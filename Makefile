SHELL := /bin/bash
.DEFAULT_GOAL := help

CLI := bin/tembeek-local
README := README.md
TEST_DIR := tests

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin
CANONICAL_NAME := tembeek-local
SHORT_NAME := tl
INSTALL_MODE ?= 755

REGRESSION_TESTS := $(sort $(wildcard $(TEST_DIR)/*regression*.sh))
ALL_SHELL_TESTS := $(sort $(wildcard $(TEST_DIR)/*.sh))

.PHONY: help test ci shell-check smoke test-regression test-all-tests list-tests install install-check install-dry-run uninstall clean

help:
	@printf '\n\033[1mtembeek-local development targets\033[0m\n\n'
	@printf '\033[1mUSAGE\033[0m\n'
	@printf '  make <target>\n\n'
	@printf '\033[1mQUALITY\033[0m\n'
	@printf '  \033[36mtest\033[0m             Run shell checks, smoke checks, and all regression tests\n'
	@printf '  \033[36mci\033[0m               CI-style alias for make test\n'
	@printf '  \033[36mshell-check\033[0m      Validate Bash syntax for CLI and test scripts\n'
	@printf '  \033[36msmoke\033[0m            Run --version and --help smoke checks\n'
	@printf '  \033[36mtest-regression\033[0m  Run every tests/*regression*.sh script\n'
	@printf '  \033[36mtest-all-tests\033[0m   Run every executable-style shell test under tests/\n'
	@printf '  \033[36mlist-tests\033[0m       Show discovered shell tests\n'
	@printf '\n\033[1mINSTALLATION\033[0m\n'
	@printf '  \033[36minstall\033[0m          Install tembeek-local and short command tl\n'
	@printf '  \033[36muninstall\033[0m        Remove this checkout-compatible installation\n'
	@printf '  \033[36minstall-check\033[0m    Show install destination and tl collision status\n'
	@printf '  \033[36minstall-dry-run\033[0m  Show what make install would do\n'
	@printf '  Default: $(BINDIR)/tembeek-local and $(BINDIR)/tl -> tembeek-local\n'
	@printf '\n'

shell-check:
	@printf '\033[1m== Bash syntax ==\033[0m\n'
	@bash -n $(CLI)
	@printf '  ✓ %s\n' "$(CLI)"
	@set -e; \
	for test_file in $(ALL_SHELL_TESTS); do \
	  bash -n "$$test_file"; \
	  printf '  ✓ %s\n' "$$test_file"; \
	done

smoke:
	@printf '\033[1m== Smoke ==\033[0m\n'
	@$(CLI) --version >/dev/null
	@printf '  ✓ --version\n'
	@$(CLI) --help >/dev/null
	@printf '  ✓ --help\n'

test-regression:
	@printf '\033[1m== Regression tests ==\033[0m\n'
	@if [[ -z "$(REGRESSION_TESTS)" ]]; then \
	  printf '  ! No regression tests found\n'; \
	  exit 1; \
	fi
	@set -e; \
	for test_file in $(REGRESSION_TESTS); do \
	  printf '\n\033[36m→ %s\033[0m\n' "$$test_file"; \
	  case "$$(basename "$$test_file")" in \
	    help-style-regression-v1.8.3.sh|help-readme-sync-v1.8.1.sh|project-roots-config-v1.8.2.sh|node-project-proxy-regression-v1.9.0.sh|node-project-lifecycle-regression-v1.9.1.sh|install-regression-v1.9.2.sh|install-same-file-regression-v1.9.3.sh|help-color-regression-v1.9.4.sh|install-path-isolation-regression-v1.9.5.sh) \
	      bash "$$test_file" "$(CLI)" "$(README)" ;; \
	    *) \
	      bash "$$test_file" "$(CLI)" ;; \
	  esac; \
	done
	@printf '\n  ✓ All regression tests passed\n'

test-all-tests:
	@printf '\033[1m== All shell tests ==\033[0m\n'
	@if [[ -z "$(ALL_SHELL_TESTS)" ]]; then \
	  printf '  ! No shell tests found\n'; \
	  exit 1; \
	fi
	@set -e; \
	for test_file in $(ALL_SHELL_TESTS); do \
	  printf '\n\033[36m→ %s\033[0m\n' "$$test_file"; \
	  case "$$(basename "$$test_file")" in \
	    help-style-regression-v1.8.3.sh|help-readme-sync-v1.8.1.sh|project-roots-config-v1.8.2.sh|node-project-proxy-regression-v1.9.0.sh|node-project-lifecycle-regression-v1.9.1.sh|install-regression-v1.9.2.sh|install-same-file-regression-v1.9.3.sh|help-color-regression-v1.9.4.sh|install-path-isolation-regression-v1.9.5.sh) \
	      bash "$$test_file" "$(CLI)" "$(README)" ;; \
	    *) \
	      bash "$$test_file" "$(CLI)" ;; \
	  esac; \
	done

test: shell-check smoke test-regression
	@printf '\n\033[32m✓ make test PASS\033[0m\n'

ci: test

list-tests:
	@printf '\033[1mRegression tests\033[0m\n'
	@for test_file in $(REGRESSION_TESTS); do printf '  %s\n' "$$test_file"; done
	@printf '\n\033[1mAll shell tests\033[0m\n'
	@for test_file in $(ALL_SHELL_TESTS); do printf '  %s\n' "$$test_file"; done


install-check:
	@set -e; \
	target_short="$(BINDIR)/$(SHORT_NAME)"; \
	target_canonical="$(BINDIR)/$(CANONICAL_NAME)"; \
	printf '\033[1m== Install check ==\033[0m\n'; \
	printf '  Canonical: %s\n' "$$target_canonical"; \
	printf '  Short:     %s -> %s\n' "$$target_short" "$(CANONICAL_NAME)"; \
	if [[ -e "$$target_canonical" && "$(CURDIR)/$(CLI)" -ef "$$target_canonical" ]]; then \
	  printf '  ✓ Canonical source and destination are already the same file\n'; \
	fi; \
	if [[ -L "$$target_short" ]]; then \
	  target="$$(readlink "$$target_short")"; \
	  if [[ "$$target" == "$(CANONICAL_NAME)" || "$$target" == "$$target_canonical" ]]; then \
	    printf '  ✓ Destination tl already belongs to this installation\n'; \
	  else \
	    printf '  ! Collision at destination: %s -> %s\n' "$$target_short" "$$target"; \
	    exit 2; \
	  fi; \
	elif [[ -e "$$target_short" ]]; then \
	  printf '  ! Collision at destination: %s already exists\n' "$$target_short"; \
	  exit 2; \
	else \
	  printf '  ✓ Destination short command is available\n'; \
	fi; \
	if command -v "$(SHORT_NAME)" >/dev/null 2>&1; then \
	  resolved="$$(command -v "$(SHORT_NAME)")"; \
	  if [[ "$$resolved" != "$$target_short" ]]; then \
	    printf '  ! Note: PATH currently resolves `%s` to %s\n' "$(SHORT_NAME)" "$$resolved"; \
	    printf '    This does not block installation into %s.\n' "$(BINDIR)"; \
	  fi; \
	fi

install-dry-run:
	@$(MAKE) --no-print-directory install-check
	@printf '\nWould install:\n'
	@printf '  install -m %s %s %s/%s\n' "$(INSTALL_MODE)" "$(CLI)" "$(BINDIR)" "$(CANONICAL_NAME)"
	@printf '  ln -s %s %s/%s\n' "$(CANONICAL_NAME)" "$(BINDIR)" "$(SHORT_NAME)"

install:
	@set -e; \
	mkdir -p "$(BINDIR)"; \
	target_short="$(BINDIR)/$(SHORT_NAME)"; \
	target_canonical="$(BINDIR)/$(CANONICAL_NAME)"; \
	if [[ -L "$$target_short" ]]; then \
	  target="$$(readlink "$$target_short")"; \
	  if [[ "$$target" != "$(CANONICAL_NAME)" && "$$target" != "$$target_canonical" ]]; then \
	    printf '\033[31m✗ Refusing to overwrite unrelated tl at destination: %s -> %s\033[0m\n' "$$target_short" "$$target" >&2; \
	    exit 2; \
	  fi; \
	elif [[ -e "$$target_short" ]]; then \
	  printf '\033[31m✗ Refusing to overwrite unrelated tl at destination: %s\033[0m\n' "$$target_short" >&2; \
	  exit 2; \
	fi; \
	source_file="$(CURDIR)/$(CLI)"; \
	dest_file="$$target_canonical"; \
	if [[ -e "$$dest_file" && "$$source_file" -ef "$$dest_file" ]]; then \
	  chmod "$(INSTALL_MODE)" "$$dest_file"; \
	  printf '\033[32m✓ Canonical command already installed at %s\033[0m\n' "$$dest_file"; \
	else \
	  install -m "$(INSTALL_MODE)" "$(CLI)" "$$dest_file"; \
	  printf '\033[32m✓ Installed %s\033[0m\n' "$$dest_file"; \
	fi; \
	rm -f "$$target_short"; \
	ln -s "$(CANONICAL_NAME)" "$$target_short"; \
	printf '\033[32m✓ Installed short command: %s\033[0m\n' "$$target_short"; \
	if command -v "$(SHORT_NAME)" >/dev/null 2>&1; then \
	  resolved="$$(command -v "$(SHORT_NAME)")"; \
	  if [[ "$$resolved" != "$$target_short" ]]; then \
	    printf '\033[33m! PATH currently resolves `%s` to %s, not the new %s\033[0m\n' "$(SHORT_NAME)" "$$resolved" "$$target_short"; \
	  fi; \
	fi; \
	printf '\nTry:\n  tembeek-local --help\n  tl --help\n'

uninstall:
	@set -e; \
	short="$(BINDIR)/$(SHORT_NAME)"; \
	canonical="$(BINDIR)/$(CANONICAL_NAME)"; \
	if [[ -L "$$short" ]]; then \
	  target="$$(readlink "$$short")"; \
	  if [[ "$$target" == "$(CANONICAL_NAME)" || "$$target" == "$$canonical" ]]; then \
	    rm -f "$$short"; \
	    printf '✓ Removed %s\n' "$$short"; \
	  else \
	    printf '! Leaving unrelated symlink untouched: %s -> %s\n' "$$short" "$$target"; \
	  fi; \
	elif [[ -e "$$short" ]]; then \
	  printf '! Leaving unrelated file untouched: %s\n' "$$short"; \
	fi; \
	if [[ -f "$$canonical" ]]; then \
	  if cmp -s "$(CLI)" "$$canonical"; then \
	    rm -f "$$canonical"; \
	    printf '✓ Removed %s\n' "$$canonical"; \
	  else \
	    printf '! Installed %s differs from this checkout; leaving it untouched\n' "$$canonical"; \
	  fi; \
	fi

clean:
	@find . -name '.DS_Store' -delete
