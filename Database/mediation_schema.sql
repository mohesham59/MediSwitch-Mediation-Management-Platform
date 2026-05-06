-- ============================================================
-- MEDIATION SYSTEM DATABASE SCHEMA
-- ============================================================

CREATE DATABASE IF NOT EXISTS mediation_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE mediation_db;

-- ============================================================
-- TABLE 1: nodes
-- Stores all upstream and downstream server nodes
-- Upstream  : MSC, SMSC, PGW  (CDR source servers)
-- Downstream: Billing, Fraud  (CDR destination servers)
-- ============================================================
CREATE TABLE nodes (
    id           INT            PRIMARY KEY AUTO_INCREMENT,  -- Human-readable name for the node (e.g. MSC-01)
    name         VARCHAR(100)   NOT NULL,                    -- Upstream = CDR source | Downstream = CDR destination
    type         ENUM(
                    'Upstream',
                    'Downstream'
                 )              NOT NULL,                    -- File transfer protocol used to connect to this node
    protocol     ENUM(
                    'FTP',
                    'SFTP',
                    'SCP'
                 )              NOT NULL,                    -- IP address of the node server
    ip           VARCHAR(50)    NOT NULL,                    -- Port number for the file transfer connection
    port         INT            NOT NULL,                    -- Login username for the node connection
    username     VARCHAR(100)   NOT NULL,                    -- Encrypted password for the node connection
    password     VARCHAR(255)   NOT NULL,                    -- Remote directory path where CDR files are stored or uploaded
    remote_path  VARCHAR(255)   NOT NULL,                    -- Soft enable/disable flag for the node
    is_active    BOOLEAN        NOT NULL DEFAULT TRUE,       -- Record creation timestamp
    created_at   TIMESTAMP      NOT NULL DEFAULT NOW(),      -- Record last update timestamp
    updated_at   TIMESTAMP      NOT NULL DEFAULT NOW()
                                ON UPDATE NOW()
);


-- ============================================================
-- TABLE 2: mediation_roles
-- Defines routing rules between Upstream and Downstream nodes
-- One Upstream node can route to multiple Downstream nodes
-- ============================================================
CREATE TABLE mediation_roles (
    id                   INT       PRIMARY KEY AUTO_INCREMENT,
    source_node_id       INT       NOT NULL,               -- FK to nodes.id | must reference an Upstream node
    destination_node_id  INT       NOT NULL,               -- FK to nodes.id | must reference a Downstream node
    is_active            BOOLEAN   NOT NULL DEFAULT TRUE,  -- Enable or disable this routing rule without deleting it
    created_at           TIMESTAMP NOT NULL DEFAULT NOW(), -- Record creation timestamp

    CONSTRAINT fk_role_source
        FOREIGN KEY (source_node_id)
        REFERENCES nodes(id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_role_destination
        FOREIGN KEY (destination_node_id)
        REFERENCES nodes(id)
        ON DELETE RESTRICT,

    CONSTRAINT uq_role
        UNIQUE (source_node_id, destination_node_id)       -- Prevent duplicate routing rules
);


-- ============================================================
-- TABLE 3: cdr_files
-- Tracks every CDR file downloaded from an Upstream node
-- One file per row — full lifecycle tracked via status field
-- ============================================================
CREATE TABLE cdr_files (
    id               INT           PRIMARY KEY AUTO_INCREMENT,
    node_id          INT           NOT NULL,                     -- FK to nodes.id | the Upstream node this file was downloaded from
    file_name        VARCHAR(255)  NOT NULL,                     -- Original file name on the remote server
    local_path       VARCHAR(500)  NOT NULL,                     -- Full local path where the file is stored after download
    archive_path     VARCHAR(500),                               -- Path where the original file is archived after processing
    status           ENUM(
                        'DOWNLOADED',   -- File downloaded, not yet processed
                        'PROCESSING',   -- Mediation engine is currently processing the file
                        'PROCESSED',    -- File processed successfully
                        'UPLOADED',     -- Processed file uploaded to all Downstream nodes
                        'ARCHIVED',     -- Original file moved to archive
                        'FAILED'        -- An error occurred during processing or upload
                     )            NOT NULL DEFAULT 'DOWNLOADED',
    total_records    INT,                                        -- Total number of CDR records found in the file
    valid_records    INT,                                        -- Number of records that passed all filters
    filtered_records INT,                                        -- Number of records removed by filters (short/zero duration)
    error_message    TEXT,                                       -- Error details if status = FAILED
    downloaded_at    TIMESTAMP     NOT NULL DEFAULT NOW(),       -- Timestamp when the file was downloaded
    processed_at     TIMESTAMP,                                  -- Timestamp when processing completed
    uploaded_at      TIMESTAMP,                                  -- Timestamp when file was uploaded to all Downstream nodes
    archived_at      TIMESTAMP,                                  -- Timestamp when the file was archived

    CONSTRAINT fk_file_node
        FOREIGN KEY (node_id)
        REFERENCES nodes(id)
        ON DELETE RESTRICT
);


-- ============================================================
-- TABLE 4: cdr_records
-- Stores every individual CDR record extracted from a CDR file
-- after decoding ASN.1 and parsing
-- ============================================================
CREATE TABLE cdr_records (
    id               BIGINT        PRIMARY KEY AUTO_INCREMENT,
    file_id          INT           NOT NULL,               -- FK to cdr_files.id | the file this record was extracted from
    a_number         VARCHAR(30),                          -- Calling party number (MSISDN)
    b_number         VARCHAR(30),                          -- Called party number (MSISDN)
    short_code       VARCHAR(20),                          -- Short code if the call/SMS was to a special number
    record_type      VARCHAR(50),                          -- Type of CDR: MOC, MTC, SMS-MO, SMS-MT, GPRS, etc.
    call_start_time  DATETIME,                             -- Date and time when the call/session started
    call_duration    INT,                                  -- Duration of the call in seconds
    data_volume      BIGINT,                               -- Data volume in bytes (used for GPRS/PGW records)
    imsi             VARCHAR(20),                          -- International Mobile Subscriber Identity
    imei             VARCHAR(20),                          -- International Mobile Equipment Identity
    cell_id          VARCHAR(50),                          -- Cell tower ID where the call originated
    cause_for_term   VARCHAR(50),                          -- Cause for call termination (normalRelease, abnormal, etc.)
    raw_data         TEXT,                                 -- Original decoded ASN.1 raw string before transformation
    is_filtered      BOOLEAN       NOT NULL DEFAULT FALSE, -- TRUE = this record was removed by a filter rule
    filter_reason    VARCHAR(255),                         -- Reason for filtering: ZERO_DURATION, SHORT_CALL, INVALID_NUMBER, etc.
    created_at       TIMESTAMP     NOT NULL DEFAULT NOW(), -- Timestamp when this record was inserted

    CONSTRAINT fk_record_file
        FOREIGN KEY (file_id)
        REFERENCES cdr_files(id)
        ON DELETE CASCADE,

    INDEX idx_record_file_id   (file_id),                 -- Speed up queries by file
    INDEX idx_record_a_number  (a_number),                -- Speed up queries by calling party
    INDEX idx_record_b_number  (b_number),                -- Speed up queries by called party
    INDEX idx_record_type      (record_type),             -- Speed up filtering by CDR type
    INDEX idx_record_filtered  (is_filtered)              -- Speed up retrieval of filtered vs valid records
);


-- ============================================================
-- TABLE 5: upload_log
-- Tracks every upload attempt from Mediation to a Downstream node
-- One row per file per destination — retries are logged separately
-- ============================================================
CREATE TABLE upload_log (
    id                   INT       PRIMARY KEY AUTO_INCREMENT,
    cdr_file_id          INT       NOT NULL,               -- FK to cdr_files.id | the processed file being uploaded
    destination_node_id  INT       NOT NULL,               -- FK to nodes.id | the Downstream node receiving the file
    status               ENUM(
                            'PENDING',    -- Upload queued but not started
                            'UPLOADING',  -- Upload in progress
                            'SUCCESS',    -- File delivered successfully
                            'FAILED',     -- Upload failed
                            'RETRYING'    -- Scheduled for retry after failure
                         )        NOT NULL DEFAULT 'PENDING',
    attempt_number       INT       NOT NULL DEFAULT 1,     -- Upload attempt count (incremented on each retry)
    error_message        TEXT,                             -- Error details if status = FAILED
    started_at           TIMESTAMP,                        -- Timestamp when the upload attempt started
    completed_at         TIMESTAMP,                        -- Timestamp when the upload attempt finished (success or fail)

    CONSTRAINT fk_upload_file
        FOREIGN KEY (cdr_file_id)
        REFERENCES cdr_files(id)
        ON DELETE CASCADE,

    CONSTRAINT fk_upload_destination
        FOREIGN KEY (destination_node_id)
        REFERENCES nodes(id)
        ON DELETE RESTRICT,

    INDEX idx_upload_status (status)                       -- Speed up queries for PENDING / RETRYING jobs
);


-- ============================================================
-- TABLE 6: filter_rules
-- Configurable filtering rules applied during CDR processing
-- Rules are evaluated per Upstream node or globally
-- ============================================================
CREATE TABLE filter_rules (
    id           INT           PRIMARY KEY AUTO_INCREMENT,
    node_id      INT,                                      -- FK to nodes.id | NULL means this rule applies to ALL nodes
    rule_name    VARCHAR(100)  NOT NULL,                   -- Descriptive name for the rule (e.g. FILTER_ZERO_DURATION)
    rule_field   VARCHAR(100)  NOT NULL,                   -- CDR field to evaluate (e.g. call_duration, a_number)
    operator     ENUM(
                    'EQUALS',
                    'NOT_EQUALS',
                    'LESS_THAN',
                    'GREATER_THAN',
                    'CONTAINS',
                    'STARTS_WITH',
                    'IS_NULL'
                 )             NOT NULL,                   -- Comparison operator for the rule condition
    rule_value   VARCHAR(255),                             -- Value to compare against (NULL if operator = IS_NULL)
    action       ENUM(
                    'DROP',   -- Discard the CDR record entirely
                    'FLAG'    -- Keep the record but mark it as filtered
                 )             NOT NULL DEFAULT 'DROP',
    is_active    BOOLEAN       NOT NULL DEFAULT TRUE,      -- Enable/disable this rule without deleting it
    created_at   TIMESTAMP     NOT NULL DEFAULT NOW(),     -- Record creation timestamp

    CONSTRAINT fk_filter_node
        FOREIGN KEY (node_id)
        REFERENCES nodes(id)
        ON DELETE CASCADE
);


-- ============================================================
-- TABLE 7: users
-- Web application users with role-based access control
-- ============================================================
CREATE TABLE users (
    id           INT           PRIMARY KEY AUTO_INCREMENT,
    username     VARCHAR(100)  NOT NULL UNIQUE,            -- Unique login username
    password     VARCHAR(255)  NOT NULL,                   -- Bcrypt hashed password — never stored in plain text
    full_name    VARCHAR(150),                             -- Display name of the user
    email        VARCHAR(150)  NOT NULL UNIQUE,            -- User email address
    role         ENUM(
                    'ADMIN',     -- Full access: CRUD on nodes, roles, rules, users
                    'OPERATOR',  -- Can view logs and trigger manual runs
                    'VIEWER'     -- Read-only access
                 )             NOT NULL DEFAULT 'VIEWER',
    is_active    BOOLEAN       NOT NULL DEFAULT TRUE,      -- Soft delete / account disable flag
    last_login   TIMESTAMP,                                -- Timestamp of last successful login
    created_at   TIMESTAMP     NOT NULL DEFAULT NOW()      -- Record creation timestamp
);


-- ============================================================
-- TABLE 8: audit_log
-- Tracks all user actions performed via the Web Application
-- ============================================================
CREATE TABLE audit_log (
    id           BIGINT        PRIMARY KEY AUTO_INCREMENT,
    user_id      INT,                                      -- FK to users.id | NULL if action was triggered by the system
    action       VARCHAR(100)  NOT NULL,                   -- Action performed (e.g. CREATE_NODE, DELETE_ROLE, LOGIN)
    entity       VARCHAR(100),                             -- The table/entity affected (e.g. nodes, mediation_roles)
    entity_id    INT,                                      -- The ID of the affected row
    old_value    JSON,                                     -- Previous state of the record before the change (for updates)
    new_value    JSON,                                     -- New state of the record after the change (for updates)
    ip_address   VARCHAR(50),                              -- IP address of the user who performed the action
    performed_at TIMESTAMP     NOT NULL DEFAULT NOW(),     -- Timestamp when the action was performed

    CONSTRAINT fk_audit_user
        FOREIGN KEY (user_id)
        REFERENCES users(id)
        ON DELETE SET NULL,

    INDEX idx_audit_user     (user_id),
    INDEX idx_audit_entity   (entity, entity_id),
    INDEX idx_audit_performed(performed_at)
);
