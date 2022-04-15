# Contributing Guidelines
This document contains guidelines specific to Rhino. [Appsilon's general contributing
guidelines](https://github.com/Appsilon/.github/blob/main/CONTRIBUTING.md) still apply.

## Contributing to Rhino

Pull requests to Rhino are welcome! 

| Tool           | Command                  | `devtools` equivalent    | Comment
|----------------|--------------------------|--------------------------|-
| Unit tests     | `testthat::test_local()` | `devtools::test()`       |
| Linter         | `lintr::lint_package()`  | `devtools::lint()`       |
| `pkgdown` site | `pkgdown::build_site()`  | `devtools::build_site()` | If built successfully, the website will be in `docs` directory.


## Development Process
1. We follow [Scrum](https://scrumguides.org/).
2. All changes are introduced in pull requests, which must be peer-reviewed. The reviewer inspects
   the code, tests the changes and checks them against the [DoD](#definition-of-done) before
   approving.
3. The `develop` branch is the base for our regular work. It is set as the "default" branch on
   GitHub so that PRs automatically target it and `closes` keyword works in issue descriptions.
4. The `main` branch is used for releases. We regularly merge `develop` into `main`, increment the
   version number and tag a new release on GitHub.
5. We follow the [Semantic Versioning](https://semver.org/) scheme.


## Definition of Done
1. The PR has at least 1 approval and 0 change requests.
2. The CI passes (`R CMD check`, linter, unit tests).
3. The change is thoroughly documented.
