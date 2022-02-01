# Rhino

<!-- badges: start -->
[![R build status](https://github.com/Appsilon/rhino/workflows/R-CMD-check/badge.svg)](https://github.com/Appsilon/rhino/actions)
<!-- badges: end -->

## Development Process
1. We follow [Scrum](https://scrumguides.org/).
2. All changes are introduced in pull requests, which must be peer-reviewed.
The reviewer inspects the code, tests the changes and checks them against the DoD before approving.
3. The `develop` branch is the base for our regular work.
It is set as the "default" branch on GitHub
so that PRs automatically target it and `closes` keyword works in issue descriptions.
4. The `main` branch is used for releases.
We regularly merge `develop` into `main`,
increment the version number and tag a new release on GitHub.
5. We follow the [Semantic Versioning](https://semver.org/) scheme.

### Definition of Done
1. The PR has at least 1 approval and 0 change requests.
2. The CI passes (`R CMD check`, linter, unit tests).
3. The change is thoroughly documented.
