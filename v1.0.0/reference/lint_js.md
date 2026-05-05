# Lint JavaScript

Runs [ESLint](https://eslint.org) on the JavaScript sources in the
`app/js` directory. Requires Node.js and the `yarn` command to be
available on the system.

## Usage

``` r
lint_js(fix = FALSE)
```

## Arguments

- fix:

  Automatically fix problems.

## Value

None. This function is called for side effects.

## Details

If your JS code uses global objects defined by other JS libraries or R
packages, you'll need to let the linter know or it will complain about
undefined objects. For example, the `{leaflet}` package defines a global
object `L`. To access it without raising linter errors, add
`/* global L */` comment in your JS code.

You don't need to define `Shiny` and `$` as these global variables are
defined by default.

If you find a particular ESLint error inapplicable to your code, you can
disable a specific rule for the next line of code with a comment like:

    // eslint-disable-next-line no-restricted-syntax

See the [ESLint
documentation](https://eslint.org/docs/user-guide/configuring/rules#using-configuration-comments-1)
for full details.

## Examples

``` r
if (interactive()) {
  # Lint the JavaScript sources in the `app/js` directory.
  lint_js()
}
```
