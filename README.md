# 📡 MediSwitch-Mediation-Management-Platform

A configurable **CDR (Call Detail Record) Mediation Platform** built with Java Spring Boot and PostgreSQL.
It collects CDR files from upstream nodes (MSC, SMSC, PGW), processes and filters them, then delivers the results to downstream systems (Billing, Fraud Detection).

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [API Endpoints](#api-endpoints)
- [Mediation Engine](#mediation-engine)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Running the Project](#running-the-project)
- [Testing](#testing)
- [Deployment](#deployment)

---

## 🔍 Overview

The Mediation System acts as a **middleware pipeline** between telecom network elements and downstream business systems.

```
[MSC / SMSC / PGW]  →  [Mediation Engine]  →  [Billing / Fraud]
     (Upstream)              (Process)           (Downstream)
```

### What it does:

- Connects to upstream nodes via **FTP / SFTP / SCP**
- Downloads CDR files matching configured patterns
- Decodes **ASN.1** binary files into structured records
- Applies configurable **filters** (e.g. remove zero-duration calls)
- Maps and transforms fields per destination requirements
- Uploads processed **CSV files** to downstream nodes
- Tracks every file and delivery with full **audit trail**

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    Web Application                       │
│         (CRUD Nodes / Rules / Monitoring)                │
└──────────────────────┬───────────────────────────────────┘
                       │ REST API
┌──────────────────────▼──────────────────────────────────┐
│                  Spring Boot Backend                    │
│                                                         │
│  ┌───────────┐  ┌───────────┐  ┌──────────────────────┐ │
│  │Collector  │→ │ Decoder   │→ │  Filter + Transform  │ │
│  │FTP/SFTP   │  │ASN.1/CSV  │  │  Field Mapping       │ │
│  └───────────┘  └───────────┘  └──────────┬───────────┘ │
│                                           │             │
│                                   ┌───────▼───────┐     │
│                                   │   Dispatcher  │     │
│                                   │  FTP/SFTP out │     │
│                                   └───────────────┘     │
└─────────────────────────────────────────────────────────┘
                       │
┌─────────────────────▼───────────────────────────────────┐
│                    PostgreSQL Database                  │
│   nodes │ rules │ cdr_files │ deliveries │ configs      │
└─────────────────────────────────────────────────────────┘
```

---

## 🛠️ Tech Stack

| Layer          | Technology              |
|----------------|-------------------------|
| Language       | Java 17                 |
| Framework      | Spring Boot 3.x         |
| Database       | PostgreSQL 15           |
| ORM            | Spring Data JPA / Hibernate |
| Security       | Spring Security + JWT   |
| FTP/SFTP       | Apache Commons Net + JSch |
| ASN.1 Decoding | Bouncy Castle           |
| Build Tool     | Maven                   |
| IDE            | NetBeans                |
| API Docs       | Swagger / OpenAPI 3     |
| Containerize   | Docker + Docker Compose |

---

## 📁 Project Structure

```
mediation-system/
├── src/main/java/com/mediation/
│   ├── config/                  # Security, Swagger, Scheduler configs
│   ├── model/                   # JPA Entities
│   │   └── enums/               # Enum types
│   ├── dto/
│   │   ├── request/             # Incoming request DTOs
│   │   └── response/            # Outgoing response DTOs
│   ├── repository/              # Spring Data JPA Repositories
│   ├── service/                 # Business Logic Interfaces
│   │   └── impl/                # Service Implementations
│   ├── controller/              # REST Controllers (Servlets)
│   ├── engine/                  # Mediation Engine Core
│   │   ├── collector/           # FTP / SFTP / SCP collectors
│   │   ├── decoder/             # ASN.1 / CSV / Text decoders
│   │   ├── filter/              # Filter engine
│   │   ├── transformer/         # Field mapping & CSV generation
│   │   └── dispatcher/          # File upload to downstream
│   ├── scheduler/               # Scheduled tasks
│   ├── security/                # JWT provider & filter
│   ├── exception/               # Global exception handling
│   ├── mapper/                  # Entity ↔ DTO mappers
│   └── util/                    # Utility classes
├── src/main/resources/
│   ├── application.properties   # Main config
│   └── db/
│       └── schema.sql           # PostgreSQL schema
├── src/test/                    # Unit & Integration tests
├── docker-compose.yml
├── Dockerfile
└── pom.xml
```

---

## 🗄️ Database Schema

The system uses **10 tables**:

| Table                  | Description                                      |
|------------------------|--------------------------------------------------|
| `users`                | Web application users (admin / viewer)           |
| `nodes`                | Upstream and downstream network nodes            |
| `node_cdr_config`      | CDR format config per upstream node              |
| `cdr_field_mapping`    | Maps ASN.1 fields to internal unified fields     |
| `cdr_filters`          | Filtering rules (exclude zero duration, etc.)    |
| `node_output_config`   | Output format config per downstream node         |
| `output_field_mapping` | Maps internal fields to downstream CSV columns   |
| `mediation_rules`      | Routing rules: which upstream sends to which downstream |
| `cdr_files`            | Tracks every downloaded CDR file                 |
| `cdr_file_deliveries`  | Tracks every file delivery to downstream nodes   |

### Key Relationships

```
nodes (upstream)
  ├── node_cdr_config (1-to-1)
  │     ├── cdr_field_mapping (1-to-many)
  │     └── cdr_filters (1-to-many)
  └── cdr_files (1-to-many)
        └── cdr_file_deliveries (1-to-many)

nodes (downstream)
  ├── node_output_config (1-to-1)
  │     └── output_field_mapping (1-to-many)
  └── cdr_file_deliveries (1-to-many)

mediation_rules → connects upstream nodes to downstream nodes
```

---

## 🌐 API Endpoints

### Authentication
| Method | Endpoint            | Description     |
|--------|---------------------|-----------------|
| POST   | `/api/auth/login`   | Login & get JWT |
| POST   | `/api/auth/logout`  | Logout          |

### Nodes
| Method | Endpoint                        | Description              |
|--------|---------------------------------|--------------------------|
| GET    | `/api/nodes`                    | Get all nodes            |
| GET    | `/api/nodes/{id}`               | Get node by ID           |
| POST   | `/api/nodes`                    | Create new node          |
| PUT    | `/api/nodes/{id}`               | Update node              |
| DELETE | `/api/nodes/{id}`               | Delete node              |
| POST   | `/api/nodes/{id}/test-connection` | Test node connection   |
| GET    | `/api/nodes/upstream`           | Get upstream nodes only  |
| GET    | `/api/nodes/downstream`         | Get downstream nodes only|

### CDR Config & Field Mapping
| Method | Endpoint                                          | Description            |
|--------|---------------------------------------------------|------------------------|
| GET    | `/api/nodes/{nodeId}/cdr-config`                  | Get CDR config         |
| POST   | `/api/nodes/{nodeId}/cdr-config`                  | Create CDR config      |
| PUT    | `/api/nodes/{nodeId}/cdr-config`                  | Update CDR config      |
| GET    | `/api/cdr-configs/{configId}/field-mappings`      | Get field mappings     |
| POST   | `/api/cdr-configs/{configId}/field-mappings`      | Add field mapping      |
| PUT    | `/api/cdr-configs/{configId}/field-mappings/{id}` | Update field mapping   |
| DELETE | `/api/cdr-configs/{configId}/field-mappings/{id}` | Delete field mapping   |

### Filters
| Method | Endpoint                                  | Description     |
|--------|-------------------------------------------|-----------------|
| GET    | `/api/cdr-configs/{configId}/filters`     | Get filters     |
| POST   | `/api/cdr-configs/{configId}/filters`     | Add filter      |
| PUT    | `/api/cdr-configs/{configId}/filters/{id}`| Update filter   |
| DELETE | `/api/cdr-configs/{configId}/filters/{id}`| Delete filter   |

### Mediation Rules
| Method | Endpoint                              | Description              |
|--------|---------------------------------------|--------------------------|
| GET    | `/api/mediation-rules`                | Get all rules            |
| POST   | `/api/mediation-rules`                | Create rule              |
| PUT    | `/api/mediation-rules/{id}`           | Update rule              |
| DELETE | `/api/mediation-rules/{id}`           | Delete rule              |
| GET    | `/api/mediation-rules/source/{nodeId}`| Get rules by source node |

### Monitoring
| Method | Endpoint                          | Description              |
|--------|-----------------------------------|--------------------------|
| GET    | `/api/cdr-files`                  | All CDR files            |
| GET    | `/api/cdr-files/{id}`             | File details             |
| GET    | `/api/cdr-files/status/{status}`  | Files by status          |
| GET    | `/api/dashboard/stats`            | System statistics        |
| GET    | `/api/dashboard/recent-files`     | Last 10 processed files  |
| GET    | `/api/dashboard/failed`           | Failed files             |
| GET    | `/api/dashboard/summary`          | Today's summary          |

---

## ⚙️ Mediation Engine

The engine runs on a configurable schedule and processes files in 6 steps:

```
Step 1 → Collector     : Connect & download files from upstream (FTP/SFTP/SCP)
Step 2 → Decoder       : Decode ASN.1 binary into structured records
Step 3 → Filter Engine : Apply configured filters (zero duration, short calls, etc.)
Step 4 → Transformer   : Map fields from internal format to destination format
Step 5 → CSV Generator : Generate CSV file per downstream node
Step 6 → Dispatcher    : Upload CSV to downstream node & update delivery status
```

### Supported Protocols
- **Input:** FTP, SFTP, SCP
- **Output:** FTP, SFTP

### Supported File Formats
- **Input:** ASN.1, CSV, TEXT, IPFIX
- **Output:** CSV, JSON, XML

---

## 🚀 Getting Started

### Prerequisites

- Java 17+
- Maven 3.8+
- PostgreSQL 15+
- NetBeans IDE 18+ (or any Java IDE)

### Clone the Repository

```bash
git clone https://github.com/your-org/mediation-system.git
cd mediation-system
```

### Create the Database

```bash
psql -U postgres
CREATE DATABASE mediation_db;
\q
```

### Run the Schema

```bash
psql -U postgres -d mediation_db -f src/main/resources/db/schema.sql
```

---

## 🔧 Configuration

Edit `src/main/resources/application.properties`:

```properties
# ── Database ──────────────────────────────────────
spring.datasource.url=jdbc:postgresql://localhost:5432/mediation_db
spring.datasource.username=postgres
spring.datasource.password=your_password

# ── JPA ───────────────────────────────────────────
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.show-sql=false

# ── JWT ───────────────────────────────────────────
jwt.secret=your_jwt_secret_key_here
jwt.expiration=86400000

# ── Mediation Engine ──────────────────────────────
# How often the engine runs (milliseconds) — default: every 60 seconds
mediation.scheduler.interval=60000

# Local directory to store downloaded files temporarily
mediation.local.download.path=/tmp/mediation/downloads

# ── Swagger ───────────────────────────────────────
springdoc.swagger-ui.path=/swagger-ui.html
```

---

## ▶️ Running the Project

### Option 1: NetBeans

```
1. Open NetBeans
2. File → Open Project → select mediation-system/
3. Right-click project → Build
4. Right-click project → Run
5. Open browser: http://localhost:8080/swagger-ui.html
```

### Option 2: Maven CLI

```bash
mvn clean install
mvn spring-boot:run
```

### Option 3: Docker Compose

```bash
docker-compose up --build
```

`docker-compose.yml`:

```yaml
version: '3.8'
services:

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: mediation_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: your_password
    ports:
      - "5432:5432"
    volumes:
      - pg_data:/var/lib/postgresql/data
      - ./src/main/resources/db/schema.sql:/docker-entrypoint-initdb.d/schema.sql

  app:
    build: .
    ports:
      - "8080:8080"
    depends_on:
      - postgres
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/mediation_db
      SPRING_DATASOURCE_USERNAME: postgres
      SPRING_DATASOURCE_PASSWORD: your_password

volumes:
  pg_data:
```

---

## 🧪 Testing

### Run All Tests

```bash
mvn test
```

### Test Categories

| Test Type        | What it covers                              |
|------------------|---------------------------------------------|
| Unit Tests       | Decoder, FilterEngine, Transformer          |
| Integration Tests| REST API endpoints with test DB             |
| Engine Tests     | Full pipeline with sample CDR files         |

### Sample Test CDR Files

Place test files in `src/test/resources/samples/`:

```
src/test/resources/samples/
├── voice_sample.dat     ← MSC ASN.1 sample
├── sms_sample.cdr       ← SMSC ASN.1 sample
└── data_sample.bin      ← PGW sample
```

---

## 📦 Deployment

### Build JAR

```bash
mvn clean package -DskipTests
java -jar target/mediation-system-1.0.0.jar
```

### Build Docker Image

```bash
docker build -t mediation-system:1.0.0 .
docker run -p 8080:8080 mediation-system:1.0.0
```

---

## 🔐 Security

- All endpoints (except `/api/auth/login`) require a valid **JWT token**
- Node credentials (password) are stored **encrypted** in the database
- Role-based access: `admin` can write, `viewer` is read-only
- Prefer **SFTP over FTP** for secure file transfer

---

## 📊 Monitoring

Access the dashboard at `/api/dashboard/stats` to see:

- Total files processed today
- Failed deliveries
- Active nodes count
- Files per status (downloaded / processing / processed / failed)

---

## 🗺️ Development Roadmap

- [x] Database Schema Design
- [x] ERD Diagram
- [ ] Node CRUD API
- [ ] Authentication & JWT
- [ ] FTP / SFTP Collector
- [ ] ASN.1 Decoder
- [ ] Filter Engine
- [ ] CSV Generator & Dispatcher
- [ ] Scheduler
- [ ] Web Dashboard (Frontend)
- [ ] Docker Deployment
- [ ] Unit & Integration Tests

---

## 👨‍💻 Author

Built for a Telecom Mediation System project.
Feel free to contribute or open issues.

---

## 📄 License

This project is licensed under the MIT License.
