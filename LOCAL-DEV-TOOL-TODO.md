# Local Development Tool — Future Features TODO

> This roadmap captures deferred work after `tembeek-local v1.10.0`.
> **Migration to `dut-tools` is the next architectural boundary and must happen before database-engine or web-server expansion.**
> The current `tembeek-local` name/config namespace remains a compatibility surface during that migration.

## Build order / dependency rule

The next major work is intentionally sequenced to avoid expanding Tembeek-specific architecture that will immediately need to be renamed or moved.

### Phase A — migrate first

1. **LOCAL-DEV-MIGRATE-01 — lock neutral identity and repository boundary**
   - choose final organization-neutral product/CLI name
   - place the tool under `dut-tools/tools/<new-name>/`
   - define the canonical executable, package/release name, config namespace, and project metadata namespace
   - keep `tembeek-local` and `tl` as compatibility entry points during the transition where appropriate

2. **LOCAL-DEV-MIGRATE-02 — migrate machine state and project metadata**
   - migrate `~/.config/tembeek-local/` into the neutral machine-config namespace
   - migrate `.tembeek/local.yaml` into the neutral project metadata namespace
   - provide idempotent migration, verification, rollback/backup, and compatibility reads
   - preserve deterministic `projects.json` recovery through the namespace transition

3. **LOCAL-DEV-MIGRATE-03 — neutralize implementation terminology**
   - remove Tembeek-specific internal names from:
     - environment variables
     - launchd labels
     - privileged helper paths
     - generated Apache/proxy files
     - logs/process-state paths
     - tests
     - README/help output
   - preserve backwards-compatible aliases only at explicit compatibility boundaries

4. **LOCAL-DEV-MIGRATE-04 — release and compatibility gate**
   - run the full regression suite against both canonical and compatibility command names
   - test upgrade from `tembeek-local v1.9.x`
   - cut the first neutral major-version release from `dut-tools`
   - freeze further feature work under the old standalone repository/namespace

### Phase B — generalize database runtime after migration

5. **LOCAL-DB-ADAPTERS-01 — extract database-engine contract + PostgreSQL**
   - wrap the current MySQL implementation behind a database-engine adapter contract
   - preserve existing MySQL behavior exactly
   - add PostgreSQL as the second first-class server database
   - keep ordinary project commands engine-neutral:
     - `<tool> db create <project>`
     - `<tool> db migrate <project>`
     - `<tool> db status <project>`
   - use project metadata to select the engine

6. **LOCAL-DB-MARIADB-01 — MariaDB**
   - add MariaDB behind the same engine contract
   - distinguish MySQL-compatible behavior from engine-specific lifecycle details

7. **LOCAL-DB-SQLITE-01 — SQLite**
   - add file-backed database support where appropriate
   - avoid pretending SQLite has server lifecycle/user-provisioning semantics

### Phase C — generalize web front door after migration

8. **LOCAL-WEB-ADAPTERS-01 — extract web-server contract + nginx**
   - wrap Apache behind a web-server adapter contract
   - preserve Apache/shared-hosting parity exactly
   - add nginx as the second front-door implementation
   - preserve:
     - `https://<alias>.localhost`
     - trusted TLS
     - document-root projects
     - Node/Astro/Vite/React reverse proxy
     - HMR/WebSocket forwarding
   - allow only one active local front-door server on ports 80/443 at a time
   - add safe switch/rollback semantics

9. **LOCAL-WEB-CADDY-01 — Caddy**
   - add Caddy only after the Apache/nginx contract is proven

### Dependency rule

Do **not** implement PostgreSQL/MariaDB/SQLite or nginx/Caddy in the old Tembeek-specific namespace.

The intended dependency chain is:

```text
tembeek-local v1.9.x
    ↓
dut-tools migration + neutral namespace
    ↓
database adapter extraction
    ↓
PostgreSQL
    ↓
MariaDB / SQLite
    ↓
web-server adapter extraction
    ↓
nginx
    ↓
Caddy
```

This keeps the migration small enough to verify and prevents us from doing the same abstraction work twice.

## 1. Organization-agnostic refactor

**Priority: NEXT. This section blocks Sections 8 and 9.**

- [ ] Treat the migration as `LOCAL-DEV-MIGRATE-01..04` using the build order above.
- [ ] Choose and lock the new product/CLI name.
  - Current leading candidates:
    - `devlocal`
    - `localdev`
    - `devground`
    - `worklocal`
  - Avoid names tied to Tembeek, PHP, Apache, macOS, or one database engine.
- [ ] Move implementation into `dut-tools/tools/<new-name>/`.
- [ ] Rename:
  - executable
  - config directory
  - environment variables
  - launchd labels
  - helper paths
  - documentation
  - tests
  - examples
- [ ] Provide a compatibility shim for `tembeek-local` during migration.
- [ ] Define migration of `~/.config/tembeek-local/` to the new neutral namespace.
- [ ] Define migration of `.tembeek/local.yaml` to an organization-neutral project metadata location.
- [ ] Preserve backwards compatibility long enough to avoid breaking existing local projects.
- [ ] Cut the neutralized tool as a new major version.
- [ ] Do not begin multi-database or multi-web-server implementation until this migration gate is green.

## 2. Privileged authorization sessions

Current daily lifecycle commands may require a macOS administrator password when starting or stopping the root-owned HTTP/HTTPS forwarder on ports 80 and 443.

- [ ] Add explicit authorization-session commands:
  - `<tool> auth login`
  - `<tool> auth login --ttl 8h`
  - `<tool> auth login --ttl 15d`
  - `<tool> auth status`
  - `<tool> auth logout`
- [ ] Support configurable TTLs such as:
  - `30m`
  - `8h`
  - `1d`
  - `7d`
  - `15d`
  - `30d`
- [ ] Never cache or persist the administrator password.
- [ ] Introduce a narrowly scoped root-owned helper instead of long-lived generic sudo authorization.
- [ ] Bind authorization to:
  - local macOS user UID
  - current machine
  - expiration timestamp
- [ ] Restrict privileged helper operations to an allowlist such as:
  - start forwarder
  - stop forwarder
  - query forwarder state
- [ ] Explicitly prohibit arbitrary root command execution.
- [ ] Store authorization state root-owned and non-user-modifiable.
- [ ] Add `down --logout` to shut down infrastructure and revoke authorization in one operation.
- [ ] Add audit-friendly status output showing authorization expiry without exposing secrets.

## 3. Database GUI integration

- [ ] Add:
  - `<tool> db info <project>`
  - `<tool> db open <project>`
- [ ] Print GUI-safe connection information:
  - engine
  - host
  - port
  - database
  - username
  - password source
- [ ] Never print the database password by default.
- [ ] Add explicit opt-in password reveal/copy behavior.
- [ ] Detect and support installed database clients where practical:
  - TablePlus
  - DBeaver
  - DataGrip
  - Beekeeper Studio
- [ ] Allow a preferred GUI client in machine config.
- [ ] Open a configured connection directly when the selected client supports it.
- [ ] Keep phpMyAdmin optional rather than making it part of the default workstation stack.

## 4. Project registry resilience — deeper hardening

`v1.8.0` introduces deterministic `projects.json` discovery, verification, rebuilding, and automatic missing-file recovery.

Future hardening:

- [ ] Add registry schema/version metadata.
- [ ] Add structural validation beyond JSON syntax.
- [ ] Add explicit conflict reporting when two manifests request the same registry key.
- [ ] Add explicit alias-collision reporting.
- [ ] Add recovery dry-run:
  - `<tool> project registry rebuild --dry-run`
- [ ] Add human-readable diff:
  - `<tool> project registry diff`
- [ ] Add `--force` only for truly destructive conflict resolution.
- [ ] Add stale-entry detection for projects moved or deleted from disk.
- [ ] Add moved-project reconciliation using manifest identity rather than path alone.
- [ ] Add recovery-root configuration to neutral machine config.
- [ ] Test multiple project roots and external disks.
- [ ] Ensure registry recovery remains deterministic after the organization-neutral rename.
- [ ] Add migration support from old Tembeek registry keys/config paths.

## 5. Project metadata model

- [ ] Separate portable project policy from generated machine state cleanly.
- [ ] Keep committed metadata authoritative for recoverable project identity.
- [ ] Define neutral equivalents for:
  - `registry_key`
  - `bootstrap_database`
  - `bootstrap_migrate`
  - `bootstrap_doctor`
- [ ] Add project metadata schema migrations.
- [ ] Add schema validation and compatibility checks.
- [ ] Add project-specific scan exclusions without allowing global policy escape hatches.
- [ ] Preserve the principle that project repositories remain understandable and operable without this tool.

## 6. Runtime lifecycle

Current lifecycle:

```text
setup workstation  = provision / reconcile
up                 = daily start
status             = inspect current state
down               = daily stop
```

Future work:

- [ ] Add component-scoped lifecycle:
  - `<tool> up apache`
  - `<tool> up database`
  - `<tool> up network`
  - `<tool> down apache`
  - `<tool> down database`
  - `<tool> down network`
- [ ] Add idempotent `restart`.
- [ ] Add machine-readable lifecycle status (`--json`).
- [ ] Distinguish:
  - installed
  - configured
  - running
  - healthy
  - externally owned
- [ ] Add lifecycle dependency ordering and clearer failure rollback.
- [ ] Add stale launchd/socat process reconciliation.
- [ ] Add lifecycle event logging suitable for diagnostics.

## 7. PHP/runtime management

- [ ] Add first-class PHP version management.
- [ ] Support multiple installed Homebrew PHP versions.
- [ ] Add:
  - `<tool> runtime list`
  - `<tool> runtime use php@8.4`
  - `<tool> runtime doctor`
- [ ] Reconcile Apache module configuration after PHP version changes.
- [ ] Detect shell/runtime conflicts such as Herd without treating non-authoritative runtimes as fatal.
- [ ] Preserve the configured runtime as the CLI authority regardless of shell PATH.

## 8. Database runtime expansion

**Blocked by Section 1 / `LOCAL-DEV-MIGRATE-01..04`. Implement only after the tool lives in `dut-tools` under its neutral namespace.**

### Adapter contract first

- [ ] Implement `LOCAL-DB-ADAPTERS-01`.
- [ ] Extract the existing MySQL implementation behind a database-engine contract instead of adding engine-specific top-level project commands.
- [ ] Define common capabilities:
  - install/provision runtime
  - start
  - stop
  - restart
  - status
  - doctor/readiness
  - create database
  - create/reconcile application user where applicable
  - connection info
  - migrate
  - backup
  - restore
- [ ] Keep ordinary project-facing commands stable and engine-neutral:
  - `<tool> db create <project>`
  - `<tool> db migrate <project>`
  - `<tool> db status <project>`
- [ ] Select the adapter from project metadata such as:
  - `database_engine: mysql`
  - `database_engine: postgresql`
  - `database_engine: mariadb`
  - `database_engine: sqlite`

### Engine order

- [ ] Preserve current MySQL behavior as the baseline adapter.
- [ ] Add PostgreSQL as the second first-class server database in `LOCAL-DB-ADAPTERS-01`.
  - This is intentionally first because it forces the abstraction to handle a genuinely different server engine.
- [ ] Add MariaDB in `LOCAL-DB-MARIADB-01`.
- [ ] Add SQLite in `LOCAL-DB-SQLITE-01`.
  - Model SQLite as file-backed storage; do not invent server/user lifecycle where none exists.
- [ ] Add runtime-aware DB readiness and health checks.
- [ ] Add safe local database backup/restore helpers.
- [ ] Add test fixtures for conflicting database installations.
- [ ] Keep external stacks such as MAMP unmanaged unless explicitly adopted.
- [ ] Make `setup database` reconcile engines actually required by registered projects while retaining explicit engine provisioning where useful.

## 9. Web-server/runtime expansion

**Blocked by Section 1 / `LOCAL-DEV-MIGRATE-01..04`. Implement only after migration to `dut-tools`.**

### Front-door adapter contract first

- [ ] Implement `LOCAL-WEB-ADAPTERS-01`.
- [ ] Extract the current Apache implementation behind a web-server/front-door adapter contract.
- [ ] Preserve Apache/shared-hosting parity as the baseline profile.
- [ ] Define common capabilities:
  - install/provision
  - configure
  - start
  - stop
  - restart
  - status
  - doctor
  - trusted local TLS
  - document-root serving
  - reverse proxy
  - WebSocket/HMR forwarding
  - alias/vhost generation
  - active-server health verification
- [ ] Keep project-facing behavior server-neutral:
  - `https://<alias>.localhost`
  - `<tool> project up <key>`
  - `<tool> project status <key>`
- [ ] Add nginx as the second implementation in `LOCAL-WEB-ADAPTERS-01`.
- [ ] Allow exactly one active local front-door server on ports 80/443 at a time.
- [ ] Add an explicit front-door selection/switch workflow with validation and rollback.
- [ ] Regenerate every registered project alias/proxy when switching front-door implementation.
- [ ] Preserve Node/Astro/Vite/React process-backed proxying and HMR behavior across Apache and nginx.
- [ ] Generalize document-root and rewrite-policy checks.
- [ ] Preserve `.htaccess` checks only where Apache semantics apply.
- [ ] Add nginx-specific portability/configuration checks.
- [ ] Add Caddy later in `LOCAL-WEB-CADDY-01`, only after Apache/nginx prove the contract.

## 10. Security hardening

- [ ] Add active HTTP probes proving that sensitive files are denied:
  - `.env`
  - `.git/config`
  - Composer metadata
  - PHPUnit metadata
  - project-local internal metadata
- [ ] Accept 403/404 as protected.
- [ ] Treat accidental 200 responses as blocking failures.
- [ ] Add TLS expiry/SAN health.
- [ ] Add root-owned helper integrity verification.
- [ ] Add launchd plist integrity checks.
- [ ] Add permissions checks for config, registry, secrets, certificates, and helper files.
- [ ] Add security-oriented machine-readable evidence output.

## 11. Scanner architecture

- [ ] Replace duplicated scanner logic with one canonical internal finding model.
- [ ] Render human and JSON output from the same finding set.
- [ ] Add finding IDs and severity levels.
- [ ] Support project-specific suppression with justification.
- [ ] Keep genuine deployment-risk findings unsuppressible without explicit policy exceptions.
- [ ] Expand exact regression fixtures for every previously observed false positive.

## 12. Project management UX

- [ ] Add:
  - `<tool> project status <key>`
  - `<tool> project update <key>`
  - `<tool> project rename <key>`
- [ ] Keep `project deregister` registry-only and non-destructive.
- [ ] Add separately named destructive decommission workflow.
- [ ] Require strong confirmation for destructive project/database cleanup.
- [ ] Add project move detection and registry reconciliation.

## 13. Testing and release engineering

- [ ] Preserve cumulative drop-in release archives through the migration period.
- [ ] Add macOS integration tests for:
  - Homebrew services
  - launchd
  - socat
  - mkcert
  - IPv4/IPv6
  - Apache
  - MySQL
- [ ] Add regression coverage for all prior production failures.
- [ ] Add shell static analysis in CI.
- [ ] Add release manifest and checksums.
- [ ] Add deterministic packaging.
- [ ] Add upgrade/migration tests between major config namespaces.

## 14. Long-term architectural boundary

The tool should remain a local-development orchestrator rather than becoming an application framework.

It should own:

- workstation provisioning
- local runtime orchestration
- project discovery/bootstrap
- local aliases and trusted HTTPS
- local database lifecycle through engine adapters
- local web front-door lifecycle through server adapters
- portability/readiness checks
- deterministic recovery of machine indexes

It should **not** become:

- a deployment platform
- a production secret manager
- a project framework
- a database administration UI
- a general-purpose container platform
- an organization-specific policy engine
