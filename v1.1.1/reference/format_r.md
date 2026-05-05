# Format R

Uses the `{styler}` package to automatically format R sources.

## Usage

``` r
format_r(paths)
```

## Arguments

- paths:

  Character vector of files and directories to format.

## Value

None. This function is called for side effects.

## Details

The code is formatted according to the
[`styler::tidyverse_style`](https://styler.r-lib.org/reference/tidyverse_style.html)
guide with one adjustment: spacing around math operators is not modified
to avoid conflicts with
[`box::use()`](https://klmr.me/box/reference/use.html) statements.

## Examples

``` r
if (interactive()) {
  # Format a single file.
  format_r("app/main.R")

  # Format all files in a directory.
  format_r("app/view")
}
```
