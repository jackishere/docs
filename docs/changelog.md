# Changelog

All notable changes to Gatekeeper are documented here. Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [v1.3.0] — 2026-04-20 *(unreleased)*

### Added

- **mTLS support** — Gatekeeper can now verify client certificates as an alternative to Bearer tokens. Configure via `auth.mtls`.
- **`GET /v1/policies`** — list all active policy rules with their current state.
- **Helm chart** — official Helm chart published at `charts.example.com/gatekeeper`.

### Changed

- Minimum Go version bumped to 1.23.
- Docker base image changed from `alpine:3.18` to `distroless/static` — image size reduced from 18MB to 6MB.

---

## [v1.2.0] — 2026-04-20

### Added

- **Audit log** — all token issuance and revocation events now written to a structured audit log file, configurable via `observability.audit_log`.
- **`POST /v1/tokens/refresh`** — new endpoint to exchange a refresh token for a new access token without re-authenticating.
- **`gatekeeper validate`** subcommand — alias for `--dry-run`, easier to use in CI pipelines.

### Changed

- OIDC provider now caches JWKS keys with a 5-minute TTL instead of fetching on every request. Reduces latency on token validation by ~40ms p99.
- `X-User-Roles` header now sends roles as a comma-separated string instead of a JSON array for broader upstream compatibility.

### Fixed

- Refresh tokens were not invalidated when the parent access token was revoked via `DELETE /v1/tokens/{id}`.

---

## [v1.1.0] — 2026-03-15

### Added

- **OIDC provider** — new `type: oidc` provider backend supporting any OpenID Connect compliant issuer. Roles are extracted from a configurable claim (`roles_claim`).
- **`--dry-run` flag** — validate `gatekeeper.yaml` and exit without starting the server. Useful in CI to catch config errors before deploy.
- **`X-Request-ID` header** — Gatekeeper now echoes or generates a request ID on all responses for easier distributed tracing correlation.

### Changed

- Default `auth.ttl` reduced from `1h` to `15m` to align with common security guidance for short-lived access tokens.
- LDAP provider now retries the bind once on connection timeout before returning 503, reducing transient failures under load.

### Fixed

- Policy engine evaluated rules in insertion order rather than file order when loaded from an external policy file. Rules are now always evaluated top-to-bottom as documented.

---

## [v1.0.1] — 2026-02-02

### Security

- **CVE-2026-1234** — Fixed a race condition in the token revocation cache. Under sustained concurrent revocation requests (>500 rps), a revoked token could transiently pass validation for up to 200ms after revocation. The cache is now protected with a read-write mutex. All users on v1.0.0 should upgrade.

### Fixed

- Gatekeeper returned HTTP 500 when the configured upstream was unreachable. The correct status is 502 Bad Gateway. This affected health check integrations that treat 5xx uniformly.
- `--config` flag was silently ignored if `GATEKEEPER_CONFIG` environment variable was also set. Flags now take precedence over environment variables as documented.

---

## [v1.0.0] — 2026-01-10

Initial stable release.

### Added

- JWT issuance and validation with HMAC-SHA256 (HS256) and RSA-256 (RS256) signing
- Local and LDAP identity providers
- Per-route policy engine with allow/deny rules based on JWT role claims
- Management API: issue, inspect, revoke tokens; upsert policy rules
- Prometheus metrics at `/v1/metrics`
- Liveness probe at `/v1/health`
- TLS termination with certificate hot-reload on SIGHUP
- Single-binary distribution, no external runtime dependencies
- Docker image at `ghcr.io/example/gatekeeper`
