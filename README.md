
# 🔄 Mediation System — Full Workflow & Database Architecture

This repository contains the database schema, workflow logic, and architecture for the Telecom Mediation System. The system is responsible for fetching raw CDR (Call Detail Record) files from Upstream nodes, processing and filtering them, and securely uploading them to Downstream nodes for billing and fraud analysis.

---

## 🗺️ High-Level Architecture
```text
┌──────────────────────────────────────────────────────────────┐
│                    MEDIATION SYSTEM FLOW                     │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  [Upstream Nodes]  →  [Download]  →  [Process]  →  [Upload]  │
│   MSC/SMSC/PGW          ↓                ↓             ↓     │
│   (FTP/SFTP/SCP)    cdr_files      cdr_records    upload_log │
│                                ↓                             │
│                          filter_rules                        │
│                                                              │
│                    →  [Downstream Nodes]                     │
│                        Billing / Fraud                       │
└──────────────────────────────────────────────────────────────┘
```

---

## 📋 Database Tables Breakdown

### 🟦 Table 1: `nodes`
> **Purpose:** The core configuration table. It stores all servers/nodes involved in the mediation process.
```text
┌─────────────────────────────────────────────┐
│ id  │ name    │ type       │ protocol │ ip  │
├─────┼─────────┼────────────┼──────────┼─────┤
│  1  │ MSC-01  │ Upstream   │ SFTP     │ ... │
│  2  │ SMSC-01 │ Upstream   │ FTP      │ ... │
│  3  │ PGW-01  │ Upstream   │ SCP      │ ... │
│  4  │ Billing │ Downstream │ SFTP     │ ... │
│  5  │ Fraud   │ Downstream │ FTP      │ ... │
└─────────────────────────────────────────────┘
```
* **Stored Data:** Server name, Node type (`Upstream`/`Downstream`), Protocol (`FTP`/`SFTP`/`SCP`), IP/Port, encrypted credentials, and remote path.
* **Trigger:** Written when the Admin adds a new Node via the Web Application.

### 🟦 Table 2: `mediation_roles`
> **Purpose:** Defines the routing rules. It dictates which Upstream node sends data to which Downstream node.
```text
┌────────────────────────────────────────────────┐
│ id │ source_node_id │ destination_node_id      │
├────┼────────────────┼──────────────────────────┤
│  1 │   1 (MSC-01)   │  4 (Billing)             │
│  2 │   1 (MSC-01)   │  5 (Fraud)               │
│  3 │   2 (SMSC-01)  │  4 (Billing)             │
└────────────────────────────────────────────────┘
```
* **Stored Data:** `source_node_id` (Upstream), `destination_node_id` (Downstream), and `is_active` status.
* **Trigger:** Written when the Admin maps an Upstream to a Downstream via the Web App.

### 🟦 Table 3: `cdr_files`
> **Purpose:** Tracks the complete lifecycle of every single CDR file from download to archiving.
```text
Lifecycle Lifecycle:
┌────────────┐   ┌────────────┐   ┌───────────┐   ┌──────────┐   ┌──────────┐
│ DOWNLOADED │ → │ PROCESSING │ → │ PROCESSED │ → │ UPLOADED │ → │ ARCHIVED │
└────────────┘   └────────────┘   └───────────┘   └──────────┘   └──────────┘
                                                                       ↓
                                                                    FAILED ❌
                                                                (At any stage)
```
* **Stored Data:** File name, local storage path, current status, record counts (Total/Valid/Filtered), timestamps, and error messages (if any).
* **Trigger:** Inserted the moment the Mediation engine downloads a new file from an Upstream Node.

### 🟦 Table 4: `cdr_records`
> **Purpose:** Stores individual parsed records extracted from the raw CDR files.
```text
MSC_20240101.asn  (10,000 records)
        ↓ Parse & Decode ASN.1
┌──────────────────────────────────────────────────────────────────┐
│ id  │ file_id │ a_number  │ b_number  │ duration │ is_filtered   │
├─────┼─────────┼───────────┼───────────┼──────────┼───────────────┤
│   1 │    1    │ 201001234 │ 201005678 │   120    │ FALSE (✅)    │
│   2 │    1    │ 201001111 │ 201002222 │     0    │ TRUE  (❌)    │
│   3 │    1    │ 201003333 │ 201004444 │     2    │ TRUE  (❌)    │
│   4 │    1    │ 201005555 │ 201006666 │   300    │ FALSE (✅)    │
└──────────────────────────────────────────────────────────────────┘
```
* **Stored Data:** A-Number, B-Number, call duration (seconds), CDR type (Voice, SMS, Data), IMSI, IMEI, Cell ID, filter status (`is_filtered`), and filter reason.
* **Trigger:** Inserted during the `PROCESSING` stage after decoding the ASN.1 file.

### 🟦 Table 5: `upload_log`
> **Purpose:** Logs every single attempt to upload a processed file to a Downstream Node.
```text
┌─────────────────────────────────────────────────────────────┐
│ id │ cdr_file_id │ destination_node_id │ status  │ attempt  │
├────┼─────────────┼─────────────────────┼─────────┼──────────┤
│  1 │      1      │     4 (Billing)     │ SUCCESS │    1     │
│  2 │      1      │     5 (Fraud)       │ FAILED  │    3     │
│  3 │      2      │     4 (Billing)     │ PENDING │    0     │
└─────────────────────────────────────────────────────────────┘
```
* **Stored Data:** Target File ID, Destination Node ID, Upload Status, Attempt Counter (for Retry Logic), and error trace.
* **Trigger:** Written when the Mediation engine attempts to push a file downstream.

### 🟦 Table 6: `filter_rules`
> **Purpose:** Stores dynamic filtering criteria applied to individual CDR records.
```text
┌────────────────────────────────────────────────────────────────────────────┐
│ id │node_id│ rule_name          │ field         │ operator  │ value │action│
├────┼───────┼────────────────────┼───────────────┼───────────┼───────┼──────┤
│  1 │ NULL  │ FILTER_ZERO_DUR    │ call_duration │ EQUALS    │   0   │ DROP │
│  2 │ NULL  │ FILTER_SHORT_CALL  │ call_duration │ LESS_THAN │   5   │ DROP │
│  3 │   1   │ FILTER_NULL_ANUM   │ a_number      │ IS_NULL   │  NULL │ DROP │
└────────────────────────────────────────────────────────────────────────────┘
* Note: node_id = NULL means the rule applies globally to all Nodes.
```
* **Stored Data:** Rule name, target field, operator (e.g., EQUALS, LESS_THAN), comparison value, and required action (`DROP` or `FLAG`).
* **Trigger:** Written when the Admin creates a new filtering rule via the Web App.

### 🟦 Table 7: `users`
> **Purpose:** Manages Web Application user accounts and RBAC (Role-Based Access Control).

| id | username | role     | Permissions |
|----|----------|----------|-------------|
| 1  | admin    | ADMIN    | Full System Access (CRUD) |
| 2  | ops_user | OPERATOR | View logs, trigger manual execution |
| 3  | viewer1  | VIEWER   | Read-only access |

* **Trigger:** Written when the Admin creates a new user profile.

### 🟦 Table 8: `audit_log`
> **Purpose:** System-wide audit trail recording user and system actions for accountability.
```text
┌──────────────────────────────────────────────────────────────────────┐
│ id │ user_id │ action        │ entity │ old_value     │ new_value    │
├────┼─────────┼───────────────┼────────┼───────────────┼──────────────┤
│  1 │    1    │ CREATE_NODE   │ nodes  │ NULL          │ {MSC-01 ...} │
│  2 │    1    │ UPDATE_NODE   │ nodes  │ {ip: 1.1.1.1} │ {ip:2.2.2.2} │
│  3 │ NULL    │ PROCESS_FILE  │ files  │ DOWNLOADED    │ PROCESSED    │
└──────────────────────────────────────────────────────────────────────┘
```
* **Trigger:** Automatically generated by the system upon any background process or user interaction.

---

## 🔄 Step-by-Step System Workflow
```text
╔══════════════════════════════════════════════════════════════════╗
║                    STEP 1 — CONFIGURATION                        ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Admin logs into the Web App                                     ║
║     ↓                                                            ║
║  Adds Nodes (MSC, SMSC, PGW, Billing, Fraud)                     ║
║     ↓ Inserted into ► nodes table                                ║
║  Links Upstream to Downstream targets                            ║
║     ↓ Inserted into ► mediation_roles table                      ║
║  Defines Filter Rules (Zero Duration, Short Calls)               ║
║     ↓ Inserted into ► filter_rules table                         ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                  STEP 2 — DOWNLOAD CDR FILES                     ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Scheduler triggers at configured intervals (e.g., 15 mins)      ║
║     ↓                                                            ║
║  Fetches active Upstream Nodes from [nodes] table                ║
║     ↓                                                            ║
║  Connects to each Node via FTP / SFTP / SCP                      ║
║     ↓                                                            ║
║  Downloads new files to local temporary storage                  ║
║     ↓                                                            ║
║  Inserts record into ► cdr_files table                           ║
║     status = 'DOWNLOADED'                                        ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                  STEP 3 — PROCESS CDR FILE                       ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Fetches files where status = 'DOWNLOADED'                       ║
║     ↓                                                            ║
║  UPDATE ► cdr_files → status = 'PROCESSING'                      ║
║     ↓                                                            ║
║  ① Decode ASN.1 → Convert Binary format to Readable format       ║
║     ↓                                                            ║
║  ② Parse Data → Iterate through every call record                ║
║     ↓ Insert into ► cdr_records table                            ║
║     ↓                                                            ║
║  ③ Apply Rules → Fetch active rules from [filter_rules]          ║
║     If call_duration == 0 → is_filtered = TRUE                   ║
║     If call_duration < 5  → is_filtered = TRUE                   ║
║     ↓ UPDATE record inside ► cdr_records table                   ║
║     ↓                                                            ║
║  ④ Generate CSV → Convert valid records to normalized CSV        ║
║     ↓                                                            ║
║  UPDATE ► cdr_files stats:                                       ║
║     status           = 'PROCESSED'                               ║
║     total_records    = 10000                                     ║
║     valid_records    = 9800                                      ║
║     filtered_records = 200                                       ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                 STEP 4 — UPLOAD TO DOWNSTREAM                    ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Fetch mapping rules from [mediation_roles] for the Source Node  ║
║     ↓                                                            ║
║  For each mapped Downstream Node:                                ║
║     Insert into ► upload_log → status = 'PENDING'                ║
║     ↓                                                            ║
║     Connect to Downstream Node (FTP/SFTP/SCP)                    ║
║     Push the processed CSV File                                  ║
║     ↓                                                            ║
║     If SUCCESS:                                                  ║
║       UPDATE ► upload_log → status = 'SUCCESS'                   ║
║     If FAILED:                                                   ║
║       UPDATE ► upload_log → status = 'FAILED', increment attempt ║
║       Queue for Retry Logic                                      ║
║     ↓                                                            ║
║  When ALL target downstream uploads succeed:                     ║
║     UPDATE ► cdr_files → status = 'UPLOADED'                     ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║                       STEP 5 — ARCHIVE                           ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Move original raw file to secure Archive Directory              ║
║     ↓                                                            ║
║  UPDATE ► cdr_files                                              ║
║     status       = 'ARCHIVED'                                    ║
║     archive_path = '/archive/2024/01/MSC_...'                    ║
║     archived_at  = NOW()                                         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

## 📊 Quick Summary Table

| Table | Primary Data | Trigger Event |
|-------|--------------|---------------|
| `nodes` | Network Servers (MSC, Billing, etc.) | Admin creates a new node profile |
| `mediation_roles` | Routing Map (Source → Destination) | Admin links upstream to downstream |
| `filter_rules` | Logical rules for dropping/flagging | Admin configures business logic |
| `cdr_files` | File metadata & processing state | System downloads a new file |
| `cdr_records` | Granular call/data records | System parses a downloaded file |
| `upload_log` | Upload attempts and retry states | System attempts file delivery |
| `users` | Admin & Operator credentials | Admin registers a new system user |
| `audit_log` | Historical log of all events | Any automated or manual system action |

---

## 🔗 Entity-Relationship (ER) Mapping
```text
users
  └──► audit_log (Logs every user action)

nodes
  ├──► mediation_roles (Acts as source or destination)
  ├──► cdr_files (Files originate from specific upstream nodes)
  │       └──► cdr_records (Records belong to specific files)
  │       └──► upload_log (Uploads are tied to specific files)
  └──► filter_rules (Rules can be tied to specific nodes)
```

```
