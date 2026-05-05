# Build JavaScript

Builds the `app/js/index.js` file into `app/static/js/app.min.js`. The
code is transformed and bundled using [Babel](https://babeljs.io) and
[webpack](https://webpack.js.org), so the latest JavaScript features can
be used (including ECMAScript 2015 aka ES6 and newer standards).
Requires Node.js to be available on the system.

## Usage

``` r
build_js(watch = FALSE)
```

## Arguments

- watch:

  Keep the process running and rebuilding JS whenever source files
  change.

## Value

None. This function is called for side effects.

## Details

Functions/objects defined in the global scope do not automatically
become `window` properties, so the following JS code:

    function sayHello() { alert('Hello!'); }

won't work as expected if used in R like this:

    tags$button("Hello!", onclick = 'sayHello()');

Instead you should explicitly export functions:

    export function sayHello() { alert('Hello!'); }

and access them via the global `App` object:

    tags$button("Hello!", onclick = "App.sayHello()")

## Examples

``` r
if (interactive()) {
  # Build the `app/js/index.js` file into `app/static/js/app.min.js`.
  build_js()
}
```
