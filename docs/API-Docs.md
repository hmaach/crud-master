# CRUD Master API Documentation

## Overview

All client requests go through the **API Gateway**, which routes them to the appropriate service:

- `/api/movies/*` → Inventory API (HTTP)
- `/api/billing` → Billing API (RabbitMQ, async)

Service topology (IPs, ports, databases, routes) is defined in [`config.yaml`](config.yaml) and loaded by [`scripts/common.sh`](scripts/common.sh:1) during VM provisioning.

> **Base URL:** `http://192.168.56.12:8000` (Gateway VM)

---

## Inventory API (via Gateway)

### Get All Movies

Retrieve a list of all movies, optionally filtered by title.

**GET** `/api/movies`

#### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `title` | string | Filter movies by title (partial match) |

#### Response

- **Status:** 200 OK
- **Body:** Array of movie objects

```json
[
  {
    "id": 1,
    "title": "Inception",
    "description": "A thief who steals corporate secrets through dream-sharing technology."
  }
]
```

---

### Get Movie by ID

Retrieve a specific movie by its ID.

**GET** `/api/movies/<int:id>`

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | integer | Movie ID |

#### Response

- **Status:** 200 OK
- **Body:** Movie object

```json
{
  "id": 1,
  "title": "Inception",
  "description": "A thief who steals corporate secrets through dream-sharing technology."
}
```

- **Status:** 404 Not Found (if movie not found)

---

### Create Movie

Create a new movie record.

**POST** `/api/movies`

#### Headers

| Key | Value |
|---|---|
| `Content-Type` | `application/json` |

#### Request Body

```json
{
  "title": "Inception",
  "description": "A thief who steals corporate secrets through dream-sharing technology."
}
```

#### Response

- **Status:** 201 Created
- **Body:**

```json
{
  "message": "created"
}
```

---

### Update Movie

Update an existing movie record.

**PUT** `/api/movies/<int:id>`

#### Headers

| Key | Value |
|---|---|
| `Content-Type` | `application/json` |

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | integer | Movie ID |

#### Request Body

```json
{
  "title": "Inception (Updated)",
  "description": "Updated description."
}
```

#### Response

- **Status:** 200 OK
- **Body:**

```json
{
  "message": "updated"
}
```

- **Status:** 404 Not Found (if movie not found)

---

### Delete Movie

Delete a specific movie by its ID.

**DELETE** `/api/movies/<int:id>`

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | integer | Movie ID |

#### Response

- **Status:** 200 OK
- **Body:**

```json
{
  "message": "deleted"
}
```

- **Status:** 404 Not Found (if movie not found)

---

### Delete All Movies

Delete all movie records.

**DELETE** `/api/movies`

#### Response

- **Status:** 200 OK
- **Body:**

```json
{
  "message": "all deleted"
}
```

---

## Billing API (via Gateway → RabbitMQ)

> The Billing service has **no HTTP API**. All interaction is asynchronous via RabbitMQ.
> The Gateway accepts billing requests even when the Billing service is stopped.

### Post Billing Order

Publish a billing order message to the `billing_queue`. The Billing consumer picks it up and inserts it into `billing_db.orders`.

**POST** `/api/billing`

#### Headers

| Key | Value |
|---|---|
| `Content-Type` | `application/json` |

#### Request Body

```json
{
  "user_id": "3",
  "number_of_items": 5,
  "total_amount": 180.0
}
```

#### Response

- **Status:** 200 OK
- **Body:**

```json
{
  "message": "Message posted"
}
```

> The message is acknowledged by RabbitMQ immediately. The actual DB insert happens asynchronously in the Billing consumer.

---

## Error Responses

All error responses follow this format:

```json
{
  "message": "Error description"
}
```

Common HTTP status codes:

| Code | Meaning |
|---|---|
| 200 | OK |
| 201 | Created |
| 400 | Bad Request |
| 404 | Not Found |
| 500 | Internal Server Error |

---

## Service Reference

| Service | VM | IP | Port | Database |
|---|---|---|---|---|
| API Gateway | `gateway-vm` | 192.168.56.12 | 8000 | — |
| Inventory API | `inventory-vm` | 192.168.56.10 | 8080 | `movies_db` |
| Billing API | `billing-vm` | 192.168.56.11 | — | `billing_db` |
| RabbitMQ | `billing-vm` | 192.168.56.11 | 5672 | — |

### Database Schemas

**movies_db — `movies` table**

| Column | Type | Description |
|---|---|---|
| `id` | integer (PK) | Auto-generated unique identifier |
| `title` | string(255) | Movie title |
| `description` | text | Movie description |

**billing_db — `orders` table**

| Column | Type | Description |
|---|---|---|
| `id` | integer (PK) | Auto-generated unique identifier |
| `user_id` | string(50) | ID of the user placing the order |
| `number_of_items` | integer | Number of items ordered |
| `total_amount` | float | Total order cost |

---

## Message Queue

| Property | Value |
|---|---|
| Queue name | `billing_queue` |
| Durable | Yes |
| ACK strategy | Manual ACK after DB insert |
| Prefetch | 1 |
| Pending messages on restart | Processed automatically |
