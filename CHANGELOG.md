# Changelog

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
