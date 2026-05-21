# CRUD Master

## Overview

CRUD Master is a microservices-based movie platform composed of:

- **API Gateway** (entry point — port 8000)
- **Inventory API** (CRUD + PostgreSQL — port 8080)
- **Billing API** (RabbitMQ consumer + PostgreSQL — no HTTP)

The system demonstrates synchronous (HTTP) and asynchronous (message queue) communication.

![App Diagram](docs/assets/crud-master-diagram.png)

---

## Architecture

- Gateway → Inventory (HTTP)
- Gateway → Billing (RabbitMQ, async)

### Services (VMs)

| VM | Service | IP | Port |
|---|---|---|---|
| `inventory-vm` | Inventory API + `movies_db` | 192.168.56.10 | 8080 |
| `billing-vm` | Billing API + `billing_db` + RabbitMQ | 192.168.56.11 | 5672 |
| `gateway-vm` | API Gateway | 192.168.56.12 | 8000 |

---

## Tech Stack

- Python 3 / Flask
- SQLAlchemy (ORM)
- PostgreSQL
- RabbitMQ (pika)
- PM2 (process manager)
- Vagrant + VirtualBox

---

## Project Structure

```
.
├── README.md
├── AI_CONTEXT.md
├── Makefile
├── config.yaml
├── .env
├── Vagrantfile
├── scripts/
│   ├── common.sh
│   ├── install_vagrant.sh
│   ├── inventory.sh
│   ├── billing.sh
│   └── gateway.sh
├── srcs/
│   ├── api-gateway-app/
│   │   ├── app/
│   │   │   ├── __init__.py      # create_app() factory
│   │   │   ├── config.py
│   │   │   ├── mq.py            # RabbitMQ publisher
│   │   │   ├── routes.py
│   │   │   └── models.py
│   │   ├── requirements.txt
│   │   ├── server.py
│   │   └── .env.example
│   ├── billing-app/
│   │   ├── app/
│   │   │   ├── __init__.py      # create_app() factory (no HTTP routes)
│   │   │   ├── config.py
│   │   │   ├── consumer.py      # RabbitMQ consumer
│   │   │   ├── db.py
│   │   │   └── models.py
│   │   ├── requirements.txt
│   │   ├── server.py
│   │   └── .env.example
│   └── inventory-app/
│       ├── app/
│       │   ├── __init__.py      # create_app() factory
│       │   ├── config.py
│       │   ├── db.py
│       │   ├── models.py
│       │   └── routes.py
│       ├── requirements.txt
│       ├── server.py
│       └── .env.example
└── docs/
    ├── API-Docs.md
    ├── postman-collection.json
    └── ...
```

---

## Environment Variables

All credentials are defined in `.env` (root of the project). No credentials are hardcoded.

| Variable | Description | Example |
|---|---|---|
| `DB_USER` | PostgreSQL user for both DBs | `appuser` |
| `DB_PASSWORD` | PostgreSQL password | `apppass` |
| `INVENTORY_URL` | URL of the Inventory API | `http://192.168.56.10:8080` |
| `RABBITMQ_URL` | RabbitMQ connection string | `amqp://guest:guest@192.168.56.11:5672/` |

---

## Configuration (`config.yaml`)

[`config.yaml`](config.yaml) is the single source of truth for service topology. It is parsed by [`scripts/common.sh`](scripts/common.sh:1) during VM provisioning and exported as environment variables (e.g. `INVENTORY_HOST`, `INVENTORY_PORT`, `BILLING_DATABASE`, etc.) so that provisioning scripts and apps can reference a single config file instead of hardcoding values.

| Section | Key | Description |
|---|---|---|
| `services.inventory` | `host` | Inventory VM IP |
| `services.inventory` | `port` | Inventory API port |
| `services.inventory` | `database` | Inventory DB name |
| `services.inventory` | `database_user` | DB user |
| `services.inventory` | `database_table` | Table name |
| `services.inventory` | `endpoints` | List of Inventory API endpoints |
| `services.billing` | `host` | Billing VM IP |
| `services.billing` | `port` | RabbitMQ port |
| `services.billing` | `database` | Billing DB name |
| `services.billing` | `queue` | RabbitMQ queue name |
| `services.gateway` | `host` | Gateway VM IP |
| `services.gateway` | `port` | Gateway port |
| `services.gateway` | `routes` | Gateway routing table |

---

## Quick Start

### Prerequisites

- Vagrant
- VirtualBox

### 1. Start all VMs

```bash
make up
# or: vagrant up
```

### 2. Check status

```bash
make status
# or: vagrant status
```

### 3. SSH into a VM

```bash
make ssh-gateway
make ssh-inventory
make ssh-billing
# or: vagrant ssh <vm-name>
```

---

## Makefile Reference

| Command | Description |
|---|---|
| `make up` | Start all VMs (`vagrant up`) |
| `make halt` | Stop all VMs (`vagrant halt`) |
| `make status` | Show VM status (`vagrant status`) |
| `make ssh-gateway` | SSH into `gateway-vm` |
| `make ssh-inventory` | SSH into `inventory-vm` |
| `make ssh-billing` | SSH into `billing-vm` |
| `make destroy` | Destroy all VMs (`vagrant destroy -f`) |
| `make clean` | Remove `venv/`, `__pycache__/`, `*.pyc` files |
| `make install` | Install Vagrant + VirtualBox (Ubuntu/Debian) |
| `make test` | Run local smoke tests (requires services running) |

---

## API Usage

### Base URL (Gateway)

```
http://192.168.56.12:8000
```

### Inventory (via Gateway → HTTP)

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/movies` | List all movies |
| `GET` | `/api/movies?title=<name>` | Filter movies by title |
| `POST` | `/api/movies` | Create a movie |
| `GET` | `/api/movies/<id>` | Get a movie by ID |
| `PUT` | `/api/movies/<id>` | Update a movie |
| `DELETE` | `/api/movies/<id>` | Delete a movie |
| `DELETE` | `/api/movies` | Delete all movies |

### Billing (via Gateway → RabbitMQ)

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/billing` | Publish billing order to queue |

Example:

```json
{
  "user_id": "3",
  "number_of_items": 5,
  "total_amount": 180.0
}
```

---

## Testing

Import the Postman collection from [`docs/postman-collection.json`](docs/postman-collection.json).

The collection includes one test per endpoint covering:

- CRUD operations on the Inventory API
- Billing message posting via the Gateway
- Queue persistence (Billing down → messages queued)
- Service restart recovery (Billing up → pending messages processed)

---

## Process Management (PM2)

Inside any VM:

```bash
sudo pm2 list
sudo pm2 stop <app_name>
sudo pm2 restart <app_name>
```

Service names: `inventory`, `billing`, `gateway`

---

## Key Behavior

- **Gateway** is always available — it never depends on Billing being up
- **Inventory** is synchronous (HTTP)
- **Billing** is asynchronous (RabbitMQ) — no HTTP API exposed
- Messages persist in the queue if Billing is down; processed on restart

---

## Run Services Manually (local development, no VMs)

```bash
# Inventory
cd srcs/inventory-app
cp .env.example .env
# edit .env with local DB credentials
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python server.py

# Billing
cd srcs/billing-app
cp .env.example .env
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python server.py

# Gateway
cd srcs/api-gateway-app
cp .env.example .env
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python server.py
```

---

## Design Choices

- **No hardcoded credentials** — all configuration via `.env`
- **Billing has no HTTP API** — exclusively message-driven via RabbitMQ
- **Durable queue + manual ACK** — no message loss on consumer restart
- **Each service isolated in its own VM** — clear separation of concerns
- **`app.config.from_object(Config)`** used consistently across all three services
