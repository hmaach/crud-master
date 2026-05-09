# CRUD MASTER API Documentation

## Overview
This document describes the RESTful API for the Inventory service, which manages movie records.

## Base URL
```
http://localhost:5000
```

## Endpoints

### Get All Movies
Retrieve a list of all movies, optionally filtered by title.

**GET** `/api/movies`

#### Query Parameters
| Parameter | Type   | Description               |
|-----------|--------|---------------------------|
| title     | string | Filter movies by title (partial match) |

#### Response
- **Status**: 200 OK
- **Body**: Array of movie objects
```json
[
  {
    "id": 1,
    "title": "Inception",
    "description": "A thief who steals corporate secrets through dream-sharing technology."
  }
]
```

### Get Movie by ID
Retrieve a specific movie by its ID.

**GET** `/api/movies/<int:id>`

#### Path Parameters
| Parameter | Type   | Description       |
|-----------|--------|-------------------|
| id        | integer| Movie ID          |

#### Response
- **Status**: 200 OK
- **Body**: Movie object
```json
{
  "id": 1,
  "title": "Inception",
  "description": "A thief who steals corporate secrets through dream-sharing technology."
}
```
- **Status**: 404 Not Found (if movie not found)

### Create Movie
Create a new movie record.

**POST** `/api/movies`

#### Headers
| Key            | Value             |
|----------------|-------------------|
| Content-Type   | application/json  |

#### Request Body
```json
{
  "title": "string",
  "description": "string (optional)"
}
```

#### Response
- **Status**: 201 Created
- **Body**: 
```json
{
  "message": "created"
}
```

### Update Movie
Update an existing movie record.

**PUT** `/api/movies/<int:id>`

#### Headers
| Key            | Value             |
|----------------|-------------------|
| Content-Type   | application/json  |

#### Path Parameters
| Parameter | Type   | Description       |
|-----------|--------|-------------------|
| id        | integer| Movie ID          |

#### Request Body
```json
{
  "title": "string (optional)",
  "description": "string (optional)"
}
```

#### Response
- **Status**: 200 OK
- **Body**: 
```json
{
  "message": "updated"
}
```
- **Status**: 404 Not Found (if movie not found)

### Delete Movie
Delete a specific movie by its ID.

**DELETE** `/api/movies/<int:id>`

#### Path Parameters
| Parameter | Type   | Description       |
|-----------|--------|-------------------|
| id        | integer| Movie ID          |

#### Response
- **Status**: 200 OK
- **Body**: 
```json
{
  "message": "deleted"
}
```
- **Status**: 404 Not Found (if movie not found)

### Delete All Movies
Delete all movie records.

**DELETE** `/api/movies`

#### Response
- **Status**: 200 OK
- **Body**: 
```json
{
  "message": "all deleted"
}
```

## Error Responses
All error responses follow this format:
```json
{
  "message": "Error description"
}
```

Common HTTP status codes:
- 400: Bad Request
- 404: Not Found
- 500: Internal Server Error