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

## App Push Test

Rhino comes with a CI setup out of the box.
On `rhino::init()` it creates a  `rhino-test.yml` file,
a GitHub Actions workflow which automatically runs all linters and tests
once the project is pushed to GitHub.

To test `rhino-test.yml` itself, we have the [`app-push-test.yml`](workflows/app-push-test.yml) workflow.
It initializes a fresh Rhino application and pushes it to the `bot/app-push-test` branch.
Then `rhino-test.yml` of this application runs and its results can be viewed
in the [list of workflow runs](https://github.com/Appsilon/rhino/actions/workflows/rhino-test.yml).

The App Push Test is triggered automatically on pushes to `main`
and can also be triggered manually for any branch via the
[Actions](https://github.com/Appsilon/rhino/actions/workflows/app-push-test.yml) tab.

The workflow requires a
[fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#fine-grained-personal-access-tokens)
with write access to code and workflows.
It should be saved as the `APP_PUSH_TEST_PAT`
[repository secret](https://github.com/Appsilon/rhino/settings/secrets/actions).

## Website

The [documentation site](https://appsilon.github.io/rhino/)
is built and deployed automatically by our [`pkgdown.yml`](workflows/pkgdown.yml) workflow.
This workflow is triggered when a
[release](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository)
is published, or a pre-release is changed to a release.
It is also possible to manually run it for a selected tag/branch
from the [Actions](https://github.com/Appsilon/rhino/actions/workflows/pkgdown.yml) tab.

## Release process

### Preparation

1. Announce the planned release on `#proj-rhino` (approximate date and scope).
2. Plan promotion (social media, blog post, ...).
Coordinate efforts with the marketing team.
3. Ensure that the [App Push Test](#app-push-test) passes
(the [latest run](https://github.com/Appsilon/rhino/actions/workflows/rhino-test.yml)
for the `main` branch should be green).
4. Upgrade [Rhino Showcase](https://github.com/Appsilon/rhino-showcase).
    1. Create a task to track progress.
    2. Test upgrade by installing Rhino from the current `main` branch.
    3. Continue the release process.
    The upgrade can be completed and the task closed once the package is accepted to CRAN.
5. Prepare the package for release.
    1. Create a `release-X.Y.Z` branch from `main`.
    2. Update `DESCRIPTION`.
        * Bump the package version according to [SemVer](https://semver.org/).
        Drop the development version (last component, e.g. `.9001`).
    3. Update `NEWS.md`.
        * Replace the `(development version)` with `X.Y.Z` in the header.
        Do not add a link to GitHub releases yet - the link won't work and will fail CRAN checks.
        * Edit the list of changes to make it useful and understandable for our users.
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
    4. Check "Set as a pre-release".
    5. Click "Publish release".
3. [Submit the package to CRAN](https://cran.r-project.org/submit.html).
    1. Use your own name and email.
    2. Click "Choose File" and select `rhino_X.Y.Z.tar.gz` from step 1.
    3. Click "Upload the package".
    4. Click "Submit package".
    5. Click the confirmation link sent to `opensource@appsilon.com`.
4. If CRAN reviewers ask for changes, implement them and return to step 1.
Use `rc.2`, `rc.3` and so on for subsequent submissions.

### Once accepted to CRAN

1. [Publish a new release](https://github.com/Appsilon/rhino/releases/new) on GitHub.
    1. Create a new `vX.Y.Z` tag on the `main` branch.
    2. Use the tag name for title.
    3. Fill in the description from `NEWS.md`.
    4. Check "Set as the latest release".
    5. Click "Publish release".
2. Prepare the package for further development.
    1. Add a development version `.9000` in `DESCRIPTION`.
    2. Add a `# rhino (development version)` header in `NEWS.md`.
    3. Link the `# rhino X.Y.Z` header to the GitHub release in `NEWS.md`.
3. Announce the release on `#proj-rhino`.

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
