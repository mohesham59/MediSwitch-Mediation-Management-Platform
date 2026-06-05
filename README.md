# 📡 MediSwitch — Mediation Management Platform

A containerized telecom mediation system that collects CDR (Call Detail Record) files from upstream network nodes, processes and filters them according to configurable rules stored in a PostgreSQL database, and routes the output as CSV files to downstream nodes.

---

## 📌 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Project Structure](#project-structure)
- [Components](#components)
  - [Upstream Generators](#upstream-generators)
  - [Mediation Engine](#mediation-engine)
  - [Downstream Watchers](#downstream-watchers)
  - [Admin Web Application](#admin-web-application)
- [Database Schema](#database-schema)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Build & Run](#build--run)
- [Configuration](#configuration)
- [Known Issues & Fixes](#known-issues--fixes)

---

## 🏗️ Architecture Overview

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ MSC Generator│    │SMSC Generator│    │ PGW Generator│
│  (voice CDR) │    │  (sms CDR)   │    │ (data CDR)   │
└──────┬───────┘    └───────┬──────┘    └───────┬──────┘
       │                    │                   │
       └────────────────────┼───────────────────┘
                            │  .txt CDR files
                            ▼
                   ┌───────────────────┐
                   │  Mediation Engine │
                   │  (Java / Maven)   │
                   │                   │
                   │  1. Fetch         │
                   │  2. Parse         │
                   │  3. Filter (DB)   │
                   │  4. Route  (DB)   │
                   │  5. Write CSV     │
                   └────────┬──────────┘
                            │  .csv CDR files
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
      ┌───────────┐  ┌───────────┐  ┌───────────┐
      │  Billing  │  │  Charging │  │   Fraud   │
      │  Watcher  │  │  Watcher  │  │  Watcher  │
      └───────────┘  └───────────┘  └───────────┘
```

All components run as Docker containers and communicate through shared volume mounts.

## 🔄 Flow Diagram
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/f6b3b53d-a695-4437-8115-f37fa5030ceb" />

---

## 📁 Project Structure

```
MediSwitch-Mediation-Management-Platform/
├── Database/
│   ├── mediation_schema.sql       # Full PostgreSQL schema + seed data
│   └── mediation_system_erd.html  # ERD diagram
│
├── mediation-docker/
│   ├── docker-compose.yml
│   ├── generator/                 # Upstream CDR file generators (Bash)
│   │   ├── Dockerfile
│   │   ├── generator.sh
│   │   └── configs/
│   │       ├── msc.conf
│   │       ├── smsc.conf
│   │       └── pgw.conf
│   ├── Up-Stream-Nodes/           # Shared volumes for upstream CDR files
│   │   ├── msc-node/cdr-files/
│   │   ├── smsc-node/cdr-files/
│   │   └── pgw-node/cdr-files/
│   ├── Down-Stream-Nodes/         # Downstream watchers (Bash)
│   │   ├── Dockerfile
│   │   ├── watcher.sh
│   │   ├── configs/
│   │   │   ├── billing.conf
│   │   │   ├── charging.conf
│   │   │   └── fraud.conf
│   │   ├── billing-node/cdr-files/
│   │   ├── charging-node/cdr-files/
│   │   └── fraud-node/cdr-files/
│
├── MediationEngine/               # Core Java processing engine (Maven)
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/main/java/com/iti/
│       ├── main/Main.java
│       ├── fetcher/FileFetcher.java
│       ├── parser/CDRParser.java
│       ├── filter/FilterService.java
│       ├── router/RouterService.java
│       ├── csv/CSVBuilder.java
│       ├── model/CDRRecord.java
│       ├── database/DBConnection.java
│       └── util/FileUtil.java
│
└── mediation-webapp/              # Admin web application (Java Servlets)
    ├── Dockerfile
    ├── pom.xml
    └── src/main/
        ├── java/com/mediation/web/
        │   ├── servlet/
        │   ├── repository/
        │   ├── model/
        │   ├── filter/
        │   └── config/
        └── webapp/WEB-INF/views/
```

---

## 🧠 Components

### Upstream Generators

Three Bash-based containers that simulate network nodes producing CDR files every 10 seconds.

| Container | Config | CDR Format | Output Directory |
|-----------|--------|------------|-----------------|
| `msc-generator` | `msc.conf` | voice | `Up-Stream-Nodes/msc-node/cdr-files/` |
| `smsc-generator` | `smsc.conf` | sms | `Up-Stream-Nodes/smsc-node/cdr-files/` |
| `pgw-generator` | `pgw.conf` | data | `Up-Stream-Nodes/pgw-node/cdr-files/` |

**Voice CDR fields:** `file_id`, `caller_id`, `receiver_id`, `start_time`, `duration`, `service_id`, `hplmn`, `vplmn`, `external_charges`, `rated_flag`

**SMS CDR fields:** `file_id`, `sender_id`, `receiver_id`, `timestamp`, `message_length`, `service_type`, `hplmn`, `vplmn`, `external_charges`, `rated_flag`

**Data CDR fields:** `file_id`, `imsi`, `session_start`, `session_duration`, `data_usage_mb`, `apn`, `hplmn`, `vplmn`, `external_charges`, `rated_flag`

---

### Mediation Engine

The core Java application (`MediationEngine/`). It runs in a continuous loop (every 10 seconds) and performs the following pipeline on every unprocessed CDR file:

1. **Fetch** — scans all upstream node directories for `.txt` files not yet in the `processed/` subfolder.
2. **Parse** — reads the key=value CDR format and maps fields into a `CDRRecord` object. Logs any missing optional fields with a `⚠️` warning but continues processing.
3. **Filter** — queries the `filtration_rules` table in PostgreSQL. If any active rule matches the record, the file is dropped and moved to `processed/`.
4. **Route** — queries the `mediation_rules` table to determine which downstream nodes should receive the record.
5. **Write CSV** — appends the record to a timestamped `.csv` file in the appropriate downstream directory.
6. **Move** — moves the original `.txt` file to the `processed/` subfolder to prevent reprocessing.

**Environment variables:**

| Variable | Description | Default |
|----------|-------------|---------|
| `UPSTREAM_BASE_PATH` | Root path for upstream node volumes | `/data/upstream` |
| `DOWNSTREAM_BASE_PATH` | Root path for downstream node volumes | `/data/downstream` |
| `DB_URL` | PostgreSQL JDBC URL | — |
| `DB_USER` | Database username | — |
| `DB_PASSWORD` | Database password | — |

**Output CSV format:**
```
timestamp,source,destination,data
20260515_161225,PGW,billing,vplmn=60202;data_usage_mb=376.35;...
```

---

### Downstream Watchers

Three Bash-based containers that monitor their respective directories and log every new CSV file received.

| Container | Config | Watches |
|-----------|--------|---------|
| `billing-watcher` | `billing.conf` | `Down-Stream-Nodes/billing-node/cdr-files/` |
| `charging-watcher` | `charging.conf` | `Down-Stream-Nodes/charging-node/cdr-files/` |
| `fraud-watcher` | `fraud.conf` | `Down-Stream-Nodes/fraud-node/cdr-files/` |

---

### Admin Web Application

A Java Servlet-based web application (`mediation-webapp/`) for managing the system configuration through a browser UI.

**Features:**
- Admin account management
- Node management (upstream & downstream)
- Mediation rule configuration (source → destination routing)
- Filtration rule management (field-based, regex, blocked numbers)
- Blocked number list management
- Dashboard

---

## 🗄️ Database Schema

The system uses **PostgreSQL** with 5 tables:

| Table | Purpose |
|-------|---------|
| `nodes` | All upstream and downstream nodes |
| `mediation_rules` | Routing rules linking a source node to a destination node |
| `filtration_rules` | Filter predicates applied per mediation rule |
| `blocked_numbers` | Emergency/short-code numbers to drop |
| `admins` | Admin web application accounts |

**Supported filtration rule types:**

| Type | Behavior |
|------|----------|
| `FIELD_EQUALS` | Drop if field == value |
| `FIELD_LESS_THAN` | Drop if field < value (numeric) |
| `BLOCKED_NUMBER` | Drop if field value exists in `blocked_numbers` table |
| `REGEX_MATCH` | Drop if field value matches the given regex |

To initialize the database, run:
```bash
psql -U <user> -d <database> -f Database/mediation_schema.sql
```

---

## 🚀 Getting Started

### Prerequisites

- Docker & Docker Compose
- A running PostgreSQL instance (e.g. [Neon](https://neon.tech)) with the schema applied
- Java 17+ and Maven 3.9+ (only needed for local builds outside Docker)

### Build & Run

```bash
# Clone the repository
git clone <repo-url>
cd MediSwitch-Mediation-Management-Platform/mediation-docker

# Build all images
docker compose build

# Start all containers
docker compose up
```

To run in the background:
```bash
docker compose up -d
docker compose logs -f mediation-engine
```

To stop:
```bash
docker compose down
```

---

## ⚙️ Configuration

### Generator config example (`msc.conf`)
```bash
node=msc
format=voice
output=/data/msc-node/cdr-files
```

### Watcher config example (`billing.conf`)
```bash
node=billing
input=/data/billing-node/cdr-files
```

### Database connection

Set the following environment variables in `docker-compose.yml` under the `mediation-engine` service:

```yaml
environment:
  UPSTREAM_BASE_PATH: /data/upstream
  DOWNSTREAM_BASE_PATH: /data/downstream
  DB_URL: jdbc:postgresql://<host>/<database>
  DB_USER: <username>
  DB_PASSWORD: <password>
```

## 📌 Operational Notes
```
- All CDR data is synthetic and generated for simulation purposes only

- System is optimized for batch file-based processing scenarios

- Designed to mimic telecom mediation platforms used in production environments

- Processing interval is configurable (default: 10 seconds)
```

## 👤 Authors

**Mohamed Hesham**  
GitHub: [@mohesham59](https://github.com/mohesham59)

**Ahmed Omar**  
GitHub: [A7med3mar4](https://github.com/A7med3mar4)

**Ali Omran**  
GitHub: [@aliomran10](https://github.com/aliomran10)

## 📜 License
```
This project is intended for educational and simulation purposes only.
```
