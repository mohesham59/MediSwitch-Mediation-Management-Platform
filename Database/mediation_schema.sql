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

INSERT INTO nodes (name, node_type, protocol, ip, port, username, password_hash, remote_path, cdr_format) VALUES
('MSC',  'UPSTREAM', 'SFTP', 'msc-node',  2221, 'msc',  'CHANGE_ME', '/cdr-files', 'voice'),
('SMSC', 'UPSTREAM', 'SFTP', 'smsc-node', 2221, 'smsc', 'CHANGE_ME', '/cdr-files', 'sms'),
('PGW',  'UPSTREAM', 'SFTP', 'pgw-node',  2221, 'pgw',  'CHANGE_ME', '/cdr-files', 'data');


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
