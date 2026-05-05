# Explanation: Node.js - JavaScript and Sass tools

## About

[Node.js](https://nodejs.org/en/about/) is a runtime environment which
can execute JavaScript code outside a web browser. It is used widely for
web development. Its package manager,
[npm](https://docs.npmjs.com/about-npm), makes it easy to install
virtually any JavaScript library. You can use other package managers
such as [bun](https://bun.sh) and [pnpm](https://pnpm.io/) that are
compatible with `npm`.

To switch from the default npm usage, set a global environment variable
named `RHINO_NPM`. For instance, if you want to use `bun` instead of
`npm`, add `export RHINO_NPM=bun` to your shell startup file
(e.g. `.bashrc`).

Rhino uses Node.js to provide state of the art tools for working with
JavaScript and Sass. The following functions require Node.js to work:

1.  [`build_js()`](https://appsilon.github.io/rhino/v1.9.0/reference/build_js.md)
2.  [`build_sass()`](https://appsilon.github.io/rhino/v1.9.0/reference/build_sass.md)
    (with `sass: node` configuration in `rhino.yml`)
3.  [`lint_js()`](https://appsilon.github.io/rhino/v1.9.0/reference/lint_js.md)
4.  [`lint_sass()`](https://appsilon.github.io/rhino/v1.9.0/reference/lint_sass.md)
5.  [`test_e2e()`](https://appsilon.github.io/rhino/v1.9.0/reference/test_e2e.md)

### Node directory

Under the hood Rhino will create a `.rhino` directory in your project to
store the specific libraries needed by these tools. This directory is
git-ignored by default and safe to remove.

### Node installation via nvm

Node can be installed in various ways. One of them relies on
[`nvm`](https://github.com/nvm-sh/nvm) (Node Version Manager).

There’s a known [issue](https://github.com/Appsilon/rhino/issues/345)
when using multiple versions of `Node` that were installed with `nvm`
that causes RStudio to not recognize properly the chosen version. It’s
caused by `nvm` and RStudio and can be easily mitigated by starting the
RStudio through the terminal:

**Ubuntu/Debian** Open your terminal of choice (i.e. Bash) and run

    rstudio

**Windows** Open your Windows terminal of choice (i.e. Terminal,
PowerShell, Git Bash) and run:

    path/to/your/rstudio/folder/Rstudio.exe

**Mac** Open your Mac terminal of choice (i.e. default Terminal) and
run:

    open -na Rstudio

### build_sass() function

The
[`build_sass()`](https://appsilon.github.io/rhino/v1.9.0/reference/build_sass.md)
function is worth an additional comment. Depending on the configuration
in `rhino.yml` it can use either the
[sass](https://www.npmjs.com/package/sass) Node.js package or the
[sass](https://rstudio.github.io/sass/) R package. We recommend the
Node.js version, as it is the primary, actively developed implementation
of Sass. In contrast, the R package uses the deprecated
[LibSass](https://sass-lang.com/blog/libsass-is-deprecated)
implementation.
