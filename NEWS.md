# rhino (development version)

* Added a `NEWS.md` file to track changes to the package.
* Added a `paths` argument to `lint_r()`.
* Prevent `init()` in home directory.
* Included `build_js()` and `build_sass()` in template CI.
* Use R version from the lockfile in CI.
* Dropped dependency on Yarn - only Node.js is now required.
* Upgraded to `r-lib/actions/setup-r@v2`.
* Upgraded to `lintr >= 3.0.0`.
* Silence audit and funding messages when using Node.js.
* Developer Mode is no longer needed on Windows to use Node.js tools.
* The `build_js()` and `build_sass()` functions should now work on Windows with `watch = TRUE`.
* The `lint_js()` function should now work on Windows when imports are used in JavaScript.

# [rhino 1.1.1](https://github.com/Appsilon/rhino/releases/tag/v1.1.1)

Minor release to fix CRAN check failures (upgrade roxygen2 to 7.2.1 and regenerate documentation).

# [rhino 1.1.0](https://github.com/Appsilon/rhino/releases/tag/v1.1.0)

## Highlights
1. New guide:  "How to manage secrets and environments" (#263).
2. Sass-specific at-rules are now recognized by `rhino::lint_sass()` (#289).
3. Shiny bookmarking now works (#294).
4. RStudio no longer complains about "too many files" during push-button deployment (#299).
5. Issues with server reloading during development resolved (#297).

# [rhino 1.0.0](https://github.com/Appsilon/rhino/releases/tag/v1.0.0)

First stable version.
