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

### Preparation

1. Announce the planned release on `#proj-rhino`
(approximate date and scope).
2. Bump the package version in `DESCRIPTION` according to [SemVer](https://semver.org/).
Drop the development version (last component, e.g. `.9001`).
3. Update `NEWS.md`.
    1. Replace the `(development version)` with `X.Y.Z` in the header.
    Do add a link to GitHub releases yet - the link won't work and will fail CRAN checks.
    2. Edit the list of changes to make it useful and understandable for our users.
    See [keep a changelog](https://keepachangelog.com/) for some guidelines.
4. Submit the changes in a pull request titled "Release X.Y.Z".
Get it approved and merged.

### Submitting to CRAN

1. Build and test the package.
    1. Checkout the `main` branch and ensure it is up to date.
    2. Build the package with `devtools::build()`.
    3. Test the package with `R CMD check --as-cran rhino_X.Y.Z.tar.gz`.
    There should be no errors, warnings nor notes.
2. [Publish a new pre-release](https://github.com/Appsilon/rhino/releases/new) on GitHub.
    1. Create a new `vX.Y.Z-rc.1` tag on the `main` branch (`rc` stands for release candidate).
    2. Use the tag name for title.
    3. Leave description blank.
3. [Submit the package to CRAN](https://cran.r-project.org/submit.html).
    1. Use your own name and email.
    2. Click the confirmation link sent to `opensource@appsilon.com`.
4. If CRAN reviewers ask for changes,
implement them and return to step 1.
Use `rc.2`, `rc.3` and so on for subsequent submissions.

### Once accepted to CRAN

1. [Publish a new release](https://github.com/Appsilon/rhino/releases/new) on GitHub.
    1. Create a new `vX.Y.Z` tag on the `main` branch.
    2. Use the tag name for title.
    3. Fill in the description from `NEWS.md`.
2. Prepare the package for further development.
    1. Add a development version `.9000` in `DESCRIPTION`.
    2. Add a `# rhino (development version)` header in `NEWS.md`.
    3. Link the `# rhino X.Y.Z` header to the GitHub release in `NEWS.md`.
3. Create a task to upgrade [Rhino Showcase](https://github.com/Appsilon/rhino-showcase).
4. Announce the release on `#proj-rhino`.
5. Plan promotion (social media, blog post, ...).

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
