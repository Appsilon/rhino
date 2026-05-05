# How-to: Use shinytest2

If you have Node.js available on your machine, you can write end-to-end
tests using [Cypress](https://www.cypress.io/) and run them with
[`rhino::test_e2e()`](https://appsilon.github.io/rhino/v1.3.1/reference/test_e2e.md)
without any additional setup. If you’d prefer to use the `shinytest2`
package instead, you will need to:

1.  Install `shinytest2` and `shinyvalidate`.
    1.  Add
        [`library(shinytest2)`](https://rstudio.github.io/shinytest2/)
        and
        [`library(shinyvalidate)`](https://rstudio.github.io/shinyvalidate/)
        lines to your `dependencies.R`.
    2.  Install the packages with
        `renv::install(c("shinytest2", "shinyvalidate"))`.
    3.  Update the lockfile with
        [`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html).
2.  Create a test with `shinytest2::record_test()` or
    `shinytest2::use_shinytest2_test()` as usual.
3.  Optionally you can remove the following files created by
    `shinytest2`, which are unnecessary in Rhino:
    1.  Runner (`tests/testthat.R`), used in R packages and executed by
        `R CMD check`.
    2.  Setup (`tests/testthat/setup-shinytest2.R`), used in traditional
        Shiny applications with `global.R` and sources in the `R`
        directory.

The tests created by `shinytest2` are treated as any other `testthat`
tests and can be run with
[`rhino::test_r()`](https://appsilon.github.io/rhino/v1.3.1/reference/test_r.md).
