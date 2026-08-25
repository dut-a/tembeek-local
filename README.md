# tembeek-local

`tembeek-local` is the local development and bootstrap CLI for Tembeek PHP projects.

Its purpose is to make a newly cloned Tembeek PHP application predictable to run on a developer workstation without relying on undocumented machine-specific setup. It standardizes Apache/PHP, local hostnames, `.env` bootstrap, MySQL provisioning, migrations, shared-hosting compatibility checks, CI readiness checks, and the `.tembeek/local.yaml` project contract.

This README is intentionally written as a handover document. A developer who has never used the tool should be able to set up a machine, onboard a project, diagnose failures, and understand the safety boundaries without needing the original author.

---

## Table of contents

1. Purpose
2. Supported environment
3. Architecture and conventions
4. Installation
5. First-time workstation setup
6. Onboarding a PHP project
7. Daily workflow
8. Local aliases and URLs
9. `.tembeek/local.yaml`
10. `.env` and `.env.example`
11. MySQL and migrations
12. Shared-hosting compatibility
13. Readiness and CI
14. Policy validation and migration
15. Doctor
16. Apache internals
17. Port-80 forwarding
18. Command reference
19. Environment variables
20. Troubleshooting
21. Recovery and rollback
22. Security rules
23. Repository conventions
24. What the tool does not do
25. New-machine checklist
26. New-project checklist
27. Versioning

---

# 1. Purpose

`tembeek-local` currently handles five areas.

## Local Apache/PHP runtime

```bash
tembeek-local setup apache
```

It prepares Homebrew Apache and PHP 8.4 for PHP applications that depend on Apache behavior such as `.htaccess`, `mod_rewrite`, and shared-hosting-style routing.

## Friendly local hostnames

Projects can be opened using names such as:

```text
http://rentbook.localhost
http://crm.localhost
http://sor.localhost
```

## Project bootstrap

```bash
tembeek-local init ~/Development/tembeek-rent-book --alias rentbook
```

This can detect the PHP document root, create `.tembeek/local.yaml`, create `.env` from `.env.example`, normalize local application settings, and register the alias.

## Local MySQL bootstrap

```bash
tembeek-local db create rentbook
tembeek-local db migrate rentbook
tembeek-local db status rentbook
```

## Readiness and shared-hosting checks

```bash
tembeek-local check hosting rentbook
tembeek-local check all rentbook
```

These are intended to catch code that works on a Mac but is likely to fail on traditional Apache/shared hosting.

---

# 2. Supported environment

Primary supported workstation:

```text
macOS
Homebrew
Homebrew httpd
PHP 8.4
MySQL
Bash
Composer
curl
```

The current Apache model is:

```text
Apache prefork MPM + mod_php
```

This is intentional because the target Tembeek PHP estate includes traditional Apache/shared-hosting deployments where `.htaccess` parity matters.

Network forwarding is macOS-specific because it uses PF.

---

# 3. Architecture and conventions

## Git repositories

Normal location:

```text
~/Development/
```

Example:

```text
~/Development/tembeek-rent-book
```

## Alias registry

Normal location:

```text
~/Sites/localhost/
```

Example:

```text
~/Sites/localhost/rentbook
```

This is a symlink to the actual web document root:

```text
~/Sites/localhost/rentbook
    -> ~/Development/tembeek-rent-book/public
```

## Hostname

```text
rentbook
    -> rentbook.localhost
```

With network forwarding:

```text
http://rentbook.localhost
```

Without it:

```text
http://rentbook.localhost:8080
```

## Project metadata

Committed, non-secret local-development contract:

```text
.tembeek/local.yaml
```

## Project secrets

Local-only:

```text
.env
```

`.env` must normally be Git-ignored.

---

# 4. Installation

From the unpacked `tembeek-local` directory:

```bash
chmod +x install.sh
./install.sh
```

The installer exposes:

```text
~/.local/bin/tembeek-local
```

If necessary add this to `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Reload:

```bash
source ~/.zshrc
```

Verify:

```bash
tembeek-local version
```

For this release:

```text
1.0.0
```

Help:

```bash
tembeek-local help
```

---

# 5. First-time workstation setup

Run these in order.

## Apache and PHP

```bash
tembeek-local setup apache
```

Homebrew formula installation performed by this command is intentionally non-interactive. `tembeek-local` uses Homebrew's `-y/--no-ask` behavior (and scopes `HOMEBREW_NO_ASK=1` to its own Homebrew invocation), so prompts such as:

```text
Do you want to proceed with the installation? [y/n]
```

do not stop workstation bootstrap.

This does **not** change your normal interactive Homebrew behavior outside `tembeek-local`.


This can:

- install Homebrew `httpd`;
- install `php@8.4`;
- configure `mpm_prefork`;
- enable `mod_rewrite`;
- enable `mod_vhost_alias`;
- wire PHP into Apache;
- create the alias root;
- configure wildcard `*.localhost`;
- enable `AllowOverride All`;
- validate Apache with `httpd -t`;
- roll back invalid Apache changes;
- start/restart Homebrew Apache.

## Port 80

```bash
tembeek-local setup network
```

This requires `sudo`.

It forwards loopback traffic:

```text
127.0.0.1:80 -> 127.0.0.1:8080
::1:80      -> ::1:8080
```

Apache itself remains on unprivileged port 8080.

## Verify the workstation

```bash
tembeek-local doctor
```

If this reports machine-level failures, fix them before onboarding applications.

---

# 6. Onboarding a PHP project

Assume:

```text
~/Development/tembeek-rent-book
```

Initialize:

```bash
tembeek-local init ~/Development/tembeek-rent-book --alias rentbook
```

The command attempts to:

1. verify it looks like PHP;
2. detect `public/` versus repository-root web root;
3. create `.tembeek/local.yaml` when absent;
4. create `.env` from `.env.example` when appropriate;
5. set `APP_ENV=local`;
6. set `APP_URL=http://rentbook.localhost`;
7. register `rentbook.localhost`.

Inspect:

```bash
tembeek-local info rentbook
```

Validate the project contract:

```bash
tembeek-local policy validate rentbook
```

If the app uses MySQL:

```bash
tembeek-local db create rentbook
tembeek-local db migrate rentbook
```

Then:

```bash
tembeek-local doctor rentbook
tembeek-local check all rentbook
```

Open:

```text
http://rentbook.localhost
```

---

# 7. Daily workflow

Useful routine commands:

```bash
tembeek-local list
tembeek-local info rentbook
tembeek-local doctor rentbook
tembeek-local db status rentbook
tembeek-local check all rentbook
```

For mature projects:

```bash
tembeek-local check all rentbook --strict-warnings
```

For automation:

```bash
tembeek-local check all rentbook --json
```

---

# 8. Local aliases and URLs

Add manually:

```bash
tembeek-local add rentbook ~/Development/tembeek-rent-book
```

List:

```bash
tembeek-local list
```

Resolve real path:

```bash
tembeek-local path rentbook
```

Show URL:

```bash
tembeek-local url rentbook
```

Remove alias:

```bash
tembeek-local remove rentbook
```

Removing an alias does **not** delete the Git repository or the database.

---

# 9. `.tembeek/local.yaml`

This file is the versioned project contract.

Current schema:

```yaml
schema_version: 1
```

Typical manifest:

```yaml
schema_version: 1

project: tembeek-rent-book
type: php
alias: rentbook
document_root: public

php_version: "8.4"
hosting_profile: shared-hosting
production_php_version: "8.4"

strict_warnings: false

required_extensions: [pdo_mysql, mbstring]
allowed_symlinks: []
allowed_process_dependencies: []
policy_exceptions: []

database_engine: mysql
database_name: tembeek_rentbook
database_user: tl_rentbook

migration_dir: migrations
migration_command: php bin/migrate.php
```

## Important fields

### `schema_version`

Manifest contract version.

```yaml
schema_version: 1
```

### `type`

Current supported value:

```yaml
type: php
```

### `alias`

Example:

```yaml
alias: rentbook
```

becomes:

```text
rentbook.localhost
```

Use lowercase letters, digits, and hyphens.

### `document_root`

Examples:

```yaml
document_root: .
```

or:

```yaml
document_root: public
```

### `production_php_version`

The compatibility target:

```yaml
production_php_version: "8.4"
```

### `strict_warnings`

```yaml
strict_warnings: false
```

Warnings are reported but do not fail readiness.

```yaml
strict_warnings: true
```

Warnings become failures.

### `required_extensions`

Example:

```yaml
required_extensions: [pdo_mysql, mbstring, intl]
```

### `allowed_symlinks`

Explicit project-relative allowlist:

```yaml
allowed_symlinks: [public/storage]
```

### `allowed_process_dependencies`

Example:

```yaml
allowed_process_dependencies: [shell_exec]
```

Use sparingly. Shared hosting may disable these functions.

### `policy_exceptions`

Example:

```yaml
policy_exceptions: [required_extensions]
```

Current check IDs include:

```text
php_version
required_extensions
case_collisions
absolute_paths
localhost_leakage
symlinks
process_dependencies
env_gitignore
database
```

An exception is a deliberate risk decision, not a convenient way to hide a problem.

---

# 10. `.env` and `.env.example`

## `.env.example`

Commit it. Do not put secrets in it.

Example:

```dotenv
APP_ENV=production
APP_URL=https://example.com

DB_HOST=
DB_PORT=3306
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=
```

## `.env`

Local and secret.

Typical local values:

```dotenv
APP_ENV=local
APP_URL=http://rentbook.localhost

DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=tembeek_rentbook
DB_USERNAME=tl_rentbook
DB_PASSWORD=<local-generated-password>
```

Add to `.gitignore`:

```gitignore
.env
```

---

# 11. MySQL and migrations

## Provision database

```bash
tembeek-local db create rentbook
```

The tool creates:

- the database;
- a project-specific DB user;
- privileges limited to that DB;
- a generated local password when needed.

Application credentials are written to `.env`.

## Admin connection defaults

```text
host: 127.0.0.1
port: 3306
user: root
```

If a password is required:

```bash
export TEMBEEK_MYSQL_ADMIN_PASSWORD='...'
```

Optional overrides:

```bash
export TEMBEEK_MYSQL_ADMIN_USER=root
export TEMBEEK_MYSQL_ADMIN_HOST=127.0.0.1
export TEMBEEK_MYSQL_ADMIN_PORT=3306
```

Do not store root/admin credentials in `.tembeek/local.yaml`.

## Run migrations

```bash
tembeek-local db migrate rentbook
```

Conventionally detected commands include:

```text
bin/migrate.php
    -> php bin/migrate.php
```

and:

```text
artisan
    -> php artisan migrate --force
```

For long-lived projects, explicitly declare the migration command in the manifest.

## Status

```bash
tembeek-local db status rentbook
```

The generic status checker understands common migration tables such as:

```text
schema_migrations
migrations
```

and columns such as:

```text
migration
version
filename
name
```

If it cannot safely infer a project's custom migration ledger, it reports that drift cannot be proven rather than guessing.

There is intentionally no generic destructive `db drop` or `db reset` command in v1.0.0.

---

## Readiness scan exclusions

Shared-hosting/readiness scans intentionally ignore generated dependency and environment trees. These are machine-local or reproducible artifacts and must not create portability failures.

Default excluded directory names include:

```text
.git
.venv
venv
node_modules
vendor
.idea
.vscode
.pytest_cache
.mypy_cache
.ruff_cache
__pycache__
coverage
dist
build
```

The exclusion applies recursively, so nested Python virtual environments such as:

```text
excel/.venv/
excel/tools/tembeek_excel_tools/.venv/
```

are ignored as well.

`bin/` is **not** ignored by default. It contains project-owned scripts, migrations, diagnostics, and operational tooling that can represent real deployment assumptions. If a future project genuinely needs repository-specific scan exclusions, those should be modeled explicitly in `.tembeek/local.yaml` rather than silently hiding all `bin/` code globally.


## Compatibility scan classification

The shared-hosting scanner distinguishes deployable source from generated/local-only material.

Ignored by default:

```text
.venv/
venv/
node_modules/
vendor/
storage/cache/
storage/backups/
build/
dist/
coverage/
*.env.local
.env.ui.local
```

Documentation files are still part of the repository, but absolute filesystem paths shown only as deployment examples are not treated as blocking developer-path leaks. Placeholder examples such as:

```text
/home/ACCOUNT/...
/home/USERNAME/...
/Users/USERNAME/...
```

are ignored by the blocker.

Localhost references in explicit development/test tooling (`tests/`, `bin/dev-*`, PHPUnit helpers, local env files) do not produce shared-hosting warnings. Production-facing config/source is still scanned.

Database API calls such as:

```php
$pdo->exec(...)
```

are not shell-process dependencies. Actual PHP process functions such as `exec()`, `shell_exec()`, and `proc_open()` remain visible.


# 12. Shared-hosting compatibility

Run:

```bash
tembeek-local check hosting rentbook
```

The checks are designed around common local-vs-shared-hosting failures.

Examples of blocking concerns:

- wrong PHP target;
- missing required extensions;
- Composer extension requirements;
- case-related filename collisions;
- hard-coded `/Users/...` or `/home/...` paths;
- runtime directories that are not writable.

Examples of warnings:

- hard-coded `localhost`;
- `127.0.0.1`;
- repository symlinks;
- shell/process execution;
- daemon assumptions;
- sensitive/internal files below web root;
- local-specific `.htaccess`;
- `.env` not clearly ignored.

Warnings are intentionally distinct from failures because some unusual behavior can be legitimate if explicitly reviewed.

---

# 13. Readiness and CI

Human-readable:

```bash
tembeek-local check all rentbook
```

Machine-readable:

```bash
tembeek-local check all rentbook --json
```

Example high-level JSON shape:

```json
{
  "tool": "tembeek-local",
  "version": "1.0.0",
  "scope": "all",
  "alias": "rentbook",
  "status": "pass",
  "strict_warnings": false,
  "failures": 0,
  "warnings": 1,
  "policy": {
    "strict_warnings_default": false,
    "production_php_version": "8.4"
  },
  "checks": {
    "hosting": [],
    "database": []
  }
}
```

Exit behavior:

```text
0 = pass
1 = blocking failure
```

Strict mode:

```bash
tembeek-local check all rentbook --strict-warnings
```

Temporary permissive override:

```bash
tembeek-local check all rentbook --no-strict-warnings
```

A GitHub Actions example is included under:

```text
examples/github-actions-shared-hosting.yml
```

---

# 14. Policy validation and migration

Validate:

```bash
tembeek-local policy validate rentbook
```

JSON:

```bash
tembeek-local policy validate rentbook --json
```

Validation checks include:

- supported schema version;
- unknown top-level keys;
- project type;
- alias format;
- document-root existence;
- PHP target format;
- strict-warning value;
- database engine;
- known `policy_exceptions` IDs.

Unknown keys are errors on purpose. A typo must not be silently ignored.

Legacy manifests can be migrated:

```bash
tembeek-local policy migrate rentbook
```

Migration:

1. creates a timestamped backup;
2. adds `schema_version: 1`;
3. adds missing policy defaults;
4. validates the result;
5. restores the original on failure.

Keep the backup until the migrated project has been verified.

---

## PHP runtime authority and Laravel Herd coexistence

`tembeek-local` treats the Homebrew PHP formula declared by `TEMBEEK_PHP_FORMULA` (default `php@8.4`) as its canonical PHP runtime.

This is deliberate. A developer may have another PHP distribution earlier on `PATH`, such as Laravel Herd:

```text
~/Library/Application Support/Herd/bin/php
```

That shell-level PHP may have a different patch version or different extensions from the PHP module loaded by Homebrew Apache. `tembeek-local` therefore resolves its own CLI checks through:

```text
brew --prefix php@8.4
```

and uses that formula's `bin/php` directly when available.

`doctor` still reports when the interactive shell resolves `php` to Herd or another runtime, but this no longer changes Tembeek's extension/version checks.

### Herd and `.localhost`

Laravel Herd can also own or intercept local development HTTP traffic. If:

```text
http://rentbook.localhost
```

returns a Herd-generated 404 while the Tembeek Apache backend works directly, check:

```bash
lsof -nP -iTCP:80 -sTCP:LISTEN
ps ax | grep -i herd
```

Tembeek-local expects its root-owned launchd/socat forwarder to own `127.0.0.1:80`, which then forwards to the persisted Homebrew Apache backend port.

`doctor` reports:

- Herd PHP on `PATH`;
- running Herd processes;
- whether the canonical `.localhost` response appears to come from Apache;
- conflicting listeners on port 80.

Do not assume that a successful DNS resolution of `*.localhost` proves the request is reaching Tembeek Apache.


## MySQL runtime detection

`doctor` does not require the unversioned Homebrew `mysql` formula.

A local MySQL-compatible runtime is considered present when any of the following is true:

- a `mysqld` or `mariadbd` process is running;
- TCP/3306 has a listener;
- a Homebrew MySQL/MariaDB service is started;
- a versioned formula such as `mysql@8.4` is installed;
- project database connectivity independently proves the runtime is reachable.

This prevents contradictory output where `db migrate` succeeds while machine doctor still warns that no database runtime exists.

# 15. Doctor

Machine:

```bash
tembeek-local doctor
```

Project:

```bash
tembeek-local doctor rentbook
```

The doctor covers areas including:

```text
Homebrew
Apache
Apache syntax
MPM
mod_rewrite
mod_vhost_alias
PHP
PDO MySQL
MySQL installation
alias registry
.htaccess execution
Apache-side PHP execution
network forwarding
project alias
.env
APP_ENV
APP_URL
manifest
database
migration configuration
policy
shared-hosting compatibility
HTTP reachability
```

When somebody reports “it does not work on my machine,” request this first:

```bash
tembeek-local doctor <alias>
```

---

# 16. Apache internals

Find Homebrew prefix:

```bash
brew --prefix
```

Common paths:

```text
Apple Silicon: /opt/homebrew
Intel:         /usr/local
```

Main config:

```text
$(brew --prefix)/etc/httpd/httpd.conf
```

Tembeek-managed Apache fragment:

```text
$(brew --prefix)/etc/httpd/extra/httpd-tembeek-local.conf
```

The configuration depends on:

```text
mpm_prefork
mod_php
mod_rewrite
mod_vhost_alias
AllowOverride All
VirtualDocumentRoot
*.localhost
```

Logs normally live under:

```text
$(brew --prefix)/var/log/httpd/
```

Relevant logs:

```text
tembeek-local-error.log
tembeek-local-access.log
```

For HTTP 500 errors, inspect the error log early.

---


## Apache listener convergence

Selecting a backend port is not enough: Apache must also have a global `Listen` directive for that port.

`setup apache` therefore now converges both:

```text
Listen 8081
<VirtualHost *:8081>
```

After restarting Homebrew Apache, the command verifies that an `httpd` process is actually listening on the selected backend port. If Apache fails to bind, setup stops and prints the active listeners and `Listen` directives.

`setup network` performs the same ownership preflight before asking for `sudo` or changing PF. It will not install a redirect to a dead Apache backend.

## Automatic backend-port selection

`tembeek-local` does **not** require Apache to own port 8080.

During:

```bash
tembeek-local setup apache
```

the CLI checks whether the configured backend port is already owned by another service. If, for example, Jenkins/Jetty is bound to `127.0.0.1:8080`, `tembeek-local` automatically searches upward for a free port such as `8081`.

As of v1.0.3, conflict detection continues automatically after reporting the conflicting listener rather than aborting during logging.

The selected backend port is persisted in:

```text
~/.config/tembeek-local/config
```

Example:

```text
HTTP_PORT=8081
```

Apache setup, PF forwarding, readiness probes, `doctor`, and URL generation all read the same machine-level value.

An explicit environment override still wins:

```bash
export TEMBEEK_HTTP_PORT=8090
```

This is useful when a developer intentionally wants a fixed backend port.

The browser-facing URL remains unchanged when PF forwarding is enabled:

```text
http://rentbook.localhost
```

Only the internal Apache backend changes, e.g.:

```text
127.0.0.1:80 -> 127.0.0.1:8081
```


## PF loopback processing

Tembeek's port-80 redirect is an `rdr` rule on macOS loopback (`lo0`). A PF option such as:

```pf
set skip on lo0
```

means PF does not process packets on that interface at all. In that state the Tembeek rule can load successfully but its packet counter stays at zero forever.

`tembeek-local setup network` now detects the exact standalone `set skip on lo0` directive. When found, it:

1. backs up `/etc/pf.conf` using the normal network backup path;
2. replaces the directive with:
   ```pf
   # TEMBEEK-LOCAL-DISABLED: set skip on lo0
   ```
3. installs and validates the Tembeek redirect rules;
4. loads PF only after the complete configuration validates;
5. performs the end-to-end port-80 probe.

`tembeek-local remove network` converts that Tembeek marker back to:

```pf
set skip on lo0
```

so the pre-Tembeek loopback policy is restored without replacing unrelated PF edits made later.

More complex `set skip` expressions are deliberately not rewritten automatically.


## Current network-forwarding architecture (v1.1+)

**v1.1.2 maintenance note:** PF is legacy-only, but its cleanup helpers remain required so upgrades from v1.0.x can remove old Tembeek PF state safely.

**v1.1.1 maintenance note:** the Apache listener helpers required by both setup paths were restored after the v1.1.0 refactor accidentally removed their definitions.

`tembeek-local` no longer uses PF as the primary localhost port-80 forwarding mechanism.

On current macOS versions, a syntactically valid `rdr on lo0` rule may load but never see locally generated localhost traffic. The observable symptom is:

```text
Evaluations: 0
Packets: 0
```

even while the backend service is healthy.

The v1.1 architecture therefore uses:

```text
browser
  -> 127.0.0.1:80
  -> root-owned launchd service
  -> socat
  -> 127.0.0.1:<Tembeek Apache backend port>
```

For example:

```text
rentbook.localhost:80
  -> launchd/socat
  -> 127.0.0.1:8081
  -> Homebrew Apache
```

`setup network` installs `socat` non-interactively when necessary and installs:

```text
/Library/LaunchDaemons/com.tembeek.local.http-forwarder.plist
/usr/local/libexec/tembeek-local-http-forwarder
```

The forwarder is root-owned because binding TCP port 80 requires elevated privilege. Apache itself remains an ordinary Homebrew user service on its unprivileged backend port.

If an older Tembeek PF configuration exists, `setup network` removes it before enabling the launchd forwarder so the two implementations cannot compete.

`remove network` removes the launchd forwarder and also cleans up legacy Tembeek PF configuration left by earlier releases.


# 17. Port-80 forwarding

Apache remains on:

```text
8080
```

`setup network` configures macOS PF.

Managed anchor:

```text
/etc/pf.anchors/com.tembeek.local
```

Main PF file:

```text
/etc/pf.conf
```

Remove only the Tembeek forwarding:

```bash
tembeek-local remove network
```

Applications can still be reached using `:8080` afterward.

---

# 18. Command reference

## General

```bash
tembeek-local help
tembeek-local version
```

## Setup

```bash
tembeek-local setup apache
tembeek-local setup network
tembeek-local remove network
```

## Project

```bash
tembeek-local init <project-path> [--alias <alias>]
tembeek-local add <alias> <project-path>
tembeek-local remove <alias>
tembeek-local list
tembeek-local path <alias>
tembeek-local url <alias>
tembeek-local info <alias>
```

## Database

```bash
tembeek-local db create <alias>
tembeek-local db migrate <alias>
tembeek-local db status <alias>
```

## Readiness

```bash
tembeek-local check hosting <alias>
tembeek-local check hosting <alias> --json
tembeek-local check all <alias>
tembeek-local check all <alias> --json
tembeek-local check all <alias> --strict-warnings
tembeek-local check all <alias> --no-strict-warnings
```

## Policy

```bash
tembeek-local policy validate <alias>
tembeek-local policy validate <alias> --json
tembeek-local policy migrate <alias>
```

## Diagnostics

```bash
tembeek-local doctor
tembeek-local doctor <alias>
```

---

# 19. Environment variables

## General

```text
TEMBEEK_LOCAL_ROOT
TEMBEEK_DEV_ROOT
TEMBEEK_HTTP_PORT
TEMBEEK_PHP_FORMULA
```

Defaults:

```text
TEMBEEK_LOCAL_ROOT = ~/Sites/localhost
TEMBEEK_DEV_ROOT   = ~/Development
TEMBEEK_HTTP_PORT  = 8080
TEMBEEK_PHP_FORMULA= php@8.4
```

## PF

```text
TEMBEEK_PF_CONF
TEMBEEK_PF_ANCHOR_NAME
TEMBEEK_PF_ANCHOR_FILE
```

Defaults:

```text
/etc/pf.conf
com.tembeek.local
/etc/pf.anchors/com.tembeek.local
```

## MySQL admin

```text
TEMBEEK_MYSQL_ADMIN_USER
TEMBEEK_MYSQL_ADMIN_HOST
TEMBEEK_MYSQL_ADMIN_PORT
TEMBEEK_MYSQL_ADMIN_PASSWORD
```

Defaults except password:

```text
root
127.0.0.1
3306
```

Never commit the admin password.

---

# 20. Troubleshooting

## Command not found

```bash
ls -l ~/.local/bin/tembeek-local
echo "$PATH"
```

Ensure:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## `.htaccess` ignored

```bash
tembeek-local doctor
httpd -M | grep rewrite
httpd -t
```

The end-to-end rewrite probe is more useful than merely seeing the module loaded.

## PHP source appears in browser

Run:

```bash
tembeek-local doctor
httpd -M | grep php
```

The current architecture expects Apache to execute PHP via its PHP module.

## Apache will not start

```bash
httpd -t
```

Then inspect:

```text
$(brew --prefix)/var/log/httpd/
```

## Another service already uses 8080

This is common with Jenkins/Jetty.

Check:

```bash
lsof -nP -iTCP:8080 -sTCP:LISTEN
```

If a non-Apache service owns the port, rerun:

```bash
tembeek-local setup apache
```

The CLI will select and persist a different Tembeek Apache backend port automatically.

## `.localhost` works on 8080 but not port 80

The Apache layer is working; the PF forwarding layer is likely not.

```bash
tembeek-local setup network
sudo -v
tembeek-local doctor
```

## Alias broken

```bash
tembeek-local list
tembeek-local path rentbook
```

Recreate if needed:

```bash
tembeek-local remove rentbook
tembeek-local add rentbook ~/Development/tembeek-rent-book
```

## MySQL provisioning fails

Check service:

```bash
brew services list
```

Test login:

```bash
mysql -u root
```

or:

```bash
mysql -u root -p
```

If needed:

```bash
export TEMBEEK_MYSQL_ADMIN_PASSWORD='...'
```

Then rerun `db create`.

## Manifest fails after CLI upgrade

```bash
tembeek-local policy validate rentbook
```

For a legacy schema:

```bash
tembeek-local policy migrate rentbook
```

Do not blindly change `schema_version`.

## Hard-coded `/Users/...` reported

Treat this as a real deployment problem unless there is a documented reason. Replace it with project-relative or environment-driven configuration.

## Process-dependency warning

Investigate code using:

```text
shell_exec
exec
system
passthru
proc_open
popen
pcntl_*
posix_*
```

Traditional shared hosting may disable these.

---

# 21. Recovery and rollback

## Apache

`setup apache` creates backups before changing configuration and validates with:

```bash
httpd -t
```

Invalid generated configuration is rolled back.

## PF

`setup network` backs up PF configuration and validates it before activation.

## Policy migration

Backups look similar to:

```text
.tembeek/local.yaml.pre-v1.<timestamp>.bak
```

## Aliases

Removing an alias removes only the symlink.

## Databases

No generic destructive reset/drop command exists in v1.0.0. This is deliberate.

---

# 22. Security rules

1. Never commit `.env`.
2. Never put MySQL root/admin credentials in `.tembeek/local.yaml`.
3. Treat `policy_exceptions` as reviewed risk decisions.
4. Do not suppress readiness failures without understanding them.
5. Passing `tembeek-local` does not replace production security review.
6. Shared-hosting compatibility is not the same as application security.

---

# 23. Repository conventions

A typical Tembeek PHP repository should resemble:

```text
tembeek-example/
├── .tembeek/
│   └── local.yaml
├── .env.example
├── .gitignore
├── composer.json
├── composer.lock
├── public/
│   ├── .htaccess
│   └── index.php
├── src/
├── migrations/
├── tests/
└── README.md
```

Key intent:

```text
local.yaml   -> committed non-secret local contract
.env.example -> committed configuration template
.env         -> ignored local secrets
public/      -> preferred document root where applicable
```

---

# 24. What the tool does not do

`tembeek-local` is not intended to replace:

- a PHP framework;
- Composer;
- Git;
- CI/CD;
- production deployment tooling;
- a secret manager;
- a production server manager;
- a database administration product;
- a vulnerability scanner.

Its job is local bootstrap, environment parity, and readiness validation.

Application behavior must remain inside each application repository.

---

# 25. New-machine checklist

```bash
./install.sh
tembeek-local version
tembeek-local setup apache
tembeek-local setup network
tembeek-local doctor
```

If needed:

```bash
brew services list
```

Expected local infrastructure commonly includes:

```text
httpd
mysql
```

---

# 26. New-project checklist

Assume:

```text
~/Development/tembeek-example
```

Run:

```bash
tembeek-local init ~/Development/tembeek-example --alias example
tembeek-local info example
tembeek-local policy validate example
```

For MySQL projects:

```bash
tembeek-local db create example
tembeek-local db migrate example
tembeek-local db status example
```

Then:

```bash
tembeek-local doctor example
tembeek-local check hosting example
tembeek-local check all example
```

For stricter release readiness:

```bash
tembeek-local check all example --strict-warnings
```

Open:

```text
http://example.localhost
```

---

# 27. Versioning

CLI version:

```bash
tembeek-local version
```

Current:

```text
1.0.0
```

Manifest version:

```yaml
schema_version: 1
```

These are separate version streams.

A future CLI version may continue supporting manifest schema 1.

When upgrading `tembeek-local`:

1. retain the previous release archive;
2. install the new release;
3. run machine doctor;
4. run `policy validate` for important projects;
5. run `check all` for important projects.

Do not mass-edit manifests simply because the CLI version changes.

---

# Quick start

New workstation:

```bash
./install.sh
tembeek-local setup apache
tembeek-local setup network
tembeek-local doctor
```

Newly cloned project:

```bash
tembeek-local init ~/Development/tembeek-rent-book --alias rentbook
tembeek-local policy validate rentbook
tembeek-local db create rentbook
tembeek-local db migrate rentbook
tembeek-local doctor rentbook
tembeek-local check all rentbook
```

Then open:

```text
http://rentbook.localhost
```

When something fails, start with:

```bash
tembeek-local doctor rentbook
```

Do not bypass a failing readiness check until its cause is understood.


## Local MySQL trigger/function migrations

MySQL may reject trigger or stored-function DDL with error 1419 when binary logging is enabled and the project account does not have elevated server privileges.

`tembeek-local` deliberately does not grant `SUPER` to application users. Before migrations it checks `@@GLOBAL.log_bin_trust_function_creators` through the configured MySQL admin connection and enables it for the local development server when necessary.

Production database policy remains separate from this local-development convenience.


## Database runtime warning precedence

From 1.2.5, `doctor <alias>` no longer emits the machine-level MySQL warning before the project database probe runs. For project-scoped doctor runs, successful application DB connectivity is authoritative. Machine-only `doctor` still warns when no compatible server/service/listener can be detected.


## Native database-runtime authority

`tembeek-local` treats the Homebrew MySQL/MariaDB stack as the native local database authority. External bundled runtimes such as MAMP are not reported as Tembeek-owned runtime state merely because a `mysqld` process exists.

The preferred baseline is a Homebrew service such as `mysql@8.4`, normally reachable on TCP 3306.

## PHP extension detection

Required PHP extensions are checked with `extension_loaded()` using the canonical Homebrew PHP binary selected by `active_php_bin`. This correctly handles built-in PHP extensions such as `json`, which may not be represented consistently by simplistic module-list parsing.


## Source portability classification

Shared-hosting portability checks distinguish runtime/deployable source from development infrastructure.

The localhost leakage check ignores:
- docs and tests;
- GitHub Actions service configuration;
- Playwright/PHPUnit configuration;
- local `.env` files, examples, and backups;
- explicit dev/test/local `bin` helpers;
- environment-overridable local defaults such as `$_ENV['DB_HOST'] ?? '127.0.0.1'`.

A localhost literal remains reportable when it is actually embedded in deployable runtime behavior without an environment override.

Process-control checks similarly ignore tests plus repository installer/fixer/dev tooling. Ordinary application/runtime `bin/*` scripts remain auditable, so a production CLI that genuinely invokes `exec`, `proc_open`, etc. is still surfaced.

## Canonical PHP extension authority

All manifest and Composer extension checks now use `php_extension_loaded`, which calls `extension_loaded()` on the canonical Homebrew PHP runtime returned by `active_php_bin`. Composer parsing also uses that same PHP binary. This removes shell-PHP/Homebrew-PHP races, including intermittent false `json` failures.


## Herd coexistence

Laravel Herd may remain installed and running. `tembeek-local doctor` does not warn merely because Herd processes exist. It warns only if the canonical Tembeek `.localhost` HTTP path is actually being served/intercepted by Herd.


## Herd interference detection

As of 1.2.9, Herd is considered interfering only when an actual Tembeek-critical listener is owned by Herd:

- TCP port 80; or
- the selected Tembeek Apache backend port.

Generic `Server: nginx` or `Server: caddy` headers are not treated as proof of Herd ownership.

The network doctor section heading is emitted once by the top-level doctor command.


## Dual-stack localhost forwarding

`*.localhost` may be reached through either IPv4 (`127.0.0.1`) or IPv6 (`::1`). The Tembeek port-80 forwarder therefore owns both loopback families and forwards both to the selected Homebrew Apache backend.

If Laravel Herd already owns port 80 on either family, `tembeek-local setup network` stops with an actionable conflict rather than installing a partially working forwarder. Stop Herd's web stack with:

```bash
herd stop
tembeek-local setup network
```

Herd can still be used later, but only one local web stack can own the same loopback port/address at a time.


## Machine database setup

Use:

```bash
tembeek-local setup database
```

`setup mysql` is an alias. The default native runtime is `mysql@8.4`, configurable with `TEMBEEK_MYSQL_FORMULA`.

The responsibility split is:

```text
setup database   -> machine MySQL runtime
db create        -> project database + user + .env credentials
db migrate       -> project schema
```

The setup command detects external runtimes such as MAMP but does not stop or adopt them; installs the configured Homebrew formula non-interactively if needed; starts it via `brew services`; verifies TCP 3306 and MySQL protocol reachability; and verifies `pdo_mysql` in the canonical Homebrew PHP runtime.


## Shared workstation aggregate setup

Apache/PHP, localhost forwarding, and the MySQL server are shared workstation infrastructure. They are not per-project resources.

Use:

```bash
tembeek-local setup workstation
```

Alias:

```bash
tembeek-local setup all
```

This is implemented inside the main CLI and reuses the existing setup functions:

```text
cmd_setup_apache
    ↓
cmd_setup_network
    ↓
cmd_setup_database
```

The individual commands remain available for targeted repair:

```bash
tembeek-local setup apache
tembeek-local setup network
tembeek-local setup database
```

Once a workstation is healthy, a new project does not need to repeat shared setup merely because it is a new shell session or repository.


## Configuration-driven project bootstrap

Shared workstation setup and project onboarding are separate concerns.

The machine-level project registry defaults to:

```text
~/.config/tembeek-local/projects.json
```

Example:

```json
{
  "projects": {
    "rentbook": {
      "path": "~/Development/tembeek-rent-book",
      "alias": "rentbook",
      "database": true,
      "migrate": true,
      "doctor": true
    }
  }
}
```

Registering through the CLI is preferred because it resolves and validates the path:

```bash
tembeek-local project register rentbook ~/Development/tembeek-rent-book rentbook
```

Then bootstrap with one command:

```bash
tembeek-local project setup rentbook
```

The default sequence is:

```text
init
  -> db create
  -> db migrate
  -> doctor
```

The JSON controls whether database creation, migration, or doctor run. The project's committed `.tembeek/local.yaml` remains authoritative for project policy, database names/users, migration command, PHP target, and shared-hosting rules. The machine JSON deliberately does not duplicate those settings.

Aliases:

```bash
tembeek-local project add <key> <path> [alias]
tembeek-local project bootstrap <key>
```

Use `tembeek-local project list` to see registered projects.


## Deregistering a project

Remove a project from the machine-level registry with:

```bash
tembeek-local project deregister <key>
```

Aliases:

```bash
tembeek-local project unregister <key>
tembeek-local project remove <key>
tembeek-local project rm <key>
```

Deregistration is deliberately non-destructive. It removes only the entry from:

```text
~/.config/tembeek-local/projects.json
```

It does **not** delete or alter:

- the repository;
- the `.localhost` alias symlink;
- the project database or database user;
- `.env`;
- `.tembeek/local.yaml`;
- migrations or other project files.

This makes it safe for correcting registration mistakes or decommissioning a project from `tembeek-local` management without destroying project state.


## Default local database naming

When a project does not explicitly configure `database_name`, `tembeek-local` derives the local development database name from the alias:

```text
<alias>_dev
```

Examples:

```text
rentbook     -> rentbook_dev
invoicing    -> invoicing_dev
hotel        -> hotel_dev
```

An explicit `database_name` in `.tembeek/local.yaml` always takes precedence.

This default is intentionally local-environment oriented and avoids duplicated product/company prefixes such as `tembeek_tembeek`.


## Trusted local HTTPS

Shared workstation setup now provisions trusted local HTTPS with `mkcert`.
Project setup reconciles `.env` to:

```dotenv
APP_ENV=local
APP_URL=https://<alias>.localhost
```

`.env` remains the generic runtime file because plain PHP projects do not universally
load `.env.local` or `.env-dev`. Framework-specific layered env files can be added later
through project policy.

The included `examples/tembeek.com.htaccess` keeps LOCAL and PROD canonicalization separate.


## Shell database semantics

A project may be structurally ready for migrations before it has any database-backed product feature.

In the machine project registry:

```json
{
  "database": false,
  "migrate": true
}
```

is interpreted as:

```text
migrate=true
    -> ensure a local database exists
    -> provision <alias>_dev when no explicit database_name exists
    -> run migrations when a migration command exists
    -> otherwise leave the empty/shell database ready
```

Therefore `migrate: true` implies a database target. `database: false` suppresses database provisioning only when `migrate` is also false.

This lets a new project start with a harmless local database shell and evolve into DB-backed functionality later without changing bootstrap conventions.


## Deterministic local TLS verification

`mkcert -install` trusts the local CA in the macOS trust store. Some `curl` builds use
their own CA bundle rather than macOS Keychain, so `tembeek-local` does not rely on that
implementation detail for its health probe.

TLS verification explicitly uses:

```text
$(mkcert -CAROOT)/rootCA.pem
```

with `curl --cacert`.

Workstation TLS setup also installs Homebrew `nss` before `mkcert -install`, allowing
mkcert to update Firefox/NSS trust stores when present.

Network setup checks exclusive ownership of both privileged ports 80 and 443 and emits
listener/backend/forwarder diagnostics when TLS forwarding cannot be verified.


## Local certificate reconciliation

Local TLS setup validates the existing certificate before reuse. The certificate must
contain SANs for:

```text
DNS:localhost
DNS:*.localhost
IP:127.0.0.1
IP:::1
```

If any required SAN is missing, `setup apache` regenerates the certificate with `mkcert`.
This prevents a trusted-but-hostname-invalid legacy certificate from surviving upgrades.

Network reconciliation also unloads the prior Tembeek launchd/socat forwarder before
checking/rebinding ports 80 and 443. The Tembeek forwarder error log is cleared at the
start of a deliberate reconciliation so failure diagnostics describe the current run.


## Apache-served certificate verification

A correct certificate file is not enough: Apache must actually serve that certificate.

`setup apache` now compares the SHA-256 fingerprint of the configured mkcert certificate
against the certificate returned by Apache on the dedicated HTTPS backend port using SNI.
If they differ, setup fails before network forwarding and prints:

- expected fingerprint;
- served fingerprint;
- served certificate SANs;
- `httpd -S` virtual-host mapping.

The Tembeek HTTPS vhost uses `_default_:<HTTPS_PORT>` because that backend port is reserved
for `tembeek-local`; this prevents unrelated/default SSL virtual hosts from silently
serving another certificate.


## Explicit project-host TLS SANs

Infrastructure TLS checks use the exact `localhost` SAN rather than a wildcard hostname.
The shared mkcert certificate also contains every registered project hostname explicitly,
for example `tembeek.localhost` and `rentbook.localhost`.

`project setup` reconciles the certificate if its alias is missing and restarts Apache.

Launchd bootstrap is now a hard gate: the generated plist is linted, installed root-owned,
and any bootstrap/kickstart failure stops setup before TLS probing.


## Hosting scanner and HTTPS local parity

The local canonical URL is HTTPS:

```text
https://<alias>.localhost
```

Hosting/doctor checks use that value and no longer warn when `.env` contains the HTTPS
local URL.

Portability scans treat generated/developer-only trees such as `.sites-runtime/`,
`.wrangler/`, npm caches, documentation-only README/TODO files, and placeholder
`*.example`/`CPANEL_USER` paths as non-deployable evidence.

Intentional `.htaccess` LOCAL host rules for `*.localhost` are also recognized as valid
environment separation rather than flagged as deployment leakage. Genuine deployable
source references to developer filesystem paths or localhost remain reportable.


## Scanner false-positive regression coverage

The scanner now uses the same canonical file walker for portability checks. Generated
runtime/dev trees `.sites-runtime/` and `.wrangler/` are pruned at traversal time rather
than filtered after grep output.

`APP_URL` validation reads the actual `.env` value and expects
`https://<alias>.localhost`.

Documentation files, placeholder cPanel examples, and the intentional `.htaccess`
`HTTP_HOST ... .localhost` LOCAL branch are excluded from deployable-source leakage
findings. Actual RewriteRules that redirect to localhost are still reportable.


## Root document-root protection

For projects that intentionally use the repository root as the web document root,
`tembeek-local` recognizes a marked defense-in-depth `.htaccess` block:

```text
# tembeek-local: internal-webroot-protection begin
...
# tembeek-local: internal-webroot-protection end
```

That block denies direct access to `.env`, `.git/`, `.tembeek/`, Composer metadata,
PHPUnit metadata, and selected internal state files. When present, the hosting scanner
reports those existing files as explicitly blocked instead of warning based only on
their presence under the document root.


## Semantic sensitive-file protection detection

Sensitive-file checks are no longer tied to a Tembeek marker block. The scanner inspects
the actual `.htaccess` protection semantics for each resource:

- `.env` / `.env.*`
- `.git/`
- `composer.json`
- `composer.lock`
- `phpunit.xml`
- `phpunit.xml.dist`

Equivalent `Files`/`FilesMatch` or `RewriteRule ... [F]` protection is recognized,
including pre-existing project rules that were not generated by `tembeek-local`.


## Daily workstation lifecycle

Provisioning and daily operation are separate:

```bash
# One-time, or after infrastructure changes
tembeek-local setup workstation

# Morning
tembeek-local up

# Check state
tembeek-local status

# End of day
tembeek-local down
```

`up` starts the already-provisioned Homebrew Apache service, the privileged launchd/socat
HTTP+HTTPS forwarder, and Homebrew MySQL when it is installed.

`down` stops those services without deleting or rewriting repositories, aliases, `.env`,
TLS certificates, databases, database users, migrations, manifests, or the project registry.

```text
setup workstation  = provision/reconcile
up                 = daily start
down               = daily stop
status             = current state
```


### Lifecycle privilege note

`tembeek-local up` and `tembeek-local down` may ask for the macOS administrator
password when they need to start or stop the root-owned launchd/socat forwarder on
ports 80 and 443. Apache and Homebrew MySQL themselves remain user-level Homebrew
services. `status` does not require privilege escalation.

MySQL lifecycle health is determined by a protocol probe on `127.0.0.1:3306`, not
merely by process-name inspection. An authentication rejection still proves the server
is alive.
