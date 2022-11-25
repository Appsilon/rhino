# rhino (development version)

# [rhino 1.2.0](https://github.com/Appsilon/rhino/releases/tag/v1.2.0-rc.2)

## Highlights
1. Don't use symbolic links internally.
This fixes a couple of issues with Node.js tools on Windows:
    * Developer Mode is no longer needed.
    * The `build_js()` and `build_sass()` functions now work with `watch = TRUE`.
    * The `lint_js()` function now works when imports are used in JavaScript.
2. Drop dependency on Yarn - only Node.js is now required.
3. Improved Rhino CI:
    * Run `build_js()` and `build_sass()` CI.
    * Use R version from the lockfile.
    * Upgrade to `r-lib/actions/setup-r@v2`.
4. The `lint_r()` now accepts a `paths` argument which can be used to run it on specific files.
5. The `init()` function will refuse to run in the home directory unless `force = TRUE` is passed.
6. Shiny bookmarking works better with `legacy_entrypoint: source`
(the UI function no longer needs to take an argument).
7. Upgraded to `lintr >= 3.0.0` and updated linter rules.

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
