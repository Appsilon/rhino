# AGENTS.md

This file provides guidance to AI coding agents working in this
repository.

## Project Overview

Rhino is a CRAN-published R package for building enterprise Shiny
applications. It standardizes Shiny app structure around `box` modules,
integrates `renv` dependency management, and provides R, JavaScript,
Sass, Cypress, logging, and project-scaffolding tooling.

## Repository Structure

- `R/`: package source. Public API is generated into `NAMESPACE` by
  roxygen2.
- `tests/testthat/`: package unit tests.
- `tests/e2e/`: end-to-end tests that install Rhino, scaffold a
  temporary app, and exercise generated-app workflows.
- `tests/e2e/app-files/`: fixture files copied into generated test apps.
- `inst/templates/`: templates copied by
  [`rhino::init()`](https://appsilon.github.io/rhino/dev/reference/init.md).
- `inst/rstudio/`: RStudio addins and project templates.
- `vignettes/`: pkgdown articles and user documentation sources.
- `man/`: generated `.Rd` files. Do not edit these directly.
- `docs/`: generated pkgdown site. Do not edit this directly.
- `pkgdown/`: versioned site build configuration and scripts.
- `data/` and `R/data.R`: packaged sample data and its documentation.

## Development Commands

Run one command per task. Prefer the command below unless you
specifically need the lower-level equivalent from
`.github/CONTRIBUTING.md` or a workflow file.

| Task                                    | Command                                               |
|-----------------------------------------|-------------------------------------------------------|
| Run all unit tests                      | `devtools::test()`                                    |
| Run a single test file                  | `testthat::test_file("tests/testthat/test-config.R")` |
| Lint package sources                    | `devtools::lint()`                                    |
| Run R CMD check                         | `devtools::check()`                                   |
| Spell check                             | `devtools::spell_check()`                             |
| Regenerate `NAMESPACE` and `man/` files | `devtools::document()`                                |
| Build documentation site                | `devtools::build_site()`                              |
| Build package tarball                   | `devtools::build()`                                   |

CI also runs package linting, unit tests, coverage, and spelling as
separate steps. Do not treat `devtools::check()` alone as the full CI
surface when the change affects lint, tests, spelling,
coverage-sensitive behavior, generated app behavior, or documentation.

For generated-app behavior, inspect `.github/workflows/e2e-test.yml` and
the scripts under `tests/e2e/`. The E2E workflow covers
[`init()`](https://appsilon.github.io/rhino/dev/reference/init.md),
[`diagnostics()`](https://appsilon.github.io/rhino/dev/reference/diagnostics.md),
dependency management, `RHINO_NPM`, R/JS/Sass linting and formatting,
JS/Sass builds,
[`test_r()`](https://appsilon.github.io/rhino/dev/reference/test_r.md),
[`test_e2e()`](https://appsilon.github.io/rhino/dev/reference/test_e2e.md),
React support, and `box.lsp` setup.

## Testing Guidance

- Add or update tests for behavioral changes, especially bug fixes.
- Use `tests/testthat/` for package-level R behavior.
- Use `tests/e2e/` when changes affect
  [`rhino::init()`](https://appsilon.github.io/rhino/dev/reference/init.md)
  output, templates, generated app structure, Node tooling, JS/Sass
  commands, `RHINO_NPM`, `box.lsp` setup, or generated app test
  workflows.
- Template changes usually need generated-app validation, not only
  package unit tests.
- Keep test fixtures in `tests/e2e/app-files/` minimal and focused on
  the generated behavior being exercised.

## Code Style

- Line length limit is 100 characters, configured in `.lintr`.
- Linting excludes `inst/rstudio`, `inst/templates`, and
  `tests/e2e/app-files`.
- Exported R functions use snake_case, except the infix operator `%<-%`.
- Documentation uses roxygen2 with markdown enabled in `DESCRIPTION`.
- `testthat` uses edition 3 with parallel execution enabled in
  `DESCRIPTION`.
- Prefer package-local helper patterns over introducing new
  abstractions.
- Do not edit generated files directly: update roxygen comments,
  vignettes, pkgdown sources, or package metadata, then regenerate
  outputs.

## Dependencies And Imports

- Avoid adding package dependencies unless the dependency provides clear
  value and is appropriate for a CRAN package.
- Use explicit `pkg::function()` calls for dependencies. Do not add new
  broad roxygen `@import` directives.
- Keep `DESCRIPTION`, `NAMESPACE`, and package code in sync. Run
  `devtools::document()` after changing exported functions, roxygen
  documentation, or other `NAMESPACE`-affecting directives.
- `R/linters.R` contains a deliberate existing import workaround for
  packages used only by generated Rhino apps. Do not copy this pattern
  for normal code.
- Node dependencies for generated apps live in
  `inst/templates/node/package.json` and
  `inst/templates/node/package-lock.json`; update both together.
- Changes to generated app dependencies or scaffolding can affect
  `dependencies.R`, `renv`, template files, and E2E tests. Check the
  generated app path before finishing such changes.

## Architecture

The package exports 20 symbols in `NAMESPACE`:

- `%<-%`
- [`app()`](https://appsilon.github.io/rhino/dev/reference/app.md)
- [`auto_test_r()`](https://appsilon.github.io/rhino/dev/reference/auto_test_r.md)
- [`build_js()`](https://appsilon.github.io/rhino/dev/reference/build_js.md)
- [`build_sass()`](https://appsilon.github.io/rhino/dev/reference/build_sass.md)
- [`devmode()`](https://appsilon.github.io/rhino/dev/reference/devmode.md)
- [`diagnostics()`](https://appsilon.github.io/rhino/dev/reference/diagnostics.md)
- [`format_js()`](https://appsilon.github.io/rhino/dev/reference/format_js.md)
- [`format_r()`](https://appsilon.github.io/rhino/dev/reference/format_r.md)
- [`format_sass()`](https://appsilon.github.io/rhino/dev/reference/format_sass.md)
- [`init()`](https://appsilon.github.io/rhino/dev/reference/init.md)
- [`lint_js()`](https://appsilon.github.io/rhino/dev/reference/lint_js.md)
- [`lint_r()`](https://appsilon.github.io/rhino/dev/reference/lint_r.md)
- [`lint_sass()`](https://appsilon.github.io/rhino/dev/reference/lint_sass.md)
- `log`
- [`pkg_install()`](https://appsilon.github.io/rhino/dev/reference/dependencies.md)
- [`pkg_remove()`](https://appsilon.github.io/rhino/dev/reference/dependencies.md)
- [`react_component()`](https://appsilon.github.io/rhino/dev/reference/react_component.md)
- [`test_e2e()`](https://appsilon.github.io/rhino/dev/reference/test_e2e.md)
- [`test_r()`](https://appsilon.github.io/rhino/dev/reference/test_r.md)

Core source files:

- `R/app.R`:
  [`app()`](https://appsilon.github.io/rhino/dev/reference/app.md)
  entrypoint for Rhino apps. Configures `box`, static files, logging,
  and autoreload. Supports `legacy_entrypoint` migration modes.
- `R/tools.R`: developer tools for testing, linting, formatting, JS/Sass
  builds, E2E tests, automated R test watching, and development mode.
  Node-backed tools go through the `npm()` wrapper in `R/node.R`.
- `R/init.R`:
  [`init()`](https://appsilon.github.io/rhino/dev/reference/init.md)
  scaffolding flow for new Rhino projects.
- `R/rhino.R`: shared template-copying helpers and
  [`diagnostics()`](https://appsilon.github.io/rhino/dev/reference/diagnostics.md).
- `R/dependencies.R`:
  [`pkg_install()`](https://appsilon.github.io/rhino/dev/reference/dependencies.md)
  and
  [`pkg_remove()`](https://appsilon.github.io/rhino/dev/reference/dependencies.md)
  management of `renv` packages and the `dependencies.R` file.
- `R/config.R`: reads and validates `rhino.yml`.
- `R/react.R`:
  [`react_component()`](https://appsilon.github.io/rhino/dev/reference/react_component.md)
  wrapper for Shiny React components.
- `R/destructure.R`: `%<-%` destructuring operator.
- `R/log.R`: `log` object wrapping logger functions at seven severity
  levels.
- `R/addins.R`: RStudio addin entrypoints.
- `R/linters.R`: R CMD check workaround for packages used by generated
  Rhino apps.
- `R/data.R`: documentation for packaged sample data.

## Key Patterns

- Templates in `inst/templates/` use naming conventions: `dot.*` files
  become `.*` files, and `*.template` suffixes are stripped during
  scaffolding.
- Node.js tooling for generated apps is configured in
  `inst/templates/node/`. `RHINO_NPM` can select an alternative package
  manager such as `pnpm`, `yarn`, or `bun`.
- [`build_sass()`](https://appsilon.github.io/rhino/dev/reference/build_sass.md)
  supports `sass: node`, `sass: r`, and `sass: custom` settings from
  `rhino.yml`; watch mode is supported only for the Node path.
- [`format_r()`](https://appsilon.github.io/rhino/dev/reference/format_r.md)
  and
  [`lint_r()`](https://appsilon.github.io/rhino/dev/reference/lint_r.md)
  integrate `box.linters`; enhanced
  [`box::use()`](https://klmr.me/box/reference/use.html) styling depends
  on `treesitter` and `treesitter.r`.
- The generated app `.Rprofile` includes optional `box.lsp`
  language-server setup.
- The logging defaults are configured through generated `config.yml`,
  including `RHINO_LOG_LEVEL` and `RHINO_LOG_FILE`.
- GitHub workflows cover package CI, generated-app E2E behavior, app
  push tests, and pkgdown publication.

## Documentation And Release Notes

- Update `NEWS.md` for user-visible changes.
- Update or add vignettes for behavior that affects documented
  workflows.
- Run `devtools::document()` when roxygen comments, exports,
  `NAMESPACE`, or data documentation change.
- Keep release-process details in `.github/CONTRIBUTING.md`; do not
  duplicate the full release checklist here.
- For code changes, increment the development version in `DESCRIPTION`
  using the `X.Y.Z.900N` pattern.
- Do not switch to a release version unless you are following the
  release process in `.github/CONTRIBUTING.md`.
- Update this `AGENTS.md` file when changes make its agent guidance
  stale, especially when exported functions, important source files,
  repository structure, workflows, or development commands change.
- If adding repository-only docs or agent instructions, remember that R
  package builds may need corresponding `.Rbuildignore` entries.

## Security And Local State

- Do not commit secrets, tokens, credentials, or machine-specific local
  config.
- Use environment variables, `config.yml` placeholders, or GitHub
  repository secrets in examples and workflows.
- Avoid committing generated app credentials, real deployment settings,
  or local files produced while testing scaffolded Rhino apps.
