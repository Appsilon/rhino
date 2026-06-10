# Run a unit test coverage check

Uses the `{covr}` package to produce unit test coverage reports. Uses
the `{testhat}` package to run all unit tests in `tests/testthat`
directory.

## Usage

``` r
covr_r(
  source_files = list.files("app", pattern = "\\.[rR]$", full.names = TRUE, recursive =
    TRUE),
  test_files = list.files("tests/testthat", pattern = "^test-.*\\.R", full.names =
    TRUE, recursive = TRUE),
  line_exclusions = NULL,
  function_exclusions = NULL
)
```

## Arguments

- source_files:

  Character vector of source files with function definitions to measure
  coverage. Defaults to all `.R` files in the `app` tree.

- test_files:

  Character vector of test files with code to test the functions.
  Defaults to all test files in `tests/testthat` with the
  `test-<name>.R` filename pattern.

- line_exclusions:

  passed to
  [`covr::file_coverage`](http://covr.r-lib.org/reference/file_coverage.md)

- function_exclusions:

  passed to
  [`covr::file_coverage`](http://covr.r-lib.org/reference/file_coverage.md)

## Value

A `covr` coverage dataset.

## Examples

``` r
if (interactive()) {
  # Run a test coverage check for the entire rhino app
  # using all tests in the `tests/testthat` directory.
  covr_r()
}
```
