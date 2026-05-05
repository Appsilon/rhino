# How-to: Write JavaScript code

This article is a stub. We are working to edit and expand it.

The `app/js/index.js` is the entrypoint for your JavaScript code.

To use functions defined in this file in R you must export them:

``` js
export function sayHello() { console.log('Hello!'); }
```

and use an `App.` prefix when referring to them in your R code.

``` r
tags$button(onclick = "App.sayHello()")
```
