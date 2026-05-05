# Changelog

## rhino 1.3.1

CRAN release: 2023-05-12

1.  [`test_r()`](https://appsilon.github.io/rhino/v1.3.1/reference/test_r.md)
    now clears the environment of loaded box modules before tests are
    run. This removes the need for
    [`box::reload()`](https://klmr.me/box/reference/unload.html) calls
    in tests.
2.  Added support for `shinymanager`.

## [rhino 1.3.0](https://github.com/Appsilon/rhino/releases/tag/v1.3.0)

CRAN release: 2022-12-22

1.  Rhino now works with `shinytest2` out of the box.

## [rhino 1.2.1](https://github.com/Appsilon/rhino/releases/tag/v1.2.1)

CRAN release: 2022-11-30

1.  Fix Rhino GitHub Actions (Cypress used to fail).

## [rhino 1.2.0](https://github.com/Appsilon/rhino/releases/tag/v1.2.0)

CRAN release: 2022-11-27

1.  Don’t use symbolic links internally. This fixes a couple of issues
    with Node.js tools on Windows:
    - Developer Mode is no longer needed.
    - The
      [`build_js()`](https://appsilon.github.io/rhino/v1.3.1/reference/build_js.md)
      and
      [`build_sass()`](https://appsilon.github.io/rhino/v1.3.1/reference/build_sass.md)
      functions now work with `watch = TRUE`.
    - The
      [`lint_js()`](https://appsilon.github.io/rhino/v1.3.1/reference/lint_js.md)
      function now works when imports are used in JavaScript.
2.  Drop dependency on Yarn - only Node.js is now required.
3.  Improved Rhino CI:
    - Run
      [`build_js()`](https://appsilon.github.io/rhino/v1.3.1/reference/build_js.md)
      and
      [`build_sass()`](https://appsilon.github.io/rhino/v1.3.1/reference/build_sass.md)
      CI.
    - Use R version from the lockfile.
    - Upgrade to `r-lib/actions/setup-r@v2`.
4.  The
    [`lint_r()`](https://appsilon.github.io/rhino/v1.3.1/reference/lint_r.md)
    now accepts a `paths` argument which can be used to run it on
    specific files.
5.  The
    [`init()`](https://appsilon.github.io/rhino/v1.3.1/reference/init.md)
    function will refuse to run in the home directory unless
    `force = TRUE` is passed.
6.  Shiny bookmarking works better with `legacy_entrypoint: source` (the
    UI function no longer needs to take an argument).
7.  Upgraded to `lintr >= 3.0.0` and updated linter rules.

## [rhino 1.1.1](https://github.com/Appsilon/rhino/releases/tag/v1.1.1)

CRAN release: 2022-09-07

Minor release to fix CRAN check failures (upgrade roxygen2 to 7.2.1 and
regenerate documentation).

## [rhino 1.1.0](https://github.com/Appsilon/rhino/releases/tag/v1.1.0)

CRAN release: 2022-07-12

1.  New guide: “How to manage secrets and environments”
    ([\#263](https://github.com/Appsilon/rhino/issues/263)).
2.  Sass-specific at-rules are now recognized by
    [`rhino::lint_sass()`](https://appsilon.github.io/rhino/v1.3.1/reference/lint_sass.md)
    ([\#289](https://github.com/Appsilon/rhino/issues/289)).
3.  Shiny bookmarking now works
    ([\#294](https://github.com/Appsilon/rhino/issues/294)).
4.  RStudio no longer complains about “too many files” during
    push-button deployment
    ([\#299](https://github.com/Appsilon/rhino/issues/299)).
5.  Issues with server reloading during development resolved
    ([\#297](https://github.com/Appsilon/rhino/issues/297)).

## [rhino 1.0.0](https://github.com/Appsilon/rhino/releases/tag/v1.0.0)

CRAN release: 2022-04-19

First stable version.
