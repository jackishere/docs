# Gatekeeper

Gatekeeper is a lightweight, embeddable JWT authentication and authorization gateway written in Go. It centralizes identity verification in a microservice mesh so individual services don't implement auth logic themselves.

## Features

- **JWT signing** — HMAC-SHA256 and RSA-256 support
- **Pluggable identity providers** — local, LDAP, OIDC
- **Per-route policy rules** — allow/deny based on claims
- **Prometheus metrics** — `/v1/metrics` endpoint out of the box
- **Zero external runtime dependencies** — single binary, no database required
- **TLS termination** — optional, with auto-reload on cert rotation

## Architecture

```
Client
  │
  │  Bearer <token>
  ▼
┌─────────────────────┐
│     Gatekeeper      │
│                     │
│  ┌───────────────┐  │
│  │  Token Store  │  │  ◄── in-memory + optional persistence
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │Policy Engine  │  │  ◄── per-route claim rules
│  └───────────────┘  │
│  ┌───────────────┐  │
│  │  ID Providers │  │  ◄── local / LDAP / OIDC
│  └───────────────┘  │
└────────┬────────────┘
         │  verified request (X-User-ID, X-User-Roles headers)
         ▼
  Upstream Service
```

Gatekeeper is **not** an API gateway. It is specifically an identity layer. Routing, load balancing, and rate limiting belong upstream.

## Design Philosophy

Gatekeeper follows a single rule: do one thing well. It verifies identity and enforces access policy. It does not transform requests, aggregate responses, or manage service discovery. This constraint keeps the binary small, the config surface minimal, and the failure modes predictable.
