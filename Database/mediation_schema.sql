-- ================================================================
--  Telecom Mediation System — Simplified Schema
--  Database: PostgreSQL (Neon)
-- ================================================================


-- ----------------------------------------------------------------
-- 1. NODES
--    Every upstream (MSC, SMSC, PGW) and downstream
--    (Billing, Fraud) container is one row.
-- ----------------------------------------------------------------
CREATE TABLE nodes (
    id            SERIAL       PRIMARY KEY,
    name          VARCHAR(100) NOT NULL UNIQUE,
    node_type     VARCHAR(20)  NOT NULL CHECK (node_type IN ('UPSTREAM', 'DOWNSTREAM')),
    protocol      VARCHAR(10)  NOT NULL CHECK (protocol  IN ('SFTP', 'FTP', 'SCP', 'HTTP', 'HTTPS')),
    ip            VARCHAR(100) NOT NULL,
    port          INTEGER      NOT NULL,
    username      VARCHAR(100),
    password_hash VARCHAR(255),
    remote_path   VARCHAR(500) NOT NULL DEFAULT '/',
    cdr_format    VARCHAR(10)  CHECK (cdr_format IN ('voice', 'sms', 'data')),
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE
);

-- Upstream nodes
INSERT INTO nodes (name, node_type, protocol, ip, port, username, password_hash, remote_path, cdr_format) VALUES
('MSC',  'UPSTREAM', 'SFTP', 'msc-node',  2221, 'msc',  'CHANGE_ME', '/cdr-files', 'voice'),
('SMSC', 'UPSTREAM', 'SFTP', 'smsc-node', 2221, 'smsc', 'CHANGE_ME', '/cdr-files', 'sms'),
('PGW',  'UPSTREAM', 'SFTP', 'pgw-node',  2221, 'pgw',  'CHANGE_ME', '/cdr-files', 'data');

-- Downstream nodes
INSERT INTO nodes (name, node_type, protocol, ip, port, username, password_hash, remote_path, cdr_format) VALUES
('Billing', 'DOWNSTREAM', 'SFTP', 'billing-node', 2221, 'billing', 'CHANGE_ME', '/cdr-files', NULL),
('Fraud',   'DOWNSTREAM', 'SFTP', 'fraud-node',   2221, 'fraud',   'CHANGE_ME', '/cdr-files', NULL);


-- ----------------------------------------------------------------
-- 2. MEDIATION_RULES
--    Links one upstream node to one downstream node.
--    Create multiple rows to fan one source to many destinations.
-- ----------------------------------------------------------------
CREATE TABLE mediation_rules (
    id                   SERIAL  PRIMARY KEY,
    source_node_id       INTEGER NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
    destination_node_id  INTEGER NOT NULL REFERENCES nodes(id) ON DELETE CASCADE,
    is_active            BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (source_node_id, destination_node_id)
);

INSERT INTO mediation_rules (source_node_id, destination_node_id, is_active) VALUES
(1, 4, TRUE),  -- MSC  -> Billing
(1, 5, TRUE),  -- MSC  -> Fraud
(2, 4, TRUE),  -- SMSC -> Billing
(3, 4, TRUE),  -- PGW  -> Billing
(3, 5, TRUE);  -- PGW  -> Fraud


-- ----------------------------------------------------------------
-- 3. FILTRATION_RULES
--    Each row is one filter predicate attached to a mediation rule.
--    A CDR that matches ANY active rule is dropped (not forwarded).
--
--    rule_type values:
--      FIELD_EQUALS     — drop if field == value
--      FIELD_LESS_THAN  — drop if field < value  (numeric)
--      BLOCKED_NUMBER   — drop if field is in blocked_numbers table
--      REGEX_MATCH      — drop if field matches regex in value
-- ----------------------------------------------------------------
CREATE TABLE filtration_rules (
    id                SERIAL       PRIMARY KEY,
    mediation_rule_id INTEGER      NOT NULL REFERENCES mediation_rules(id) ON DELETE CASCADE,
    rule_type         VARCHAR(30)  NOT NULL CHECK (rule_type IN (
                          'FIELD_EQUALS',
                          'FIELD_LESS_THAN',
                          'BLOCKED_NUMBER',
                          'REGEX_MATCH'
                      )),
    field_name        VARCHAR(100) NOT NULL,
    value             VARCHAR(500),
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE
);

-- ── Rule 1: MSC -> Billing ───────────────────────────────────────
-- Drop zero-duration calls (no billable event)
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(1, 'FIELD_EQUALS', 'duration', '0');

-- Drop calls to emergency / short-code numbers
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(1, 'BLOCKED_NUMBER', 'receiver_id', NULL);

-- ── Rule 2: MSC -> Fraud ─────────────────────────────────────────
-- Drop zero-duration calls (no fraud signal in empty calls)
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(2, 'FIELD_EQUALS', 'duration', '0');

-- Drop calls to emergency numbers (not fraud targets)
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(2, 'BLOCKED_NUMBER', 'receiver_id', NULL);

-- ── Rule 3: SMSC -> Billing ──────────────────────────────────────
-- Drop messages sent to emergency / short-code numbers
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(3, 'BLOCKED_NUMBER', 'receiver_id', NULL);

-- Drop messages with zero length (empty / system messages)
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(3, 'FIELD_EQUALS', 'message_length', '0');

-- ── Rule 4: PGW -> Billing ───────────────────────────────────────
-- Drop sessions with zero data usage (not billable)
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(4, 'FIELD_EQUALS', 'data_usage_mb', '0');

-- Drop sessions shorter than 1 second (handshake-only, not billable)
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(4, 'FIELD_LESS_THAN', 'session_duration', '1');

-- ── Rule 5: PGW -> Fraud ─────────────────────────────────────────
-- Drop sessions with zero data usage (no fraud signal)
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(5, 'FIELD_EQUALS', 'data_usage_mb', '0');

-- Flag suspiciously large sessions for fraud (over 10000 MB) using regex on string value.
-- Note: for numeric range checks prefer FIELD_LESS_THAN; this shows REGEX_MATCH usage.
-- Drop IMSIs matching test/internal patterns (e.g. 00101xxxxxxxxx)
INSERT INTO filtration_rules (mediation_rule_id, rule_type, field_name, value) VALUES
(5, 'REGEX_MATCH', 'imsi', '^00101\d{10}$');


-- ----------------------------------------------------------------
-- 4. BLOCKED_NUMBERS
--    Emergency / short-code numbers checked by BLOCKED_NUMBER rules.
-- ----------------------------------------------------------------
CREATE TABLE blocked_numbers (
    id          SERIAL      PRIMARY KEY,
    number      VARCHAR(20) NOT NULL UNIQUE,
    description VARCHAR(200)
);

INSERT INTO blocked_numbers (number, description) VALUES
('911',  'US/Canada emergency'),
('112',  'International emergency'),
('999',  'UK emergency'),
('15',   'Egypt police'),
('16',   'Egypt ambulance'),
('19',   'Egypt fire'),
('122',  'Egypt general emergency');


-- ----------------------------------------------------------------
-- 5. ADMINS
--    Accounts for the servlet-based admin web application.
-- ----------------------------------------------------------------
CREATE TABLE admins (
    id            SERIAL       PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    is_active     BOOLEAN      NOT NULL DEFAULT TRUE
);

INSERT INTO admins (username, password_hash) VALUES
('admin', 'admin_123');
