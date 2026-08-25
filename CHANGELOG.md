# Changelog

## 1.8.4
- Add a styled repository-level Makefile.
- Add `make test` as the default quality entry point for Bash syntax, smoke checks, and regression tests.
- Add focused targets: `shell-check`, `smoke`, `test-regression`, `test-all-tests`, `list-tests`, and `ci`.
- Auto-discover regression shell tests under `tests/`.
- Document the Make-based development workflow in README.


## 1.8.3
- Restore the pre-1.8.1 styled built-in help presentation.
- Merge project-root configuration and registry-recovery commands into the styled help instead of replacing the help function.
- Add styled recovery/defaults/environment sections for the new 1.8.x functionality.
- Add a regression gate that requires the styled help contract and the new commands to coexist.


## 1.8.2
- Add persistent project discovery roots to machine config (`PROJECT_ROOTS`).
- Add `project roots`, `project roots set`, `project roots add`, and `project roots remove`.
- Make discovery-root precedence explicit: `TEMBEEK_PROJECT_ROOTS` override → machine config → `TEMBEEK_DEV_ROOT`.
- Make `project discover` print every effective root before scanning.
- Update built-in help and README with persistent discovery-root configuration.
- Add regression coverage for persistence, precedence, help, and README synchronization.


## 1.8.1
- Add `project discover`, `project registry verify`, and `project registry rebuild` to built-in help.
- Replace the help surface with a complete command hierarchy covering lifecycle, setup, project registry, database, readiness, and policy commands.
- Reconcile README command reference with the executable help surface.
- Add a help/README synchronization regression gate for registry recovery and other high-value commands.


## 1.8.0
- Make `projects.json` recoverable from committed `.tembeek/local.yaml` manifests.
- Add `project discover`, `project registry verify`, and `project registry rebuild`.
- Automatically recover a missing registry when recoverable manifests exist.
- Seed `registry_key` and bootstrap recovery metadata during project registration.
- Rebuild atomically, deterministically, and with backup of an existing registry.
- Support colon-separated recovery roots through `TEMBEEK_PROJECT_ROOTS`.


## 1.7.2
- Fix lifecycle crash caused by calling `info` as a logger even though `info()` is the project-info command.
- Replace lifecycle informational messages with direct output.
- Add a regression preventing `cmd_up`, `cmd_down`, and `cmd_status` from reusing the `info` command name as a logging helper.


## 1.7.1
- Fix `up`, `down`, and `status` exiting silently because the main dispatcher shifted arguments twice.
- Use `homebrew_mysql_protocol_ready` for lifecycle MySQL health instead of the nonexistent `mysql_native_runtime_running` helper.
- Make the administrator-password prompt for the root-owned port 80/443 forwarder explicit.


## 1.7.0
- Add `tembeek-local up` for daily startup of Apache, HTTP/HTTPS forwarding, and provisioned MySQL.
- Add `tembeek-local down` for clean end-of-day shutdown without deleting local state.
- Add `tembeek-local status` for shared infrastructure state.
- Keep `setup workstation` reserved for provisioning/reconciliation.


## 1.6.13
- Fix `.env` protection detection using literal rewrite-rule recognition plus conservative Files/FilesMatch deny detection.
- Treat a `.git/` directory deny rewrite as protection for `.git/config`.
- Add a focused regression for the two remaining web-root warnings.


## 1.6.12
- Remove marker-only detection from sensitive web-root checks.
- Detect actual `.htaccess` protection semantics per internal file/directory.
- Recognize existing FilesMatch and RewriteRule denials for `.env`, `.git`, Composer, and PHPUnit metadata.
- Add a regression fixture matching the existing Tembeek `.htaccess` protection style.


## 1.6.11
- Make sensitive web-root checks protection-aware instead of presence-only.
- Recognize the marked Tembeek internal-webroot protection block in `.htaccess`.
- Report `.env`, `.git/config`, Composer metadata, and PHPUnit metadata as explicitly blocked when that policy is present.
- Add hardened root-document-layout `.htaccess` example and regression coverage.


## 1.6.10
- Fix the actual stale `APP_URL` doctor check to expect `https://<alias>.localhost`.
- Prune `.sites-runtime/` and `.wrangler/` in the canonical scan file walker.
- Exclude documentation and cPanel placeholder examples from deployable-path leakage.
- Recognize the intentional `.htaccess` LOCAL `HTTP_HOST .localhost` condition as portable.
- Align JSON and human hosting checks around the same scanner semantics.
- Add a scanner regression fixture covering the exact false positives seen on `tembeek`.


## 1.6.9
- Align APP_URL/doctor policy with canonical local HTTPS (`https://<alias>.localhost`).
- Ignore generated `.sites-runtime/` and `.wrangler/` trees in hosting portability scans.
- Ignore README/TODO documentation-only localhost examples and placeholder `CPANEL_USER`/`*.example` filesystem paths.
- Treat intentional `.htaccess` LOCAL `*.localhost` rules as valid environment separation, not deployment leakage.
- Preserve genuine blocking findings for deployable source and web-root exposure.


## 1.6.8
- Use exact `localhost` SAN for infrastructure TLS health probes.
- Add every registered `<alias>.localhost` explicitly to the mkcert certificate.
- Reconcile missing project-host SANs during `project setup`.
- Harden launchd bootstrap/bootout lifecycle and stop immediately on bootstrap errors.
- Validate launchd plist and set root ownership before bootstrap.


## 1.6.7
- Verify the TLS certificate actually served by Apache, not only the certificate file on disk.
- Compare configured and served SHA-256 certificate fingerprints using SNI.
- Make the Tembeek TLS vhost `_default_` on its dedicated HTTPS backend port.
- Fail `setup apache` early when Apache serves a different certificate.
- Add served SAN and `httpd -S` virtual-host diagnostics.


## 1.6.6
- Validate SANs on existing mkcert certificates before reusing them.
- Regenerate local TLS material when `*.localhost` or required loopback SANs are missing.
- Cleanly unload the previous Tembeek launchd/socat forwarder before rebinding ports 80/443.
- Clear historical forwarder error logs during deliberate network reconciliation.
- Show configured certificate SANs when a TLS probe fails.


## 1.6.5
- Fixed false local TLS verification failures caused by curl CA-store differences.
- TLS probes now explicitly trust mkcert's `rootCA.pem`.
- Added Homebrew `nss` installation before `mkcert -install` for Firefox/NSS trust.
- Added explicit TCP 443 ownership checks.
- Added detailed port-443, Apache HTTPS backend, mkcert CA, and launchd forwarder diagnostics.


## 1.6.4
- Made `migrate: true` imply that a local database must exist.
- Project bootstrap provisions the default `<alias>_dev` shell database when no explicit DB name exists.
- `db migrate` now succeeds cleanly when no migration command exists, reporting that the database shell is ready.
- `database: false` only suppresses DB creation when `migrate` is also false.


## 1.6.3
- Restored all remaining baseline core functions accidentally dropped during the 1.6.0 refactor, including `detect_migration_dir`, `detect_database_need`, and `cmd_info`.
- Expanded project-bootstrap dependency validation to cover transitive migration and doctor helpers.
- Added runtime smoke coverage for migration-directory and doctor helper availability.


## 1.6.2
- Restored `env_set` and any missing core bootstrap helpers lost during the 1.6.0 refactor.
- Added project-bootstrap dependency-closure validation, not just top-level command existence.
- `project setup` now verifies `cmd_init`, env helpers, DB commands, and doctor before running.


## 1.6.1
- Restored the `cmd_init` function accidentally removed during the 1.6.0 HTTPS/env refactor.
- Added internal function guards to `project setup` so missing orchestration commands fail immediately with an explicit internal error.
- Added regression validation for `cmd_init`, `cmd_db_create`, `cmd_db_migrate`, and `doctor` availability.


## 1.6.0
- Added trusted local HTTPS using Homebrew `mkcert`.
- Added Apache HTTPS backend on port 8443.
- Added local port 443 forwarding alongside port 80.
- Project setup now reconciles `APP_ENV=local` and `APP_URL=https://<alias>.localhost`.
- Project doctor now probes canonical HTTPS URLs.
- Added PROD/LOCAL-safe `tembeek.com` `.htaccess` example.


## 1.5.2
- Changed the default generated local database name to `<alias>_dev`.
- Explicit `database_name` in `.tembeek/local.yaml` still takes precedence.
- Avoids awkward duplicated defaults such as `tembeek_tembeek`.


## 1.5.1
- Added `project deregister <key>`.
- Added aliases: `project unregister`, `project remove`, and `project rm`.
- Deregistration removes only the machine-level `projects.json` entry.
- Repository, alias symlink, database, credentials, and project files remain untouched.


## 1.5.0
- Added machine-level `projects.json` registry.
- Added `project register` / `project add`.
- Added one-command `project setup` / `project bootstrap`.
- Added `project list`.
- Default project bootstrap sequence is `init -> db create -> db migrate -> doctor`.
- Registry stores only machine mapping/orchestration; `.tembeek/local.yaml` remains authoritative for project policy and DB/migration details.
- Added `TEMBEEK_PROJECTS_FILE` override and `config/projects.example.json`.


## 1.4.1
- Added `tembeek-local setup workstation`.
- Added `tembeek-local setup all` alias.
- Aggregate setup reuses the existing Apache, network, and database setup functions.
- Kept individual setup commands for targeted repair/reconciliation.
- Updated help to distinguish shared workstation setup from per-project onboarding.


## 1.4.0
- Added `tembeek-local setup database` with `setup mysql` alias.
- Standardized native local DB setup on configurable Homebrew `mysql@8.4`.
- Added noninteractive install, `brew services` startup, TCP 3306/protocol checks, and canonical PHP `pdo_mysql` verification.
- External runtimes such as MAMP are detected and reported as unmanaged, not adopted.
- Preserved machine-runtime vs project DB/schema responsibility boundaries.


## 1.3.0
- Made the launchd/socat HTTP forwarder dual-stack: `127.0.0.1:80` and `[::1]:80`.
- Added separate IPv4 and IPv6 doctor probes.
- Added explicit Herd port-80 conflict detection before network installation.
- `setup network` no longer succeeds when only one loopback address family is usable.
- Provides `herd stop` remediation when Herd owns port 80.


## 1.2.9
- Fixed false Laravel Herd interception warnings caused by generic nginx/caddy response headers.
- Herd conflicts are now based on actual ownership of port 80 or the selected Apache backend listener.
- Removed duplicate `Network` heading from `doctor` output.
- Kept Herd silent when Tembeek launchd/socat and Apache own the intended networking path.


## 1.2.8
- Removed unconditional Laravel Herd process warnings.
- Herd may remain running without noise when it does not intercept Tembeek networking.
- Network doctor now warns only when the canonical `.localhost` HTTP path appears to be served by Herd.


## 1.2.7
- Removed the final legacy `php -m` required-extension checks.
- Composer extension parsing and manifest checks now use canonical Homebrew PHP exclusively.
- Fixed intermittent false `json` extension failures.
- Refined localhost leakage classification for docs, CI, browser-test config, local env/examples/backups, and environment-overridable config defaults.
- Refined process-control classification for tests and repository installer/fixer/dev tooling while keeping ordinary runtime `bin/*` auditable.


## 1.2.6
- Excluded MAMP and other external app-bundled `mysqld` processes from Tembeek-native runtime reporting.
- Runtime authority now prefers Homebrew MySQL/MariaDB services and conventional TCP 3306.
- Reworked PHP extension checks around `extension_loaded()` on the canonical Homebrew PHP binary.
- Fixed false `json` missing-extension reports on PHP 8.x.
- Kept `pdo_mysql` and manifest extension checks on the same canonical PHP runtime.


## 1.2.5
- Removed the stale unversioned `brew list --versions mysql` warning path from project-scoped doctor runs.
- `doctor <alias>` now defers MySQL runtime judgement to the project database probe.
- Successful project database connectivity is authoritative evidence that a compatible runtime is reachable.
- Machine-only `doctor` still warns when no MySQL/MariaDB runtime can be detected.
- PHP CLI version display now uses the same canonical Homebrew PHP binary as the actual checks.


## 1.2.4
- Fixed false `No local MySQL/MariaDB runtime detected` warnings after successful DB provisioning/migration.
- Detects running `mysqld`/`mariadbd` processes.
- Detects TCP/3306 listeners.
- Detects versioned Homebrew services/formulas such as `mysql@8.4`.
- Treats successful project DB connectivity as authoritative evidence that a compatible runtime is reachable.


## 1.2.3
- Added local MySQL trigger/function migration policy preflight.
- Enables `log_bin_trust_function_creators=1` through the configured admin account when required.
- Keeps project DB users least-privileged rather than granting `SUPER`.
- Runs the policy check during both `db create` and `db migrate`.


## 1.2.2
- Excluded `storage/backups/` from portability/readiness scans as generated operational state.
- Backup/rebuild reports may contain machine-specific paths without becoming source portability blockers.
- Kept the scripts that generate backups auditable.
- Unified PHP extension checks on the canonical Homebrew PHP binary selected by `active_php_bin`.
- Fixed false `pdo`/`json` missing-extension results caused by inconsistent PHP runtime selection.


## 1.2.1
- Doctor now accepts any detected MySQL-compatible runtime instead of requiring Homebrew's exact `mysql` formula.
- Detects MariaDB and live TCP/3306 database services.
- Excludes `storage/cache` and local-only env files from portability scanning.
- Documentation placeholder paths no longer become blocking developer-path findings.
- Localhost references in explicit dev/test tooling are ignored.
- Correctly distinguishes PDO `->exec()` database calls from PHP `exec()` shell execution.
- Keeps real production-source portability findings visible.


## 1.2.0
- Made Homebrew PHP the canonical PHP runtime for Tembeek-local checks instead of whichever `php` appears first on PATH.
- Detects and reports Laravel Herd PHP/runtime conflicts.
- Detects Herd processes in doctor output.
- Adds canonical `.localhost` server ownership diagnostics.
- Adds port-80 listener diagnostics before network setup.
- Documents Herd coexistence and why Herd can produce a 404 for Tembeek `.localhost` hosts.


## 1.1.3
- Excluded generated/dependency trees from shared-hosting and portability scans.
- `.venv`, `venv`, `node_modules`, `vendor`, caches, build output, and VCS/editor metadata no longer create false portability findings.
- Nested virtual environments are excluded recursively.
- Kept `bin/` auditable by default because it contains project-owned operational code.
- Restored the missing `doctor_network` helper.
- Added helper/runtime smoke checks for doctor and scan exclusion functions.


## 1.1.2
- Restored missing legacy PF cleanup helper `remove_pf_conf_lines`.
- Audited network setup/removal dependencies after the v1.1 refactor.
- Added runtime helper-existence checks for all critical network helpers.


## 1.1.1
- Restored `ensure_apache_listen_port`, accidentally removed during the v1.1.0 network refactor.
- Restored `apache_backend_is_listening`, also accidentally removed during that refactor.
- Added structural regression checks requiring both helpers to exist before Apache/network setup functions.


## 1.1.0
- Replaced PF as the primary localhost port-80 forwarding mechanism.
- `setup network` now installs a root-owned launchd + `socat` forwarder from 127.0.0.1:80 to the persisted Apache backend port.
- Installs `socat` non-interactively when missing.
- Removes legacy Tembeek PF rules before activating the launchd forwarder.
- `remove network` removes both the launchd forwarder and legacy Tembeek PF state.
- Adds launchd status/error diagnostics when port-80 forwarding fails.
- Keeps Apache running unprivileged as a normal Homebrew service.


## 1.0.5
- Detects the exact `set skip on lo0` PF option that prevents localhost redirects from ever matching.
- Temporarily marks that directive as Tembeek-disabled during network setup, after taking the normal PF backup.
- Restores `set skip on lo0` when `remove network` is run.
- `doctor` now explicitly reports loopback PF bypass.
- Reports PF redirect packet counters after successful forwarding.
- Does not auto-rewrite more complex PF skip expressions.


## 1.0.4
- Fixed automatic backend-port relocation updating the virtual host but not Apache's global `Listen` directive.
- `setup apache` now converges `Listen PORT` and `<VirtualHost *:PORT>` to the same persisted machine port.
- Verifies after restart that `httpd` actually owns the selected backend port.
- `setup network` now fails before `sudo`/PF mutation when the configured Apache backend is not listening.
- Direct backend HTTP status is no longer treated as authoritative; listener ownership plus the end-to-end `.localhost` probe are used instead.


## 1.0.3
- Fixed `setup apache` aborting with `info: command not found` after detecting a port conflict.
- Fixed the same undefined logger in network listener diagnostics.
- Added regression coverage for automatic 8080 -> 8081 backend-port selection.


## 1.0.2
- Added machine-level persistent HTTP backend configuration.
- Detects non-Apache port conflicts before Apache setup.
- Automatically selects the next free backend port.
- Persists the selected port under `~/.config/tembeek-local/config`.
- Apache, PF forwarding, doctor/probes and URLs now share the same backend-port source.
- Network probe failures now print backend listeners, direct curl diagnostics and PF anchor rules.
- Specifically avoids collisions such as Jenkins/Jetty on 127.0.0.1:8080.

## 1.0.1
- Made Homebrew formula installation non-interactive during setup.
- `brew install` now uses `-y/--no-ask`.
- Scopes `HOMEBREW_NO_ASK=1` and `HOMEBREW_NO_ENV_HINTS=1` to CLI-owned Homebrew invocations.
- Normal interactive Homebrew behavior outside `tembeek-local` is unchanged.

## 1.0.0
- Added manifest schema version 1.
- Added `policy validate` with JSON mode.
- Added unknown-key and invalid exception-ID detection.
- Added core type/value validation.
- Added `policy migrate` with backup/rollback.
