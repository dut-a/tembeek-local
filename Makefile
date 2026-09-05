SHELL := /bin/bash
.DEFAULT_GOAL := help

CLI := bin/tembeek-local
README := README.md
TEST_DIR := tests

REGRESSION_TESTS := $(sort $(wildcard $(TEST_DIR)/*regression*.sh))
ALL_SHELL_TESTS := $(sort $(wildcard $(TEST_DIR)/*.sh))

.PHONY: help test ci shell-check smoke test-regression test-all-tests list-tests clean

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
	    help-style-regression-v1.8.3.sh|help-readme-sync-v1.8.1.sh|project-roots-config-v1.8.2.sh|node-project-proxy-regression-v1.9.0.sh) \
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
	    help-style-regression-v1.8.3.sh|help-readme-sync-v1.8.1.sh|project-roots-config-v1.8.2.sh|node-project-proxy-regression-v1.9.0.sh) \
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

clean:
	@find . -name '.DS_Store' -delete
