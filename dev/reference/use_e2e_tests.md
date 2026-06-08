# Add end-to-end tests

Adds the Rhino Cypress end-to-end test structure to a Rhino application:
the `tests/cypress.config.js` file and the `tests/cypress/` directory.

## Usage

``` r
use_e2e_tests()
```

## Value

None. This function is called for side effects.

## Details

This structure is added automatically by
[`init()`](https://appsilon.github.io/rhino/dev/reference/init.md). Use
this function to add it to an existing Rhino project.

If `tests/cypress.config.js` or the `tests/cypress/` directory already
exist in an interactive session, you will be prompted to either abort
(the default) or back up the existing paths (each moved to a `.bak`
path) and create new ones. In non-interactive sessions the function
aborts with an error.

## Examples

``` r
if (interactive()) {
  # Add the end-to-end test structure to the current Rhino project.
  use_e2e_tests()
}
```
