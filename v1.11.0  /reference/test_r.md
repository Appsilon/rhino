# Run R unit tests

Uses the `{testhat}` package to run all unit tests in `tests/testthat`
directory.

## Usage

``` r
test_r(...)
```

## Arguments

- ...:

  Additional arguments passed to
  [`testthat::test_dir()`](https://testthat.r-lib.org/reference/test_dir.html).

## Value

None. This function is called for side effects.

## Examples

``` r
if (interactive()) {
  # Run all unit tests in the `tests/testthat` directory.
  test_r()
}
```
