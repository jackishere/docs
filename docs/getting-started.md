# Getting Started

## Installation

### Binary

```bash
go install github.com/example/gatekeeper/cmd/gatekeeper@latest
```

### Docker

```bash
docker pull ghcr.io/example/gatekeeper:latest
```

## Quickstart

Create a minimal config file:

```yaml
# gatekeeper.yaml
server:
  addr: ":8080"

auth:
  algorithm: HS256
  secret: "change-me-in-production"
  ttl: 15m

providers:
  - type: local
    users:
      - username: alice
        password: hunter2
        roles: [admin]
      - username: bob
        password: s3cr3t
        roles: [reader]
```

Start the server:

```bash
gatekeeper --config gatekeeper.yaml
```

Issue a token:

```bash
curl -s -X POST http://localhost:8080/v1/tokens \
  -H "Content-Type: application/json" \
  -d '{"username": "alice", "password": "hunter2"}' | jq .
```

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2026-01-10T12:15:00Z"
}
```

Use the token against a protected upstream:

```bash
curl -s http://localhost:8080/v1/health \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## Next Steps

- [API Reference](api-reference.md) — full HTTP API documentation
- [Configuration](configuration.md) — all `gatekeeper.yaml` options
