# API Reference

All endpoints are served on the address configured in `server.addr`. The management API is versioned under `/v1/`.

---

## POST /v1/tokens

Issue a new JWT for a given set of credentials.

**Request**

```
POST /v1/tokens
Content-Type: application/json
```

```json
{
  "username": "alice",
  "password": "hunter2"
}
```

**Response — 200 OK**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_id": "tok_01hx3z9k2r",
  "expires_at": "2026-01-10T12:15:00Z"
}
```

**Response codes**

| Code | Meaning |
|------|---------|
| 200 | Token issued |
| 400 | Malformed request body |
| 401 | Invalid credentials |
| 503 | Identity provider unavailable |

---

## GET /v1/tokens/{id}

Inspect a live token by its ID.

**Request**

```
GET /v1/tokens/tok_01hx3z9k2r
Authorization: Bearer <admin-token>
```

**Response — 200 OK**

```json
{
  "token_id": "tok_01hx3z9k2r",
  "subject": "alice",
  "roles": ["admin"],
  "issued_at": "2026-01-10T12:00:00Z",
  "expires_at": "2026-01-10T12:15:00Z",
  "revoked": false
}
```

**Response codes**

| Code | Meaning |
|------|---------|
| 200 | Token found |
| 401 | Missing or invalid admin token |
| 403 | Insufficient privileges |
| 404 | Token not found or already expired |

---

## DELETE /v1/tokens/{id}

Revoke a token immediately. The token will be rejected on all subsequent requests.

**Request**

```
DELETE /v1/tokens/tok_01hx3z9k2r
Authorization: Bearer <admin-token>
```

**Response — 204 No Content**

Empty body.

**Response codes**

| Code | Meaning |
|------|---------|
| 204 | Token revoked |
| 401 | Missing or invalid admin token |
| 404 | Token not found |

---

## GET /v1/health

Liveness probe. Returns 200 when the server is up and all configured identity providers are reachable.

**Request**

```
GET /v1/health
```

**Response — 200 OK**

```json
{
  "status": "ok",
  "providers": {
    "local": "ok",
    "ldap": "ok"
  },
  "uptime_seconds": 3721
}
```

No authentication required.

---

## GET /v1/metrics

Prometheus metrics in `text/plain` exposition format.

**Request**

```
GET /v1/metrics
```

**Response — 200 OK**

```
# HELP gatekeeper_tokens_issued_total Total number of tokens issued.
# TYPE gatekeeper_tokens_issued_total counter
gatekeeper_tokens_issued_total 142

# HELP gatekeeper_tokens_active Current number of non-expired, non-revoked tokens.
# TYPE gatekeeper_tokens_active gauge
gatekeeper_tokens_active 37

# HELP gatekeeper_auth_duration_seconds Latency of token issuance requests.
# TYPE gatekeeper_auth_duration_seconds histogram
gatekeeper_auth_duration_seconds_bucket{le="0.005"} 120
...
```

No authentication required. Restrict access at the network level if needed.

---

## PUT /v1/policies/{name}

Upsert a named policy rule. Policy rules control which roles may access which route prefixes.

**Request**

```
PUT /v1/policies/admin-only
Authorization: Bearer <admin-token>
Content-Type: application/json
```

```json
{
  "route_prefix": "/internal/",
  "require_roles": ["admin"],
  "effect": "allow"
}
```

**Response — 200 OK**

```json
{
  "name": "admin-only",
  "route_prefix": "/internal/",
  "require_roles": ["admin"],
  "effect": "allow",
  "created_at": "2026-01-10T11:00:00Z",
  "updated_at": "2026-01-10T12:00:00Z"
}
```

**Response codes**

| Code | Meaning |
|------|---------|
| 200 | Policy created or updated |
| 400 | Invalid policy definition |
| 401 | Missing or invalid admin token |
