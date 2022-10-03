# vim:tw=0:ts=2:sw=2:noet:ft=make:

# This file exists within 'easy-as-pypi-appdirs':
#
#   https://github.com/doblabs/easy-as-pypi-appdirs#🛣

# -----------------------------------------------------------------------

PROJNAME = easy_as_pypi_appdirs

BASENAME_LINT = poetry-shell-lint

DOCS_BUILDDIR = _build

PYTHON_VERS = 3.10

# -----------------------------------------------------------------------

# DEV: Set BROWSER environ to pick your browser, otherwise webbrowser ignores
# the system default and goes through its list, which starts with 'mozilla'.
# E.g.,
#
#   BROWSER=chromium-browser make view-coverage
#
# Alternatively, one could be less distro-friendly and leverage sensible-utils, e.g.,
#
#   PYBROWSER := sensible-browser
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT
# NOTE: Cannot name BROWSER, else overrides environ of same name.
PYBROWSER := python -c "$$BROWSER_PYSCRIPT"

# -----------------------------------------------------------------------

# YOU/DEV: If you want to define your own tasks, add your own Makefile.
# You could e.g., define a help task extension thusly:
#
#   $ echo -e "help-local::\n\t@echo 'More help!'" > Makefile.local

-include Makefile.local

# -----------------------------------------------------------------------

# DEV: Friendly reminder: Comments within rules are printed to the console
# (and to GitHub Actions log).
# - So best to keep comments at file-level.

# -----------------------------------------------------------------------

help: help-main help-local
.PHONY: help

help-local::
.PHONY: help-local

# FIXME/2022-10-03 00:46: Update the help list:

help-main:
	@echo "Please choose a target for make:"
	@echo
	@echo " Installing and Packaging"
	@echo " ------------------------"
	@echo "   install           install the package to the active Python's site-packages"
	@echo "   develop           install (or update) all packages required for development"
	@echo "   dist              package"
	@echo "   release           package and upload a release"
	@echo
	@echo " Developing and Testing"
	@echo " ----------------------"
	@echo "   clean             remove all build, test, coverage and Python artifacts"
	@echo "   clean-build       remove build artifacts"
	@echo "   clean-docs        remove docs from the build"
	@echo "   clean-pyc         remove Python file artifacts"
	@echo "   clean-test        remove test and coverage artifacts"
	@echo "   cloc              display results of \"count lines of code\""
	@echo "   coverage          check code coverage quickly with the default Python"
	@echo "   coverage-html     generate HTML coverage reference for every source file"
	@echo "   develop           install packages in the current Poetry shell"
	@echo "   dist-check        check dist"
	@echo "   docs              generate Sphinx HTML documentation, including API docs"
	@echo "   help              print helpful list of commands (this list)"
	@echo "   isort             run isort; sorts and groups imports in every module"
	@echo "   linkcheck         check docs links"
	@echo "   lint              check style with flake8"
	@echo "   manifest-check    check manifest"
	@echo "   pydocstyle-check  check PEP 257 Docstring conventions"
	@echo "   test              run tests quickly with the default Python"
	@echo "   test-all          run tests on every Python version with tox"
	@echo "   test-one          run tests until the first one fails"
	@echo "   view-coverage     open coverage docs in new tab (set BROWSER to specify app)"
	@echo "   whoami            print the project name"
.PHONY: help-main

whoami:
	@echo $(PROJNAME)
.PHONY: whoami

# -----------------------------------------------------------------------

not-github-actions:
	@if [ -n "${GITHUB_ACTION}" ]; then \
		>&2 echo "ERROR: Do not call this Makefile from GitHub Actions."; \
		exit 1; \
	fi
.PHONY: not-github-actions

# Ideally, if the dev hasn't poetry-install'ed yet, make commands herein
# will fail because the tool is missing. But not always, e.g., if the user
# happened to install `twine` globally (say, to ~/.local/bin). So here we
# do our best to ensure that the tools we expect to run will be run.
# - See also: VIRTUAL_ENV and POETRY_ACTIVE environs.
virtualenv-exists:
	@if [ -z "$$(poetry env list)" ]; then \
		>&2 echo "ERROR: You must setup the Poetry virtual environment first."; \
		>&2 echo "- Hint: Try running \`make develop\`."; \
		exit 1; \
	fi
.PHONY: virtualenv-exists

no-virtualenv:
	@if [ -n "${VIRTUAL_ENV}" ] || [ -n "${POETRY_ACTIVE}" ]; then \
		>&2 echo "ERROR: A virtual environment or poetry shell is already activated."; \
		exit 1; \
	fi
.PHONY: no-virtualenv

# -----------------------------------------------------------------------

# Note that you can `poetry install` without being in a Poetry shell.

# - CPYST: To see the list of available Python versions, try:
#     pyenv install -l
#     pyenv install -l | grep '^ \+3\.'
#	- Note the `tail` assumes that the version list is sorted correctly,
#	  e.g., 3.x.9 is sorted before 3.x.10.
#	  - Otherwise we could print the PATCH number first and `sort -n`,
#	    but that's some spectacular magic:
#	      sed 's/^ \+\([0-9]\+\.[0-9]\+\.\([0-9]\+\)\)/\2 \1/'
#	- HINT: Try `pyenv versions` to see what you've got installed.
#
#	LATER/2022-10-03: Note that we pin 3.11.0rc1, because how `tox.ini` is wired.
#	- If I knew of a solution that didn't pin, I'd use it, but this was the
#	  first thing I figured out in the five minutes of diagnosing the issue.
#	- But also a good thing. Release candidates are allowed to break things,
#	  so it's not a bad idea to manually manage this version.
pyenv:
	@pyenv install --skip-existing $$(pyenv install -l | grep '^ \+3\.7\.' | tail -1)
	@pyenv install --skip-existing $$(pyenv install -l | grep '^ \+3\.8\.' | tail -1)
	@pyenv install --skip-existing $$(pyenv install -l | grep '^ \+3\.9\.' | tail -1)
	@pyenv install --skip-existing $$(pyenv install -l | grep '^ \+3\.10\.' | tail -1)
	@pyenv install --skip-existing 3.11.0rc1
.PHONY: pyenv

install:
	@poetry install --only main
.PHONY: install

# Note that you don't want to `poetry install` from inside Poetry shell.
# Otherwise pseudo subproject will use the same virtual environment.
# - And then you might see weird dependency version switching, e.g.,
#     Installing dependencies from lock file
#       • Updating docutils (0.19 -> 0.17.1)
#     Installing the current project: easy-as-pypi-appdirs (0.0.0.post57.dev0+fd430aa)
#     Installing dependencies from lock file
#       • Updating docutils (0.17.1 -> 0.19)
#     Installing the current project: poetry-shell-lint (0.0.0)
# - So we enforce `no-virtualenv` when running the `make develop` command.
# Note also the `cd .` so you (the DEV) see a visual separation between
# the two `po install` commands.
develop: no-virtualenv reset-virtualenv
	@echo
	cd . && poetry install --with dev,docs,test,extras
	@echo
	cd "$(BASENAME_LINT)" && poetry install
.PHONY: develop

# Determines the virtual environment name from `poetry env list` and
# removes the corresponding ~/.cache/pypoetry/virtualenvs/ directory.
clean-install: no-virtualenv
	@if [ -n "$$(poetry env list)" ]; then \
		poetry env remove "$$(poetry env list | grep -e ' (Activated)$$' | sed 's/ (Activated)$$//')"; \
	fi
	@if [ -n "$$(cd "$(BASENAME_LINT)" && poetry env list)" ]; then \
		cd "$(BASENAME_LINT)" && \
			poetry env remove "$$(poetry env list | grep -e ' (Activated)$$' | sed 's/ (Activated)$$//')"; \
	fi
.PHONY: clean-install

# Both Poetry and pyenv make it easy to switch Python versions, but they
# also both it easy to forget or nor realized when you're not using your
# normal development version.
# - This command ensures that you're using whatever version of Python
#   that you normally use when developing (and not, say, a version you
#   might have been temporarily using to debug some issue).
reset-virtualenv: no-virtualenv
	@poetry env use $(PYTHON_VERS)
	@cd "$(BASENAME_LINT)" && poetry env use $(PYTHON_VERS)
.PHONY: reset-virtualenv

reset: reset-virtualenv
.PHONY: reset

# -----------------------------------------------------------------------

# The following `make clean[-*]` tasks are only used by `make dist-build`.

clean: clean-build clean-pyc clean-test
.PHONY: clean

clean-build:
	@echo "clean-build"
	@/bin/rm -fr build/
	@/bin/rm -fr dist/
	@/bin/rm -fr .eggs/
	@find . -name '*.egg-info' -exec /bin/rm -fr {} +
	@find . -name '*.egg' -exec /bin/rm -f {} +
.PHONY: clean-build

clean-pyc:
	@echo "clean-pyc"
	@find . -name '*.pyc' -exec /bin/rm -f {} +
	@find . -name '*.pyo' -exec /bin/rm -f {} +
	@find . -name '*~' -exec /bin/rm -f {} +
	@find . -name '__pycache__' -exec /bin/rm -fr {} +
.PHONY: clean-pyc

# Note that we don't remove the .tox/ directory.
# - For one, we don't want to clobber the .tox/ directory when called from
#   tox. Specifically, `poetry run tox -e check_all` calls `make check-dist`.
# - But also, setting up each tox environment takes time. So leave it be.
clean-test:
	@echo "clean-test"
	@/bin/rm -f .coverage
	@/bin/rm -fr htmlcov/
	@/bin/rm -fr .pytest_cache/
.PHONY: clean-test

# -----------------------------------------------------------------------

# Checks the validity of the pyproject.toml file.
check-config: virtualenv-exists
	@poetry check
.PHONY: check-config

check-dist: virtualenv-exists dist-build
	@poetry run python -m twine check dist/*
.PHONY: check-dist

check-pydocstyle: virtualenv-exists
	@poetry run python -m pydocstyle $(PROJNAME)/ tests/
.PHONY: check-pydocstyle

# -----------------------------------------------------------------------

# This is not so elegant, I admit, but it's the best I've got.
# - There's a conflict between Sphinx dependencies and flake8 and doc8
#   dependencies, so we use a pseudo subproject to install those lint
#   tools into their own virtual environment. So we have to change to
#   the pseudo subproject directory and run poetry from there, to access
#   those tools.
# - Note that `make` executes each line in its own subshell, hence the
#   multiple `@cd` commands.
#   - Note also that `cd` itself is a Bash command, so we cannot run
#     `poetry run cd .. && ...` but must instead invoke Bash (`bash -c`).
# - The `poetry run` command loads the venv before running the command
#   -- which, phew!, is a blessing, because we cannot call `poetry shell`
#   from this Makefile (the `shell` command runs a new interactive shell
#   and blocks until you `exit` from it, so you can cannot do, e.g.,
#   `poetry shell && echo HI` and except the echo to happen from within
#   the new shell, because the echo won't happen until you exit the shell).
# - Finally, unset the VIRTUAL_ENV variable so that `poetry run` doesn't
#   not run if called from within a virtual environment. (I didn't read
#   any documentation on if this is okay to do, and I didn't check source,
#   so this is my own unsanctioned hack, and it could easily break in a
#   future Poetry release. -(lb))
#
# FIXME/2022-10-03: Demo `black --check {paths}`, maybe add to `lint` task.
lint: not-github-actions virtualenv-exists
	@cd "$(BASENAME_LINT)" && \
		bash -c "unset VIRTUAL_ENV ; poetry run -- bash -c 'cd .. && python -m flake8 setup.py $(PROJNAME)/ tests/'"
	@cd "$(BASENAME_LINT)" && \
		bash -c "unset VIRTUAL_ENV ; poetry run -- bash -c 'cd .. && python -m doc8'"
.PHONY: lint

# -----------------------------------------------------------------------

test: virtualenv-exists
	@poetry run python -m pytest $(TEST_ARGS) tests/
.PHONY: test

# - Note that if you ran `workon` (from deprecated virtualenvwrapper) earlier
#   in your shell, and then `deactivate`, $PYTHONPATH likely be set to a
#   virtualenv project path.
#   - So we unset PYTHONPATH to avoid the tox warning:
#       WARNING: Discarding $PYTHONPATH from environment, to override specify
#         PYTHONPATH in 'passenv' in your configuration.
#   - Otherwise, we could run a simpler command: `@poetry run python -m tox`.
# - Hint: To run a specific tox task (aka "environment"), which is helpful
#   when debugging tox, try, e.g.,:
#     poetry run python -m tox -e flake8
test-all: virtualenv-exists
	@poetry run -- bash -c 'PYTHONPATH= python -m tox'
.PHONY: test-all

tox: test-all
.PHONY: tox

test-debug: test-local quickfix
.PHONY: test-debug

#	To express the exit code of pytest, and not tee, use PIPESTATUS.
# - We use ${PIPESTATUS[0]} to use the exit code of `pytest`, and not `tee`
#   (because, by default, `pytest | tee` uses the exit code from tee (which
#   will always be 0)). (I also tried `set -o pipefail` within the task, but
#   that didn't work.) (Another option is to add `SHELL = /bin/bash -o pipefail`
#   outside the task (maybe also `export SHELL`), but using PIPESTATUS is more
#   readable -- anyone reading this code won't have to guess what the return
#   code might be.)
test-local: virtualenv-exists
	@poetry run python -m pytest $(TEST_ARGS) tests/ | tee .make.out
	exit ${PIPESTATUS[0]}
.PHONY: test-local

# Stops testing after the first failure.
# - Alternatively, you could run:
#   TEST_ARGS=-x make test
# - To keep debugging the same test, isolate it, e.g.,:
#   pytest --pdb -vv -k test_function tests/
test-one: virtualenv-exists
	@poetry run python -m pytest $(TEST_ARGS) -x tests/
.PHONY: test-one

# Prepares the .make.out output for Vim quickix.
# - The first substitute command:
#   Converts partial paths to full paths, so Vim quickfix can open.
# - The second substitute command:
#   Converts double-colons in messages (not file:line:s) -- at least
#   those that we can identify -- to avoid quickfix errorformat hits.
quickfix:
	sed -r "s#^([^ ]+:[0-9]+:)#$(shell pwd)/\1#" -i .make.out
	sed -r "s#^(.* .*):([0-9]+):#\1∷\2:#" -i .make.out
.PHONY: quickfix

# -----------------------------------------------------------------------

coverage: virtualenv-exists
	@poetry run python -m coverage run -m pytest $(TEST_ARGS) tests
	@poetry run python -m coverage report
.PHONY: coverage

coverage-to-html: coverage
	@poetry run python -m coverage html
.PHONY: coverage-to-html

coverage-html: coverage-to-html view-coverage
.PHONY: coverage-html

view-coverage:
	$(PYBROWSER) htmlcov/index.html
.PHONY: view-coverage

# -----------------------------------------------------------------------

clean-docs: clean-apidocs
	$(MAKE) -C docs clean BUILDDIR=$(DOCS_BUILDDIR)
.PHONY: clean-docs

clean-apidocs:
	/bin/rm -f docs/$(PROJNAME).*rst
	/bin/rm -f docs/modules.rst
.PHONY: clean-apidocs

docs: docs-html view-docs
.PHONY: docs

view-docs:
	$(PYBROWSER) docs/_build/html/index.html
.PHONY: view-docs

servedocs: virtualenv-exists docs
	@poetry run watchmedo shell-command -p "*.rst" -c "$(MAKE) -C docs html" -R -D .
.PHONY: servedocs

linkcheck: virtualenv-exists docs-html
	@poetry run $(MAKE) -C docs linkcheck
.PHONY: linkcheck

# - Note that `sphinx-apidoc` generates two files, docs/modules.rst and
#   docs/<package_name>.rst, the latter of which lists all the Submodule
#   names and the top-level package, and specifies `automodule` directives.
#   - To alter the generated HTML, add options to the `automodule` directives.
#   - The author was led to believe you could influence these options from
#     docs/conf.py, but I was not successful going that route.
#   - So instead, we can just inject changes after those files are created.
#   - If you want to change the generated HTML, and perhaps compare to the
#     default HTML to see what changes, you can tinker with docs-inject.
#     - Perhaps:
#         make docs-inject
#         mv docs/_build docs/_build-new
#         sensible-open docs/_build-new/html/index.html
#         make docs
#     - Currently, docs-inject only adds two options to the final package
#       `automodule`, but you could easily craft a `sed` or `awk` script
#       to achieve more advanced injection.
# - REFER: *PEP 257 - Docstring Conventions*:
#   https://www.python.org/dev/peps/pep-0257/

docs-html: virtualenv-exists clean-docs
	@poetry run sphinx-apidoc --force -o docs/ $(PROJNAME)
	@poetry run $(MAKE) -C docs clean
	@poetry run $(MAKE) -C docs html
.PHONY: docs-html

define INJECT_DOCS
   :special-members: __new__
   :noindex:
endef
export INJECT_DOCS
docs-inject: virtualenv-exists clean-docs
	@poetry run sphinx-apidoc --force -o docs/ $(PROJNAME)
	echo "$$INJECT_DOCS" >> docs/$(PROJNAME).rst
	@poetry run $(MAKE) -C docs clean
	@poetry run $(MAKE) -C docs html
.PHONY: docs-inject

# -----------------------------------------------------------------------

# - Interesting options:
#   -r/--repository pypi
#   -u/--username user
#   -p/--password pass
#   --cert
#   --client-cert
#   --dry-run
# MAYBE/2022-10-02 16:56: Should we also build in this step?
# - But what about uploading the build we tested? Hrmm.
#		release: clean
#			@poetry publish --build
#		.PHONY: release
release:
	@poetry publish
.PHONY: release

# Note that `poetry build` makes the virtualenv if it doesn't exist.
dist-build: clean
	@poetry build
.PHONY: dist-build

dist: dist-build
	@ls -l dist | tail -n -2
.PHONY: dist

# -----------------------------------------------------------------------

# BWARE/2022-10-02: This command untested lately.

CLOC := $(shell command -v cloc 2> /dev/null)
.PHONY: CLOC

cloc:
ifndef CLOC
	$(error "Please install cloc from: https://github.com/AlDanial/cloc")
endif
	@cloc --exclude-dir=build,dist,docs,$(PROJNAME).egg-info,.eggs,.git,htmlcov,.pytest_cache,.tox .
.PHONY: cloc

# -----------------------------------------------------------------------

# BWARE/2022-10-02: This command untested lately.

# STYLE: Note that isort chops blank lines from the ends of files.
# - We replace those blanks by going through all project files (via
#   `git-ls-files`) and echoing a newline to the ends of files.
# - This is obviously a style choice. The author likes to end files
#   with blank lines (and not just so Ctrl-end always puts the cursor
#   in the first column, and not some other column because the last
#   line is not blank).
isort: not-github-actions virtualenv-exists
	@poetry run python -m isort --recursive setup.py $(PROJNAME)/ tests/
	git ls-files | while read file; do \
		if [ -n "$$(tail -n1 $$file)" ]; then \
			echo "Blanking: $$file"; \
			echo >> $$file; \
		else \
			echo "DecentOk: $$file"; \
		fi \
	done
	@echo "ça va"
.PHONY: isort

isort-check: virtualenv-exists
	@poetry run python -m isort --check-only --recursive --verbose setup.py $(PROJNAME)/ tests/
.PHONY: isort-check

# -----------------------------------------------------------------------

