# AGENTS.md

This file provides guidance to AI coding agents working in this repository.

## Project Overview

Rhino is a CRAN-published R package for building enterprise Shiny applications.
It standardizes Shiny app structure around `box` modules, integrates `renv`
dependency management, and provides R, JavaScript, Sass, Cypress, logging, and
project-scaffolding tooling.

## Repository Structure

- `R/`: package source. Public API is generated into `NAMESPACE` by roxygen2.
- `tests/testthat/`: package unit tests.
- `tests/e2e/`: end-to-end tests that install Rhino, scaffold a temporary app,
  and exercise generated-app workflows.
- `tests/e2e/app-files/`: fixture files copied into generated test apps.
- `inst/templates/`: templates copied by `rhino::init()`.
- `inst/rstudio/`: RStudio addins and project templates.
- `vignettes/`: pkgdown articles and user documentation sources.
- `man/`: generated `.Rd` files. Do not edit these directly.
- `docs/`: generated pkgdown site. Do not edit this directly.
- `pkgdown/`: versioned site build configuration and scripts.
- `data/` and `R/data.R`: packaged sample data and its documentation.

## Development Commands

Run one command per task. Prefer the command below unless you specifically need
the lower-level equivalent from `.github/CONTRIBUTING.md` or a workflow file.

| Task | Command |
| --- | --- |
| Run all unit tests | `devtools::test()` |
| Run a single test file | `testthat::test_file("tests/testthat/test-config.R")` |
| Lint package sources | `devtools::lint()` |
| Run R CMD check | `devtools::check()` |
| Spell check | `devtools::spell_check()` |
| Build documentation site | `devtools::build_site()` |
| Build package tarball | `devtools::build()` |

CI also runs package linting, unit tests, coverage, and spelling as separate
steps. Do not treat `devtools::check()` alone as the full CI surface when the
change affects lint, tests, spelling, coverage-sensitive behavior, generated app
behavior, or documentation.

For generated-app behavior, inspect `.github/workflows/e2e-test.yml` and the
scripts under `tests/e2e/`. The E2E workflow covers `init()`, `diagnostics()`,
dependency management, `RHINO_NPM`, R/JS/Sass linting and formatting, JS/Sass
builds, `test_r()`, `test_e2e()`, React support, and `box.lsp` setup.

## Code Style

- Line length limit is 100 characters, configured in `.lintr`.
- Linting excludes `inst/rstudio`, `inst/templates`, and `tests/e2e/app-files`.
- Exported R functions use snake_case, except the infix operator `%<-%`.
- Documentation uses roxygen2 with markdown enabled in `DESCRIPTION`.
- `testthat` uses edition 3 with parallel execution enabled in `DESCRIPTION`.
- Prefer package-local helper patterns over introducing new abstractions.
- Do not edit generated files directly: update roxygen comments, vignettes,
  pkgdown sources, or package metadata, then regenerate outputs.

## Architecture

The package exports 20 symbols in `NAMESPACE`:

- `%<-%`
- `app()`
- `auto_test_r()`
- `build_js()`
- `build_sass()`
- `devmode()`
- `diagnostics()`
- `format_js()`
- `format_r()`
- `format_sass()`
- `init()`
- `lint_js()`
- `lint_r()`
- `lint_sass()`
- `log`
- `pkg_install()`
- `pkg_remove()`
- `react_component()`
- `test_e2e()`
- `test_r()`

Core source files:

- `R/app.R`: `app()` entrypoint for Rhino apps. Configures `box`, static files,
  logging, and autoreload. Supports `legacy_entrypoint` migration modes.
- `R/tools.R`: developer tools for testing, linting, formatting, JS/Sass builds,
  E2E tests, automated R test watching, and development mode. Node-backed tools
  go through the `npm()` wrapper in `R/node.R`.
- `R/init.R`: `init()` scaffolding flow for new Rhino projects.
- `R/rhino.R`: shared template-copying helpers and `diagnostics()`.
- `R/dependencies.R`: `pkg_install()` and `pkg_remove()` management of `renv`
  packages and the `dependencies.R` file.
- `R/config.R`: reads and validates `rhino.yml`.
- `R/react.R`: `react_component()` wrapper for Shiny React components.
- `R/destructure.R`: `%<-%` destructuring operator.
- `R/log.R`: `log` object wrapping logger functions at seven severity levels.
- `R/addins.R`: RStudio addin entrypoints.
- `R/linters.R`: roxygen imports for packages used by generated Rhino apps.
- `R/data.R`: documentation for packaged sample data.

## Key Patterns

- Templates in `inst/templates/` use naming conventions: `dot.*` files become
  `.*` files, and `*.template` suffixes are stripped during scaffolding.
- Node.js tooling for generated apps is configured in `inst/templates/node/`.
  `RHINO_NPM` can select an alternative package manager such as `pnpm`, `yarn`,
  or `bun`.
- `build_sass()` supports `sass: node`, `sass: r`, and `sass: custom` settings
  from `rhino.yml`; watch mode is supported only for the Node path.
- `format_r()` and `lint_r()` integrate `box.linters`; enhanced `box::use()`
  styling depends on `treesitter` and `treesitter.r`.
- The generated app `.Rprofile` includes optional `box.lsp` language-server
  setup.
- The logging defaults are configured through generated `config.yml`, including
  `RHINO_LOG_LEVEL` and `RHINO_LOG_FILE`.
- GitHub workflows cover package CI, generated-app E2E behavior, app push tests,
  and pkgdown publication.

## Documentation And Release Notes

- Update `NEWS.md` for user-visible changes.
- Update or add vignettes for behavior that affects documented workflows.
- Keep release-process details in `.github/CONTRIBUTING.md`; do not duplicate
  the full release checklist here.
- Update this `AGENTS.md` file when changes make its agent guidance stale,
  especially when exported functions, important source files, repository
  structure, workflows, or development commands change.
- If adding repository-only docs or agent instructions, remember that R package
  builds may need corresponding `.Rbuildignore` entries.
