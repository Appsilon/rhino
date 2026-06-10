# Add GitHub Actions CI

Adds the Rhino GitHub Actions CI workflow
(`.github/workflows/rhino-test.yml`) to a Rhino application.

## Usage

``` r
use_github_actions_ci()
```

## Value

None. This function is called for side effects.

## Details

This workflow is added automatically by
[`init()`](https://appsilon.github.io/rhino/reference/init.md) unless
`github_actions_ci = FALSE`. Use this function to add it to an existing
Rhino project.

If `.github/workflows/rhino-test.yml` already exists in an interactive
session, you will be prompted to either abort (the default) or back up
the existing file as `rhino-test.yml.bak` (with a numeric suffix if
`rhino-test.yml.bak` is also taken) and create a new one. In
non-interactive sessions the function aborts with an error.

## Examples

``` r
if (interactive()) {
  # Add the GitHub Actions CI workflow to the current Rhino project.
  use_github_actions_ci()
}
```
