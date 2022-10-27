# rhino (development version)

* Added a `NEWS.md` file to track changes to the package.
* Added a `paths` argument to `lint_r()`.
* Prevent `init()` in home directory.
* Included `build_js()` and `build_sass()` in template CI.
* Use R version from the lockfile in CI.

# rhino 1.1.1

## What's Changed
* Add upcoming events section to the README by @kamilzyla in https://github.com/Appsilon/rhino/pull/311
* Update upcoming events by @kamilzyla in https://github.com/Appsilon/rhino/pull/315
* Update info on upcoming events by @kamilzyla in https://github.com/Appsilon/rhino/pull/316
* Upgrade roxygen2 to 7.2.1 and regenerate documentation by @kamilzyla in https://github.com/Appsilon/rhino/pull/320

# rhino 1.1.0

## Highlights
1. New guide:  "How to manage secrets and environments" (#263).
2. Sass-specific at-rules are now recognized by `rhino::lint_sass()` (#289).
3. Shiny bookmarking now works (#294).
4. RStudio no longer complains about "too many files" during push-button deployment  (#299).
5. Issues with server reloading during development resolved (#297).

## What's Changed
* docs: Add url to pkgdown configuration. by @jakubnowicki in https://github.com/Appsilon/rhino/pull/260
* fix: make configure_logger() work with missing config fields by @TymekDev in https://github.com/Appsilon/rhino/pull/254
* Rhino Tutorial: Minor text and css changes for app preview images by @ianemoore in https://github.com/Appsilon/rhino/pull/241
* What is rhino edit by @ianemoore in https://github.com/Appsilon/rhino/pull/256
* Edit app structure by @ianemoore in https://github.com/Appsilon/rhino/pull/257
* docs: add note about native pipe operator by @TymekDev in https://github.com/Appsilon/rhino/pull/262
* Describe how main branch is used in CONTRIBUTING guide by @kamilzyla in https://github.com/Appsilon/rhino/pull/265
* docs: add secrets and environments how to guide by @TymekDev in https://github.com/Appsilon/rhino/pull/263
* Indicate stub status in the article header by @kamilzyla in https://github.com/Appsilon/rhino/pull/266
* Draft articles by @kamilzyla in https://github.com/Appsilon/rhino/pull/267
* Configure issue templates by @kamilzyla in https://github.com/Appsilon/rhino/pull/269
* Update the GTM container ID by @kamilzyla in https://github.com/Appsilon/rhino/pull/272
* Run apt-get update in CI by @kamilzyla in https://github.com/Appsilon/rhino/pull/275
* Improve stylelint config to accept Sass at-rules by @kamilzyla in https://github.com/Appsilon/rhino/pull/289
* Explain documentation structure by @kamilzyla in https://github.com/Appsilon/rhino/pull/290
* Always purge box cache in rhino::app() by @kamilzyla in https://github.com/Appsilon/rhino/pull/292
* Support bookmarking by @kamilzyla in https://github.com/Appsilon/rhino/pull/294
* Update lintr config after 3.0.0 release by @kamilzyla in https://github.com/Appsilon/rhino/pull/296
* Simplify CI into a single workflow by @kamilzyla in https://github.com/Appsilon/rhino/pull/301
* feat: Add a template for .rscignore file. by @jakubnowicki in https://github.com/Appsilon/rhino/pull/299
* Wording and style improvements for tutorial by @kamilzyla in https://github.com/Appsilon/rhino/pull/273
* Change maintainer to an alias by @kamilzyla in https://github.com/Appsilon/rhino/pull/303
* Work around server reloading issues by @kamilzyla in https://github.com/Appsilon/rhino/pull/297
* Bump version to 1.1.0 by @kamilzyla in https://github.com/Appsilon/rhino/pull/304
* Change maintainer back to Kamil by @kamilzyla in https://github.com/Appsilon/rhino/pull/305
