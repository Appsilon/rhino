# Lint Sass

Runs [Stylelint](https://stylelint.io/) on the Sass sources in the
`app/styles` directory. Requires Node.js to be available on the system.

## Usage

``` r
lint_sass(fix = FALSE)
```

## Arguments

- fix:

  Automatically fix problems.

## Value

None. This function is called for side effects.

## Examples

``` r
if (interactive()) {
  # Lint the Sass sources in the `app/styles` directory.
  lint_sass()
}
```
