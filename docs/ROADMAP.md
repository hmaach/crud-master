# CRUD MASTER — ROADMAP

## 1. High-level phases

| Phase            | Goal                      | Duration |
| ---------------- | ------------------------- | -------- |
| 0. Setup         | Tools, repo, Vagrant base | 1–2 days |
| 1. Inventory API | CRUD + PostgreSQL         | 2–3 days |
| 2. Billing API   | RabbitMQ + consumer + DB  | 2–3 days |
| 3. API Gateway   | Routing (HTTP + MQ)       | 1–2 days |
| 4. Integration   | Connect all services      | 2 days   |
| 5. VM Automation | Vagrant + scripts         | 2–3 days |
| 6. Testing       | Postman + edge cases      | 1–2 days |
| 7. Documentation | README + OpenAPI          | 1–2 days |

**Total:** ~10–17 days (focused work)

---

## 2. Phase-by-phase roadmap

### Phase 0 — Environment setup

**Goal:** working base

**Tasks**

* Install:

  * Python + venv
  * PostgreSQL
  * RabbitMQ
  * Vagrant + VirtualBox
* Create repo structure
* Add `.env` (DB creds, ports, MQ URL)

**Deliverable**

* Repo runs locally (no VMs yet)

---

### Phase 1 — Inventory API (core CRUD)

**Goal:** stable REST API

**Tasks**

* Flask app
* SQLAlchemy model:

  ```text
  Movie(id, title, description)
  ```
* Implement endpoints:

  * GET /movies
  * GET /movies/<id>
  * POST
  * PUT
  * DELETE (single + all)
* Add filtering: `?title=`

**Testing**

* Postman collection (mandatory)

**Deliverable**

* Runs on `:8080`
* Fully tested

---

### Phase 2 — Billing API (async system)

**Goal:** message-driven service

**Tasks**

* Setup RabbitMQ connection (pika)
* Create consumer:

  * listens to `billing_queue`
* Parse JSON message
* Insert into PostgreSQL:

  ```text
  Orders(id, user_id, number_of_items, total_amount)
  ```
* Implement:

  * manual ACK after DB insert
* Handle:

  * service restart → process pending messages

**Key concept**

* No HTTP here

**Deliverable**

* Queue → DB pipeline works

---

### Phase 3 — API Gateway

**Goal:** central entry point

**Tasks**

#### Inventory routing

* Proxy all:

  ```
  /api/movies → inventory service
  ```
* Return raw response

#### Billing routing

* POST `/api/billing`
* Publish message to RabbitMQ

**Important**

* Must NOT depend on Billing API being alive

**Deliverable**

* Gateway works standalone

---

### Phase 4 — Integration

**Goal:** full system works together

**Flow to validate**

1. Client → Gateway
2. Gateway → Inventory (HTTP)
3. Gateway → RabbitMQ → Billing

**Test cases**

* Billing API OFF → messages queued
* Billing API ON → messages processed

---

### Phase 5 — VMs (Vagrant)

**Goal:** production-like separation

**VMs**

* gateway-vm
* inventory-vm
* billing-vm

**Tasks**

* Write `Vagrantfile`
* Create provisioning scripts:

  * install Python, pip
  * install PostgreSQL
  * install RabbitMQ (billing VM only)
* Inject `.env` into VMs
* Setup DBs automatically

**Deliverable**

```bash
vagrant up
```

→ everything runs

---

### Phase 6 — Process management (PM2)

**Goal:** resilience

**Tasks**

* Install PM2
* Run apps:

  ```bash
  pm2 start server.py --name inventory
  ```
* Test:

  * kill billing → restart → messages processed

---

### Phase 7 — Testing

**Goal:** audit-ready

**Tasks**

* Postman:

  * 1 test per endpoint (minimum)
* Export collection (JSON)
* Test scenarios:

  * CRUD
  * queue persistence
  * failure recovery

---

### Phase 8 — Documentation

**Goal:** clarity + reproducibility

**Tasks**

#### README.md

* Architecture
* Setup steps
* Commands:

  ```bash
  vagrant up
  ```
* Env variables

#### OpenAPI (Swagger)

* Document:

  * `/api/movies`
  * `/api/billing`

---

## 3. Suggested execution order (important)

1. Inventory API (finish fully)
2. Billing API (local)
3. Gateway (local)
4. Integrate locally
5. Move to Vagrant
6. Add PM2
7. Final tests + docs

---

## 4. Key risks (and how to avoid)

| Risk                 | Fix                    |
| -------------------- | ---------------------- |
| RabbitMQ confusion   | test with CLI first    |
| DB connection issues | isolate with `.env`    |
| VM networking issues | use fixed private IPs  |
| async bugs           | log everything         |
| time overrun         | finish Inventory first |

---

## 5. What to explore next (learning)

* Reverse proxy vs API Gateway
* Event-driven architecture (EDA)
* Idempotency in message systems
* Docker version of this architecture
* Scaling RabbitMQ consumers
