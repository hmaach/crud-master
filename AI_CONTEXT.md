# CRUD MASTER — AI CONTEXT FILE

## 1. PROJECT OVERVIEW

Microservices-based movie platform composed of:

- API Gateway (entry point)
- Inventory API (CRUD + PostgreSQL)
- Billing API (RabbitMQ consumer + PostgreSQL)

Communication:

- Gateway → Inventory: HTTP
- Gateway → Billing: RabbitMQ (async)

---

## 2. ARCHITECTURE

### Services

- gateway-vm → API Gateway (Flask)
- inventory-vm → Inventory API + movies_db
- billing-vm → Billing API + billing_db + RabbitMQ

### Flow

1. Client → Gateway
2. Gateway → Inventory (HTTP)
3. Gateway → RabbitMQ → Billing → DB

---

## 3. TECHNOLOGY STACK

- Python 3
- Flask
- SQLAlchemy
- PostgreSQL
- RabbitMQ (pika)
- PM2 (process manager)
- Vagrant (VM orchestration)

---

## 4. ENVIRONMENT VARIABLES

```env
DB_USER=appuser
DB_PASSWORD=apppass

INVENTORY_URL=http://192.168.56.10:8080
RABBITMQ_URL=amqp://mquser:mqpass@192.168.56.11:5672/
```

---

## 5. API SPECIFICATION

### Inventory API (via Gateway)

Base:

```
/api/movies
```

Endpoints:

- GET /api/movies
- GET /api/movies?title=
- POST /api/movies
- DELETE /api/movies
- GET /api/movies/<id>
- PUT /api/movies/<id>
- DELETE /api/movies/<id>

Schema:

```json
{
  "id": 1,
  "title": "string",
  "description": "string"
}
```

---

### Billing API (via Gateway → RabbitMQ)

Endpoint:

```
POST /api/billing
```

Payload:

```json
{
  "user_id": "string",
  "number_of_items": "int",
  "total_amount": "float"
}
```

Behavior:

- Message sent to `billing_queue`
- Billing service consumes
- Inserts into DB
- ACK message

---

## 6. DATABASES

### movies_db

Table: movies

- id (PK)
- title
- description

### billing_db

Table: orders (database name: `orders_db`)

- id (PK)
- user_id
- number_of_items
- total_amount

---

## 7. MESSAGE QUEUE

Queue:

```
billing_queue
```

Rules:

- durable queue
- manual ACK
- process pending messages on restart

---

## 8. PROJECT STRUCTURE

```
.
├── .env
├── Vagrantfile
├── scripts/
├── srcs/
│   ├── api-gateway-app/
│   ├── inventory-app/
│   └── billing-app/
```

---

## 9. VM CONFIGURATION

IPs:

- inventory → 192.168.56.10
- billing → 192.168.56.11
- gateway → 192.168.56.12

Command:

```bash
vagrant up
```

---

## 10. PROCESS MANAGEMENT

Using PM2:

```bash
pm2 start server.py --name <service> --interpreter python3
pm2 stop <service>
pm2 restart <service>
```

---

## 11. TESTING REQUIREMENTS

- Postman collection required
- At least 1 test per endpoint

Key tests:

- CRUD operations
- Billing queue processing
- Billing down → queue persists
- Billing restart → processes backlog

---

## 12. FAILURE SCENARIOS

- Billing OFF:
  - Gateway still accepts requests
  - Messages stored in queue

- Billing ON:
  - All pending messages processed

---

## 13. EXPECTED BEHAVIOR

- Gateway is always available
- Inventory is synchronous
- Billing is asynchronous
- No direct HTTP to Billing

---

## 14. DELIVERY REQUIREMENTS

- Working Vagrant setup
- Functional APIs
- Postman collection
- README.md
- OpenAPI (Gateway)

---

## 15. DESIGN CONSTRAINTS

- No hardcoded credentials
- Use `.env`
- Services isolated in VMs
- Billing must NOT expose HTTP API

---

## 16. OPTIONAL IMPROVEMENTS

- Logging system
- Retry mechanism for failed messages
- Docker version
- API authentication
- Monitoring (Prometheus)

---
