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

## Release process

1. Bump the package version in `DESCRIPTION` according to [SemVer](https://semver.org/).
Drop the development version (last component, e.g. `.9001`).
2. Update `NEWS.md`.
Create a new header for the release.
Edit the list of changes: reorder, reword, and add or remove details as appropriate.
See [keep a changelog](https://keepachangelog.com/) for some guidelines.
3. Submit the changes in a pull request titled "Release X.Y.Z".
Get it approved and merged.
4. [Publish a new pre-release](https://github.com/Appsilon/rhino/releases/new) on GitHub.
Create a new `vX.Y.Z-rc.1` tag on the `main` branch (`rc` stands for release candidate).
Use the same string for title, leave description blank.
5. Build the package with `devtools::build()`
and [submit it to CRAN](https://cran.r-project.org/submit.html).
Use your own name and email.
You will need access to `opensource@appsilon.com` to receive the confirmation link.
6. If CRAN reviewers ask for changes,
implement them and return to step 4
(use `rc.2`, `rc.3` and so on for subsequent submissions).
7. Once the package is accepted to CRAN,
[publish a new release](https://github.com/Appsilon/rhino/releases/new) on GitHub.
Create a new `vX.Y.Z` tag on the `main` branch.
Use the same string for title, fill the description from `NEWS.md`.
8. Announce the release on `#proj-rhino`.

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
