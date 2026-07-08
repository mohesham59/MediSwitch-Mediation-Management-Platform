# 📡 MediSwitch — Mediation Management Platform

A containerized telecom mediation system that collects CDR (Call Detail Record) files from upstream network nodes, processes and filters them according to configurable rules stored in a PostgreSQL database, and routes the output as CSV files to downstream nodes — **all file transport is done over a real FTP server (vsftpd) rather than shared filesystem mounts.**

---

## 📌 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Why FTP Instead of Shared Volumes](#why-ftp-instead-of-shared-volumes)
- [Project Structure](#project-structure)
- [Components](#components)
  - [FTP Server](#ftp-server)
  - [Upstream Generators](#upstream-generators)
  - [Mediation Engine](#mediation-engine)
  - [Downstream Watchers](#downstream-watchers)
  - [Admin Web Application](#admin-web-application)
- [Database Schema](#database-schema)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Build & Run](#build--run)
- [Configuration](#configuration)
- [Batching Behavior](#batching-behavior)
- [Known Issues & Fixes](#known-issues--fixes)
- [Authors](#authors)

---

## 🏗️ Architecture Overview

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ MSC Generator│    │SMSC Generator│    │ PGW Generator│
│  (voice CDR) │    │  (sms CDR)   │    │ (data CDR)   │
└──────┬───────┘    └───────┬──────┘    └───────┬──────┘
       │                    │                   │
       │   curl -T (FTP STOR, port 21)          │
       └────────────────────┼───────────────────┘
                            ▼
                   ┌───────────────────┐
                   │   FTP SERVER      │
                   │   (fauria/vsftpd) │
                   │                   │
                   │  /upstream/...    │◄─────┐
                   │  /downstream/...  │      │
                   └────────┬──────────┘      │
                            │                 │
              raw FTP socket (fetch, delete)  │ raw FTP socket
                            ▼                 │ (STOR, EPSV/PASV)
                   ┌───────────────────┐      │
                   │  Mediation Engine │──────┘
                   │  (Java / Maven)   │
                   │                   │
                   │  1. Fetch (FTP)   │
                   │  2. Parse         │
                   │  3. Filter (DB)   │
                   │  4. Route  (DB)   │
                   │  5. Build CSV     │
                   │  6. Upload (FTP)  │
                   └───────────────────┘
                            │
              curl --list-only (FTP LIST, port 21)
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
      ┌───────────┐  ┌───────────┐  ┌───────────┐
      │  Billing  │  │  Charging │  │   Fraud   │
      │  Watcher  │  │  Watcher  │  │  Watcher  │
      └───────────┘  └───────────┘  └───────────┘
```

All components run as Docker containers on a shared Compose network and communicate **exclusively through the FTP server** — there is no bind-mounted shared folder between the generators, the engine, and the watchers anymore. The only shared filesystem state is inside the `ftp-server` container itself, persisted via two named Docker volumes (`ftp-upstream`, `ftp-downstream`).

---

## 🔄 Why FTP Instead of Shared Volumes

An earlier version of this project used Docker bind mounts (`./Up-Stream-Nodes/...:/data/upstream/...`) so that every container could read/write the same folder on the host disk. That works, but only when every container runs on the **same physical host** — it does not reflect how mediation platforms actually move CDR files between distributed network elements in the real world.

This version replaces that with a **real FTP server** (`fauria/vsftpd`) sitting in the middle:

| | Shared Volumes (old) | FTP Server (current) |
|---|---|---|
| Transport | Host bind mount, same disk | Real network protocol (FTP, port 21 + passive range) |
| Discovery | Polling a local folder | Polling `LIST` output from the FTP server |
| Realism | Simulation-only, single host | Mirrors real telecom mediation transport (many platforms still use FTP/SFTP for CDR delivery) |
| Portability | Containers must share a host filesystem | Any container that can reach `ftp-server:21` can participate, even across hosts/networks |
| Auth | None | FTP username/password (`mediuser` / `medipass`) |

The trade-off is added complexity: every producer/consumer now needs FTP credentials, has to wait for the FTP server to be ready before starting, and has to handle FTP-specific failure modes (login errors, passive-mode port ranges, etc.) — all covered below.

---

## 📁 Project Structure

```
MediSwitch-Mediation-Management-Platform/
├── Database/
│   ├── mediation_schema.sql       # Full PostgreSQL schema + seed data
│   └── mediation_system_erd.html  # ERD diagram
│
├── mediation-docker/
│   ├── docker-compose.yml         # Orchestrates ftp-server + all nodes
│   ├── generator/                 # Upstream CDR file generators (Bash + curl)
│   │   ├── Dockerfile
│   │   ├── generator.sh
│   │   └── configs/
│   │       ├── msc.conf
│   │       ├── smsc.conf
│   │       └── pgw.conf
│   ├── Down-Stream-Nodes/         # Downstream watchers (Bash + curl)
│   │   ├── Dockerfile
│   │   ├── watcher.sh
│   │   └── configs/
│   │       ├── billing.conf
│   │       ├── charging.conf
│   │       └── fraud.conf
│
├── MediationEngine/               # Core Java processing engine (Maven)
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/main/java/com/iti/
│       ├── main/Main.java
│       ├── fetcher/FileFetcher.java   # Pulls + deletes files from FTP /upstream
│       ├── parser/CDRParser.java
│       ├── filter/FilterService.java  # Queries filtration_rules (PostgreSQL)
│       ├── router/RouterService.java  # Queries mediation_rules (PostgreSQL)
│       ├── csv/CSVBuilder.java        # Builds CSV, uploads to FTP /downstream
│       ├── model/CDRRecord.java
│       ├── database/DBConnection.java
│       └── util/FileUtil.java
│
└── mediation-webapp/              # Admin web application (Java Servlets, Tomcat)
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

> Note: `Up-Stream-Nodes/` and per-node `cdr-files/` host folders from the previous bind-mount design are no longer used by any service — all CDR storage now lives inside the `ftp-server` container's volumes.

---

## 🧠 Components

### FTP Server

A single `ftp-server` container running the `fauria/vsftpd` image, acting as the central hand-off point for every CDR/CSV file in the system.

```yaml
ftp-server:
  image: fauria/vsftpd
  environment:
    FTP_USER: mediuser
    FTP_PASS: medipass
    PASV_MIN_PORT: 21100
    PASV_MAX_PORT: 21110
    PASV_ADDRESS_ENABLE: "YES"
    PASV_ADDR_RESOLVE: "YES"     # resolves its own container hostname instead of a hardcoded IP
    PASV_ADDRESS: ftp-server
    LOCAL_UMASK: "022"
    LOG_STDOUT: "YES"
  volumes:
    - ftp-upstream:/home/vsftpd/mediuser/upstream
    - ftp-downstream:/home/vsftpd/mediuser/downstream
  ports:
    - "21:21"
    - "21100-21110:21100-21110"
```

**Key points:**
- **Port 21** handles the FTP *control* connection (login, commands like `STOR`/`LIST`/`DELE`).
- **Ports 21100–21110** are the *passive-mode data port range* — every actual file transfer opens a new socket in this range. Both the control port and the entire passive range must be published (`ports:`) or transfers will hang/timeout.
- `PASV_ADDR_RESOLVE: "YES"` + `PASV_ADDRESS: ftp-server` tell vsftpd to advertise its own Docker Compose service name for passive connections instead of an internal container IP that other containers couldn't reach — this was a deliberate fix, since hardcoding an IP breaks the moment the container is recreated.
- Two directories exist under the FTP user's home: `/upstream` (written by generators, read+deleted by the engine) and `/downstream` (written by the engine, read by watchers).
- Both directories are backed by **named Docker volumes** (`ftp-upstream`, `ftp-downstream`), so CDR data survives a `docker compose restart` but is wiped by `docker compose down -v`.

---

### Upstream Generators

Three Bash-based containers that simulate network nodes producing CDR files every 10 seconds and **upload each one to the FTP server** instead of writing to a local shared folder.

| Container | Config | CDR Format | Remote FTP Directory |
|-----------|--------|------------|----------------------|
| `msc-generator` | `msc.conf` | voice | `/upstream/msc-node/cdr-files/` |
| `smsc-generator` | `smsc.conf` | sms | `/upstream/smsc-node/cdr-files/` |
| `pgw-generator` | `pgw.conf` | data | `/upstream/pgw-node/cdr-files/` |

**Startup sequence (`generator.sh`):**
1. **Wait for the FTP server.** Before generating anything, the script polls with `curl --connect-timeout 3 "ftp://$FTP_HOST:$FTP_PORT" --user "$FTP_USER:$FTP_PASS"` in a loop every 3 seconds until it succeeds. This prevents a generator from crashing on startup just because `ftp-server` hasn't finished initializing yet (Compose's `depends_on` only waits for the container to *start*, not for vsftpd to be *ready to accept logins*).
2. **Ensure the remote directory exists**, via `curl --ftp-create-dirs ftp://.../` — vsftpd won't auto-create nested folders on `STOR`, so this primes the path once at startup.
3. **Generate + upload loop**, every 10 seconds:
   - Build the CDR content to a local temp file (`/tmp/<node>_cdr_<timestamp>.txt`).
   - Upload it with `curl -T "$TMP" "ftp://$FTP_HOST:$FTP_PORT$FTP_DIR/$FILE_NAME" --user "$FTP_USER:$FTP_PASS" --ftp-create-dirs`.
   - Delete the local temp file regardless of upload success/failure, so `/tmp` doesn't fill up over a long-running container.

**Voice CDR fields:** `file_id`, `caller_id`, `receiver_id`, `start_time`, `duration`, `service_id`, `hplmn`, `vplmn`, `external_charges`, `rated_flag`

**SMS CDR fields:** `file_id`, `sender_id`, `receiver_id`, `timestamp`, `message_length`, `service_type`, `hplmn`, `vplmn`, `external_charges`, `rated_flag`

**Data CDR fields:** `file_id`, `imsi`, `session_start`, `session_duration`, `data_usage_mb`, `apn`, `hplmn`, `vplmn`, `external_charges`, `rated_flag`

---

### Mediation Engine

The core Java application (`MediationEngine/`). It runs a continuous loop and performs the following pipeline every cycle:

1. **Fetch (FTP)** — `FileFetcher` connects to the FTP server and lists files under `/upstream/<node>/cdr-files/` for each upstream node, downloading up to `MAX_FILES_PER_BATCH` files per node per cycle (see [Batching Behavior](#batching-behavior)).
2. **Parse** — reads the key=value CDR format and maps fields into a `CDRRecord` object.
3. **Filter (PostgreSQL)** — opens a database connection and queries the `filtration_rules` table. If any active rule matches the record, it is dropped.
4. **Route (PostgreSQL)** — opens a second database connection and queries the `mediation_rules` table to determine which downstream node(s) — Billing, Charging, Fraud — should receive the record. A single record can route to more than one destination.
5. **Buffer + Build CSV** — matching records are buffered in memory per destination, then serialized into a CSV block (`CSVBuilder`).
6. **Upload (raw FTP socket)** — rather than using Java's built-in `FtpURLConnection`, `CSVBuilder` speaks the FTP protocol manually over a raw `Socket`: `USER`/`PASS` login, `TYPE I` (binary mode), `EPSV` (falling back to `PASV`) to open a data channel, `MKD` to ensure the remote folder exists, then `STOR` to push the CSV bytes. This gives finer control over passive-mode negotiation than the JDK's deprecated FTP client.
7. **Cleanup** — once a source file has been fully processed, it is deleted from `/upstream/...` on the FTP server (`FileUtil`) so it is never re-processed.

**Environment variables:**

| Variable | Description | Default |
|----------|-------------|---------|
| `FTP_HOST` | Hostname of the FTP server | `ftp-server` |
| `FTP_PORT` | FTP control port | `21` |
| `FTP_USER` | FTP username | `mediuser` |
| `FTP_PASS` | FTP password | `medipass` |
| `FTP_UPSTREAM_BASE` | Root FTP path for upstream nodes | `/upstream` |
| `FTP_DOWNSTREAM_BASE` | Root FTP path for downstream nodes | `/downstream` |
| `MAX_FILES_PER_BATCH` | Max files fetched per node per cycle | `5` |
| `DB_URL` | PostgreSQL JDBC URL | — |
| `DB_USER` | Database username | — |
| `DB_PASSWORD` | Database password | — |

**Output CSV format:**
```
timestamp,source,destination,record_type,caller_id,receiver_id,duration,data_usage_mb,message_length,external_charges,extra
2026-07-07 20:52:31,MSC,billing,,2010012018,2010024501,134,,,7.53,service_id=3;hplmn=60201;vplmn=60202
```

---

### Downstream Watchers

Three Bash-based containers that poll the FTP server every 5 seconds and log every new CSV file they observe.

| Container | Config | Watches (FTP path) |
|-----------|--------|---------------------|
| `billing-watcher` | `billing.conf` | `/downstream/billing-node/cdr-files/` |
| `charging-watcher` | `charging.conf` | `/downstream/charging-node/cdr-files/` |
| `fraud-watcher` | `fraud.conf` | `/downstream/fraud-node/cdr-files/` |

**Logic (`watcher.sh`):**
1. Wait for the FTP server to accept logins (same retry loop as the generators).
2. Every 5 seconds, run `curl --list-only "ftp://$FTP_HOST:$FTP_PORT$FTP_DIR/" --user "$FTP_USER:$FTP_PASS"` to get the current file listing.
3. For every `.csv` filename not already seen (tracked in an in-memory `SEEN_FILES` string), print `Received: <filename>`.

Unlike the mediation engine, the watchers are **read-only** — they never delete or move files on the FTP server; they only observe and log.

---

### Admin Web Application

A Java Servlet-based web application (`mediation-webapp/`, deployed on Apache Tomcat) for managing the system configuration through a browser UI, exposed on `localhost:8080`.

**Features:**
- Admin account management
- Node management (upstream & downstream)
- Mediation rule configuration (source → destination routing)
- Filtration rule management (field-based, regex, blocked numbers)
- Blocked number list management
- Dashboard, with FTP connection settings (`FTP_HOST`, `FTP_USER`, `FTP_PASS`, `FTP_DOWNSTREAM_BASE`) so it can browse delivered CSVs directly from the FTP server.

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
- A running PostgreSQL instance (e.g. [Neon](https://neon.tech)) with the schema applied — the FTP server does **not** replace the database; PostgreSQL still holds all routing/filtering configuration
- Java 17+ and Maven 3.9+ (only needed for local builds outside Docker)
- Ports **21** and **21100–21110** free on the host for FTP control + passive data connections, and **8080** free for the web app

### Build & Run

```bash
# Clone the repository
git clone <repo-url>
cd MediSwitch-Mediation-Management-Platform/mediation-docker

# Build all images
docker compose build

# Start all containers (ftp-server first, others wait on it)
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

To stop **and** wipe the FTP volumes (clears any leftover CDR/CSV files):
```bash
docker compose down -v
```

---

## ⚙️ Configuration

### Generator config example (`msc.conf`)
```bash
node=msc
format=voice
```
> The `output=` path used in the old bind-mount setup is no longer read by `generator.sh` — the upload destination now comes entirely from the `FTP_DIR` environment variable set per-service in `docker-compose.yml`.

### Watcher config example (`billing.conf`)
```bash
node=billing
```
> Same change applies here: the `input=` local path is unused now; `FTP_DIR` (env var) drives which remote folder is polled.

### FTP credentials

Every service that talks to the FTP server takes the same four variables:
```yaml
environment:
  FTP_HOST: ftp-server
  FTP_USER: mediuser
  FTP_PASS: medipass
  FTP_DIR: /upstream/<node>-node/cdr-files      # or /downstream/... for watchers
```
These **must** match the `FTP_USER`/`FTP_PASS` set on the `ftp-server` service itself — a mismatch produces `FtpLoginException: Invalid username/password` in the `mediation-engine` logs (see [Known Issues](#known-issues--fixes)).

### Database connection

Set the following environment variables under the `mediation-engine` service in `docker-compose.yml`:

```yaml
environment:
  FTP_HOST: ftp-server
  FTP_USER: mediuser
  FTP_PASS: medipass
  FTP_UPSTREAM_BASE: /upstream
  FTP_DOWNSTREAM_BASE: /downstream
  MAX_FILES_PER_BATCH: "5"
  DB_URL: jdbc:postgresql://<host>/<database>
  DB_USER: <username>
  DB_PASSWORD: <password>
```

---

## 📦 Batching Behavior

To avoid one node flooding the engine's processing loop, `FileFetcher` caps how many files it pulls **per node, per cycle** using `MAX_FILES_PER_BATCH` (default `5`). If more files are waiting than the cap allows, the engine logs how many are left over, e.g.:

```
QUEUED: pgw_cdr_20260707_205231.txt
QUEUED: pgw_cdr_20260707_205241.txt
QUEUED: pgw_cdr_20260707_205250.txt
QUEUED: pgw_cdr_20260707_205300.txt
QUEUED: pgw_cdr_20260707_205310.txt
⏳ 1 more pending in pgw-node
```

The remaining file(s) are simply picked up on the next cycle — nothing is lost, processing just spreads across multiple loop iterations when the generators produce faster than the engine drains a single node's backlog.

Each processed file logs its full pipeline outcome:
```
📥 Processing : msc-node_msc_cdr_20260707_205231.txt
✅ Parsed [UNKNOWN] ... → 13 fields
📋 Fields     : 13
🕐 Timestamp  : 2026-07-07 20:52:31
[DB] Connected Successfully      # Filter check
📡 Source     : MSC
[DB] Connected Successfully      # Route lookup
🎯 Dests      : [Billing, Fraud]
🗑️  Deleted: /upstream/msc-node/cdr-files/msc_cdr_20260707_205231.txt
✅ Deleted from FTP + local temp: msc-node_msc_cdr_20260707_205231.txt
✅ Done       : msc-node_msc_cdr_20260707_205231.txt
```

---

## 🐞 Known Issues & Fixes

| Issue | Symptom | Fix |
|---|---|---|
| **Missing `package` declaration** | `mvn package` fails with `duplicate class: CSVBuilder` and `bad source file ... file does not contain class com.iti.csv.CSVBuilder` (or the same for `Main`) | Every `.java` file must start with the `package` statement matching its folder path (e.g. `package com.iti.csv;` for a file under `com/iti/csv/`). Without it, javac treats the file as being in the *default package*, which collides with how other files reference it via `import com.iti.csv.CSVBuilder;`. |
| **`Could not find or load main class com.iti.main.Main`** | Container starts, immediately exits with `ClassNotFoundException: com.iti.main.Main`, then restarts in a loop | Same root cause as above, but on `Main.java` — the JAR manifest points to `com.iti.main.Main`, but a missing `package com.iti.main;` line puts the compiled class in the default package instead of `com/iti/main/Main.class` inside the JAR. |
| **`FtpLoginException: Invalid username/password`** | `mediation-engine` logs `❌ Failed to write/upload CSV for: billing` / `fraud` right after a successful parse | The `FTP_USER`/`FTP_PASS` used by `CSVBuilder` didn't match the `ftp-server` service's configured credentials, or `ftp-server` wasn't fully initialized yet when the engine attempted to log in. Ensure all services share identical `FTP_USER`/`FTP_PASS` values and that `ftp-server` is healthy before dependents start writing. |
| **PGW `Timestamp` field shows `cdr_20260707` instead of a real timestamp** | Log line `🕐 Timestamp : cdr_20260707` for PGW records only | `CDRParser` appears to be reading a fragment of the filename for PGW's `session_start` field rather than the correct key from the CDR body — voice and SMS records parse correctly. Not yet fixed; tracked for a future pass on `CDRParser`. |
| **Stale Docker build cache masking source fixes** | Rebuilding after fixing source still reproduces the old compile error | Run `docker compose build --no-cache <service>` (or `docker builder prune -f` for a full reset) to force Docker to re-read the corrected source instead of reusing a cached layer. |

---

## 📌 Operational Notes
```
- All CDR data is synthetic and generated for simulation purposes only
- All inter-service communication now goes through the ftp-server container — no host-level shared folders are required
- System is optimized for batch file-based processing scenarios
- Designed to mimic telecom mediation platforms used in production environments
- Processing interval is configurable (default: 10 seconds); batch size per node is configurable via MAX_FILES_PER_BATCH (default: 5)
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
