# CRUD Master

## Overview

CRUD Master is a microservices-based movie platform composed of:

- **API Gateway** (entry point)
- **Inventory API** (CRUD + PostgreSQL)
- **Billing API** (RabbitMQ consumer + PostgreSQL)

The system demonstrates synchronous (HTTP) and asynchronous (message queue) communication.

![App Diagram](docs/assets/crud-master-diagram.png)

---

## Architecture

- Gateway → Inventory (HTTP)
- Gateway → Billing (RabbitMQ)

### Services (VMs)

- `gateway-vm` → API Gateway
- `inventory-vm` → Inventory API + movies_db
- `billing-vm` → Billing API + billing_db + RabbitMQ

---

## Tech Stack

- Python (Flask)
- PostgreSQL
- RabbitMQ (pika)
- PM2
- Vagrant + VirtualBox

---

## Project Structure

```
.
├── README.md
├── AI_CONTEXT.md
├── .env
├── Vagrantfile
├── scripts/
└── srcs/
    ├── api-gateway-app/
    ├── inventory-app/
    └── billing-app/
```

---

## Setup

### 1. Prerequisites

- Vagrant
- VirtualBox

### 2. Start infrastructure

```bash
vagrant up
```

### 3. Check status

```bash
vagrant status
```

### 4. Access a VM

```bash
vagrant ssh gateway-vm
```

---

## API Usage

### Base URL

```
http://192.168.56.12:8000
```

### Inventory

- `GET /api/movies`
- `POST /api/movies`
- `GET /api/movies/<id>`
- `PUT /api/movies/<id>`
- `DELETE /api/movies/<id>`

### Billing

- `POST /api/billing`

Example:

```json
{
  "user_id": "3",
  "number_of_items": "5",
  "total_amount": "180"
}
```

---

## Testing

- Import Postman collection
- Test all endpoints
- Validate:
  - CRUD operations
  - Billing queue behavior
  - Service restart handling

---

## Process Management

```bash
pm2 list
pm2 stop <service>
pm2 restart <service>
```

---

## Key Behavior

- Gateway always accepts requests
- Inventory is synchronous
- Billing is asynchronous via RabbitMQ
- Messages persist if Billing is down

---

## Run Services Manually (optional)

```bash
cd srcs/<service>
python server.py
```

---

## Notes

- Configuration uses `.env`
- No credentials are hardcoded
- Each service runs independently in its own VM
