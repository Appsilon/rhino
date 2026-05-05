# Build Sass

Builds the `app/styles/main.scss` file into
`app/static/css/app.min.css`.

## Usage

``` r
build_sass(watch = FALSE)
```

## Arguments

- watch:

  Keep the process running and rebuilding Sass whenever source files
  change. Only supported for `sass: node` configuration in `rhino.yml`.

## Value

None. This function is called for side effects.

## Details

The build method can be configured using the `sass` option in
`rhino.yml`:

1.  `node`: Use [Dart Sass](https://sass-lang.com/dart-sass) (requires
    Node.js to be available on the system).

2.  `r`: Use the `{sass}` R package.

It is recommended to use Dart Sass which is the primary, actively
developed implementation of Sass. On systems without Node.js you can use
the `{sass}` R package as a fallback. It is not advised however, as it
uses the deprecated
[LibSass](https://sass-lang.com/blog/libsass-is-deprecated)
implementation.

## Examples

``` r
if (interactive()) {
  # Build the `app/styles/main.scss` file into `app/static/css/app.min.css`.
  build_sass()
}
```
