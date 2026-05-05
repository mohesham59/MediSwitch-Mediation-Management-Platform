-- ============================================================
--   MEDIATION SYSTEM - PostgreSQL Database Schema
-- ============================================================


-- ============================================================
-- ENUM TYPES - defined once, reused across tables
-- ============================================================

CREATE TYPE user_role          AS ENUM ('admin', 'viewer');
CREATE TYPE node_type          AS ENUM ('upstream', 'downstream');
CREATE TYPE node_protocol      AS ENUM ('FTP', 'SCP', 'SFTP');
CREATE TYPE cdr_type           AS ENUM ('voice', 'sms', 'data');
CREATE TYPE cdr_file_format    AS ENUM ('ASN1', 'TEXT', 'IPFIX', 'CSV');
CREATE TYPE output_format      AS ENUM ('CSV', 'JSON', 'XML', 'ASN1');
CREATE TYPE field_type         AS ENUM ('string', 'integer', 'timestamp', 'bytes');
CREATE TYPE filter_operator    AS ENUM ('=', '!=', '>', '<', '>=', '<=', 'IS NULL', 'IS NOT NULL');
CREATE TYPE filter_action      AS ENUM ('exclude', 'include');
CREATE TYPE cdr_file_status    AS ENUM ('downloaded', 'processing', 'processed', 'failed');
CREATE TYPE delivery_status    AS ENUM ('pending', 'uploaded', 'failed');


-- ============================================================
-- FUNCTION - auto-update updated_at column on row change
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ============================================================
-- 1. USERS - System users for web application login
-- ============================================================

CREATE TABLE users (
    id            SERIAL PRIMARY KEY,
    username      VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role          user_role NOT NULL DEFAULT 'viewer',
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();


-- ============================================================
-- 2. NODES - All network nodes (Upstream and Downstream)
-- ============================================================

CREATE TABLE nodes (
    id            SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    type          node_type NOT NULL,
    protocol      node_protocol NOT NULL,
    ip            INET NOT NULL,                      -- PostgreSQL native IP type (supports IPv4 & IPv6)
    port          INTEGER NOT NULL DEFAULT 22
                      CHECK (port BETWEEN 1 AND 65535),
    username      VARCHAR(100) NOT NULL,
    password      VARCHAR(255) NOT NULL,              -- stored encrypted
    remote_path   VARCHAR(255),                       -- path on the remote server
    archive_path  VARCHAR(255),                       -- local archive path after download
    is_active     BOOLEAN NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_nodes_updated_at
    BEFORE UPDATE ON nodes
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_nodes_type     ON nodes (type);
CREATE INDEX idx_nodes_active   ON nodes (is_active);


-- ============================================================
-- 3. NODE_CDR_CONFIG - CDR configuration for each Upstream Node
-- ============================================================

CREATE TABLE node_cdr_config (
    id              SERIAL PRIMARY KEY,
    node_id         INTEGER NOT NULL UNIQUE            -- each node has exactly one config
                        REFERENCES nodes (id) ON DELETE CASCADE,
    cdr_type        cdr_type NOT NULL,
    file_format     cdr_file_format NOT NULL,
    file_pattern    VARCHAR(100),                      -- e.g. '*.dat' or 'CDR_*.bin'
    decoder_class   VARCHAR(100),                      -- name of the class responsible for decoding
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_node_cdr_config_updated_at
    BEFORE UPDATE ON node_cdr_config
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();


-- ============================================================
-- 4. CDR_FIELD_MAPPING - Input field mapping for each CDR type
--    Tells the Mediation which fields to read from the ASN.1 file
-- ============================================================

CREATE TABLE cdr_field_mapping (
    id                  SERIAL PRIMARY KEY,
    node_cdr_config_id  INTEGER NOT NULL
                            REFERENCES node_cdr_config (id) ON DELETE CASCADE,
    source_field        VARCHAR(100) NOT NULL,         -- field name in the original ASN.1
    target_field        VARCHAR(100) NOT NULL,         -- unified field name inside Mediation
    field_type          field_type NOT NULL,
    is_required         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cdr_field_mapping_config ON cdr_field_mapping (node_cdr_config_id);

/*
Example:
MSC Node:
  source_field='seizure_time'   -> target_field='start_time'   (timestamp, required)
  source_field='call_duration'  -> target_field='duration'     (integer,   required)
  source_field='calling_number' -> target_field='msisdn'       (string,    required)
  source_field='called_number'  -> target_field='called'       (string,    required)
  source_field='cell_id'        -> target_field='cell_id'      (string,    optional)
  source_field='imei'           -> target_field='imei'         (string,    optional)
*/


-- ============================================================
-- 5. CDR_FILTERS - Filtering rules applied to CDR records
--    e.g. exclude Zero Duration, exclude Short Calls
-- ============================================================

CREATE TABLE cdr_filters (
    id                  SERIAL PRIMARY KEY,
    node_cdr_config_id  INTEGER NOT NULL
                            REFERENCES node_cdr_config (id) ON DELETE CASCADE,
    field_name          VARCHAR(100) NOT NULL,         -- the field to apply the filter on
    operator            filter_operator NOT NULL,
    value               VARCHAR(255),                  -- the value to compare against
    action              filter_action NOT NULL DEFAULT 'exclude',
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_cdr_filters_config ON cdr_filters (node_cdr_config_id);

/*
Example:
  field_name='duration', operator='=',       value='0', action='exclude'  -> remove Zero Duration records
  field_name='duration', operator='<',       value='5', action='exclude'  -> remove Short Call records
  field_name='msisdn',   operator='IS NULL',            action='exclude'  -> remove records with no MSISDN
*/


-- ============================================================
-- 6. NODE_OUTPUT_CONFIG - Output configuration for each Downstream Node
--    Tells the Mediation how to format and deliver files to each Downstream
-- ============================================================

CREATE TABLE node_output_config (
    id              SERIAL PRIMARY KEY,
    node_id         INTEGER NOT NULL UNIQUE            -- each downstream node has exactly one output config
                        REFERENCES nodes (id) ON DELETE CASCADE,
    output_format   output_format NOT NULL DEFAULT 'CSV',
    file_prefix     VARCHAR(100),                      -- output filename prefix e.g. 'BILLING_CDR_'
    delimiter       CHAR(1) NOT NULL DEFAULT ',',      -- column delimiter for CSV output
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_node_output_config_updated_at
    BEFORE UPDATE ON node_output_config
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();


-- ============================================================
-- 7. OUTPUT_FIELD_MAPPING - Fields to be sent to each Downstream Node
--    Each Downstream receives a different set of fields
-- ============================================================

CREATE TABLE output_field_mapping (
    id                    SERIAL PRIMARY KEY,
    node_output_config_id INTEGER NOT NULL
                              REFERENCES node_output_config (id) ON DELETE CASCADE,
    source_field          VARCHAR(100) NOT NULL,       -- unified field name inside Mediation
    target_field          VARCHAR(100) NOT NULL,       -- field name in the output file sent to Downstream
    field_order           INTEGER NOT NULL DEFAULT 0,  -- column order in the output CSV
    is_required           BOOLEAN NOT NULL DEFAULT FALSE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_output_field_mapping_config ON output_field_mapping (node_output_config_id);

/*
Example:
Billing Node Output:
  source_field='msisdn'      -> target_field='msisdn'       (order=1, required)
  source_field='called'      -> target_field='b_number'     (order=2, required)
  source_field='start_time'  -> target_field='call_date'    (order=3, required)
  source_field='duration'    -> target_field='duration_sec' (order=4, required)

Fraud Node Output:
  source_field='msisdn'      -> target_field='a_number'     (order=1, required)
  source_field='called'      -> target_field='b_number'     (order=2, required)
  source_field='start_time'  -> target_field='event_time'   (order=3, required)
  source_field='duration'    -> target_field='duration'     (order=4, required)
  source_field='imei'        -> target_field='device_id'    (order=5, optional)
  source_field='cell_id'     -> target_field='location'     (order=6, optional)
*/


-- ============================================================
-- 8. MEDIATION_RULES - Routing rules: which upstream sends to which downstream
-- ============================================================

CREATE TABLE mediation_rules (
    id                    SERIAL PRIMARY KEY,
    source_node_id        INTEGER NOT NULL              -- Upstream node
                              REFERENCES nodes (id),
    destination_node_id   INTEGER NOT NULL              -- Downstream node
                              REFERENCES nodes (id),
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_mediation_rule
        UNIQUE (source_node_id, destination_node_id),  -- prevent duplicate rules

    CONSTRAINT chk_different_nodes
        CHECK (source_node_id <> destination_node_id)  -- a node cannot route to itself
);

CREATE INDEX idx_mediation_rules_source ON mediation_rules (source_node_id);
CREATE INDEX idx_mediation_rules_dest   ON mediation_rules (destination_node_id);

/*
Example:
MSC  -> Billing  (active)
MSC  -> Fraud    (active)
SMSC -> Billing  (active)
PGW  -> Billing  (active)
*/


-- ============================================================
-- 9. CDR_FILES - Tracks every CDR file downloaded from upstream nodes
-- ============================================================

CREATE TABLE cdr_files (
    id              SERIAL PRIMARY KEY,
    source_node_id  INTEGER NOT NULL
                        REFERENCES nodes (id),
    file_name       VARCHAR(255) NOT NULL,
    file_size       BIGINT CHECK (file_size >= 0),     -- size in bytes
    status          cdr_file_status NOT NULL DEFAULT 'downloaded',
    downloaded_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at    TIMESTAMPTZ,
    error_message   TEXT
);

CREATE INDEX idx_cdr_files_node     ON cdr_files (source_node_id);
CREATE INDEX idx_cdr_files_status   ON cdr_files (status);
CREATE INDEX idx_cdr_files_dl_at    ON cdr_files (downloaded_at DESC);


-- ============================================================
-- 10. CDR_FILE_DELIVERIES - Tracks delivery of each file to each downstream node
-- ============================================================

CREATE TABLE cdr_file_deliveries (
    id              SERIAL PRIMARY KEY,
    cdr_file_id     INTEGER NOT NULL
                        REFERENCES cdr_files (id),
    dest_node_id    INTEGER NOT NULL
                        REFERENCES nodes (id),
    status          delivery_status NOT NULL DEFAULT 'pending',
    uploaded_at     TIMESTAMPTZ,
    error_message   TEXT
);

CREATE INDEX idx_deliveries_file    ON cdr_file_deliveries (cdr_file_id);
CREATE INDEX idx_deliveries_node    ON cdr_file_deliveries (dest_node_id);
CREATE INDEX idx_deliveries_status  ON cdr_file_deliveries (status);


-- ============================================================
-- RELATIONSHIPS SUMMARY
-- ============================================================
/*

nodes (upstream)
  ├── node_cdr_config (1-to-1)
  │     ├── cdr_field_mapping (1-to-many)   <- defines which fields are read from ASN.1
  │     └── cdr_filters (1-to-many)          <- defines which records are excluded
  └── cdr_files (1-to-many)
        └── cdr_file_deliveries (1-to-many)

nodes (downstream)
  ├── node_output_config (1-to-1)
  │     └── output_field_mapping (1-to-many) <- defines which fields are sent to each downstream
  └── cdr_file_deliveries (1-to-many)

mediation_rules
  ├── source_node_id      -> nodes (upstream)
  └── destination_node_id -> nodes (downstream)

users
  └── web application authentication

*/