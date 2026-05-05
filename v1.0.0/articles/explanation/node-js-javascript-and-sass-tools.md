# Explanation: Node.js - JavaScript and Sass tools

[Node.js](https://nodejs.org/en/about/) is a runtime environment which
can execute JavaScript code outside a web browser. It is used widely for
web development. Its package manager,
[npm](https://docs.npmjs.com/about-npm), makes it easy to install
virtually any JavaScript library.

Rhino uses Node.js to provide state of the art tools for working with
JavaScript and Sass. In the future it might also become an easy way to
add any JS library to your Shiny app.

The following functions require Node.js to work:

1.  [`build_js()`](https://appsilon.github.io/rhino/v1.0.0/reference/build_js.md)
2.  [`build_sass()`](https://appsilon.github.io/rhino/v1.0.0/reference/build_sass.md)
    (with `sass: node` configuration in `rhino.yml`)
3.  [`lint_js()`](https://appsilon.github.io/rhino/v1.0.0/reference/lint_js.md)
4.  [`lint_sass()`](https://appsilon.github.io/rhino/v1.0.0/reference/lint_sass.md)
5.  [`test_e2e()`](https://appsilon.github.io/rhino/v1.0.0/reference/test_e2e.md)

You don’t need to worry about Node.js most of the time. You need to
install it on your system along with
[yarn](https://classic.yarnpkg.com/lang/en/) (an alternative package
manager for Node.js). The rest will be handled automatically.

Under the hood Rhino will create a `.rhino/node` directory in your
project to store the specific libraries needed by these tools. This
directory is git-ignored by default and safe to remove.

The
[`build_sass()`](https://appsilon.github.io/rhino/v1.0.0/reference/build_sass.md)
function is worth an additional comment. Depending on the configuration
in `rhino.yml` it can use either the
[sass](https://www.npmjs.com/package/sass) Node.js package or the
[sass](https://rstudio.github.io/sass/) R package. We recommend the
Node.js version, as it is the primary, actively developed implementation
of Sass. In contrast, the R package uses the deprecated
[LibSass](https://sass-lang.com/blog/libsass-is-deprecated)
implementation.
