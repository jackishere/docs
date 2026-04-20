# Configuration

Gatekeeper is configured via a single YAML file. Pass its path with `--config`:

```bash
gatekeeper --config /etc/gatekeeper/gatekeeper.yaml
```

## Full annotated default config

```yaml
server:
  # TCP address to listen on.
  addr: ":8080"

  # Optional TLS. Both cert and key must be set to enable TLS.
  tls_cert: ""
  tls_key: ""

  # HTTP timeouts.
  read_timeout: 5s
  write_timeout: 10s
  idle_timeout: 120s

auth:
  # Signing algorithm. Options: HS256, HS512, RS256, RS512.
  algorithm: HS256

  # For HMAC algorithms: shared secret string.
  secret: ""

  # For RSA algorithms: paths to PEM-encoded key files.
  private_key: ""
  public_key: ""

  # How long issued tokens remain valid.
  ttl: 15m

  # Whether to issue a long-lived refresh token alongside the access token.
  refresh_token: false
  refresh_ttl: 24h

providers:
    # At least one provider is required.
    # Providers are checked in order; first match wins.

  - type: local
    # Inline user list. Not recommended for production.
    users:
      - username: alice
        # bcrypt hash or plaintext (plaintext only for dev)
        password: hunter2
        roles: [admin]

  - type: ldap
    addr: "ldap://ldap.example.com:389"
    bind_dn: "cn=gatekeeper,ou=service,dc=example,dc=com"
    bind_password: ""
    user_base_dn: "ou=users,dc=example,dc=com"
    user_filter: "(uid={{.Username}})"
    # LDAP attribute whose values map to Gatekeeper roles.
    role_attribute: "memberOf"
    role_map:
      "cn=admins,ou=groups,dc=example,dc=com": admin
      "cn=readers,ou=groups,dc=example,dc=com": reader

  - type: oidc
    issuer: "https://accounts.example.com"
    client_id: ""
    client_secret: ""
    # Claim in the OIDC ID token to use as the roles source.
    roles_claim: "roles"

policies:
  # Path to an external policy file. If set, inline rules are ignored.
  file: ""

  # Inline policy rules. Evaluated top-to-bottom; first match wins.
  rules:
    - name: health-public
      route_prefix: "/v1/health"
      effect: allow
    - name: metrics-public
      route_prefix: "/v1/metrics"
      effect: allow
    - name: admin-only
      route_prefix: "/v1/"
      require_roles: [admin]
      effect: allow
    - name: deny-all
      route_prefix: "/"
      effect: deny

observability:
  # Prometheus metrics endpoint. Set to "" to disable.
  metrics_addr: "/v1/metrics"

  # Log level. Options: debug, info, warn, error.
  log_level: info

  # Log format. Options: json, text.
  log_format: json
```

## Top-level key reference

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `server.addr` | string | `":8080"` | TCP listen address |
| `server.tls_cert` | string | `""` | Path to TLS certificate PEM |
| `server.tls_key` | string | `""` | Path to TLS private key PEM |
| `server.read_timeout` | duration | `5s` | Max time to read request |
| `server.write_timeout` | duration | `10s` | Max time to write response |
| `auth.algorithm` | string | `HS256` | JWT signing algorithm |
| `auth.secret` | string | `""` | HMAC secret (HS* algorithms) |
| `auth.ttl` | duration | `15m` | Access token lifetime |
| `auth.refresh_token` | bool | `false` | Enable refresh tokens |
| `auth.refresh_ttl` | duration | `24h` | Refresh token lifetime |
| `providers` | list | — | Ordered list of identity backends |
| `policies.file` | string | `""` | External policy file path |
| `policies.rules` | list | — | Inline policy rules |
| `observability.log_level` | string | `info` | Log verbosity |
| `observability.log_format` | string | `json` | Log output format |
