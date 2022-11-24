# Contributing guidelines

This document contains guidelines specific to Rhino.
[Appsilon's general contributing guidelines](https://github.com/Appsilon/.github/blob/main/CONTRIBUTING.md) still apply.

## Development tools

1. R CMD check<br>
`devtools::check()` or `rcmdcheck::rcmdcheck()`

2. Run linter<br>
`devtools::lint()` or `lintr::lint_package()`

3. Run unit tests<br>
`devtools::test()`or `testthat::test_local()`

4. Check spelling<br>
`devtools::spell_check()` or `spelling::spell_check_package()`

5. Build documentation<br>
`devtools::build_site()` or `pkgdown::build_site()`

6. Build package<br>
`devtools::build()` or `pkgbuild::build()`

## Development process

1. All changes are introduced in pull requests to the `main` branch,
which must be always kept in a "potentially shippable" state.
2. Pull requests must be peer-reviewed.
The reviewer inspects the code, tests the changes
and checks them against the [DoD](#definition-of-done) before approving.
3. We follow the [Semantic Versioning](https://semver.org/) scheme.
Starting with `1.0.0`, all versions should be released to CRAN.

## Definition of Done

1. The PR has at least 1 approval and 0 change requests.
2. The CI passes (`R CMD check`, linter, unit tests, spelling).
3. The change is thoroughly documented.
