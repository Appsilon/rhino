# Run Cypress end-to-end tests

Uses [Cypress](https://www.cypress.io/) to run end-to-end tests defined
in the `tests/cypress` directory. Requires Node.js to be available on
the system.

## Usage

``` r
test_e2e(interactive = FALSE)
```

## Arguments

- interactive:

  Should Cypress be run in the interactive mode?

## Value

None. This function is called for side effects.

## Details

Check out: [Tutorial: Write end-to-end tests with
Cypress](https://appsilon.github.io/rhino/articles/tutorial/write-end-to-end-tests-with-cypress.html)
to learn how to write end-to-end tests for your Rhino app.

If you want to write end-to-end tests with `{shinytest2}`, see our
[How-to: Use
shinytest2](https://appsilon.github.io/rhino/articles/how-to/use-shinytest2.html)
guide.

## Examples

``` r
if (interactive()) {
  # Run the end-to-end tests in the `tests/cypress` directory.
  test_e2e()
}
```
