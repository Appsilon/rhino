# Display rhino test coverage results using a standalone report

Uses the `{covr}` package to produce unit test coverage reports. Uses
the `{testhat}` package to run all unit tests in `tests/testthat`
directory.

## Usage

``` r
covr_report(rhino_coverage = covr_r(), ...)
```

## Arguments

- rhino_coverage:

  a rhino coverage dataset, defaults to
  [`covr_r()`](https://appsilon.github.io/rhino/dev/reference/covr_r.md).

- ...:

  additional arguments to pass to
  [[`covr::report()`](http://covr.r-lib.org/reference/report.md)](https://covr.r-lib.org/reference/report.html)

## Value

None. This function is called for side effects.

## Examples

``` r
if (interactive()) {
  # Run a test coverage report on a rhino app
  covr_report()
}
```
