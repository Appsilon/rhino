# Contributing Guidelines

This document contains guidelines specific to Rhino. [Appsilon's general contributing
guidelines](https://github.com/Appsilon/.github/blob/main/CONTRIBUTING.md) still apply.

## Contributing to Rhino

Pull requests to Rhino are welcome!

| Tool           | Command                  | `devtools` equivalent    | Comment
|----------------|--------------------------|--------------------------|-
| Unit tests     | `testthat::test_local()` | `devtools::test()`       |
| Linter         | `lintr::lint_package()`  | `devtools::lint()`       |
| `pkgdown` site | `pkgdown::build_site()`  | `devtools::build_site()` | If built successfully, the website will be in `docs` directory. Requires `pkgdown` version >= 2.0.0.


## Development Process

1. All changes are introduced in pull requests to the `main` branch,
which must be always kept in a "potentially shippable" state.
2. Pull requests must be peer-reviewed.
The reviewer inspects the code, tests the changes
and checks them against the [DoD](#definition-of-done) before approving.
3. We follow the [Semantic Versioning](https://semver.org/) scheme.
Starting with `1.0.0`, all versions should be released to CRAN.

## Definition of Done

1. The PR has at least 1 approval and 0 change requests.
2. The CI passes (`R CMD check`, linter, unit tests).
3. The change is thoroughly documented.
