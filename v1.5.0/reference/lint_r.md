# Lint R

Uses the `{lintr}` package to check all R sources in the `app` and
`tests/testthat` directories for style errors.

## Usage

``` r
lint_r(paths = NULL)
```

## Arguments

- paths:

  Character vector of directories and files to lint. When `NULL` (the
  default), check `app` and `tests/testthat` directories.

## Value

None. This function is called for side effects.

## Details

The linter rules can be adjusted in the `.lintr` file.

You can set the maximum number of accepted style errors with the
`legacy_max_lint_r_errors` option in `rhino.yml`. This can be useful
when inheriting legacy code with multiple styling issues.
