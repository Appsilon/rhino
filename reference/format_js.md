# Format JavaScript

Runs [prettier](https://prettier.io/) on JavaScript files in `app/js`
directory. Requires Node.js installed.

## Usage

``` r
format_js(fix = TRUE)
```

## Arguments

- fix:

  If `TRUE`, fixes formatting. If FALSE, reports formatting errors
  without fixing them.

## Value

None. This function is called for side effects.

## Details

You can prevent prettier from formatting a given chunk of your code by
adding a special comment:

    // prettier-ignore

Read more about [ignoring code](https://prettier.io/docs/en/ignore).
