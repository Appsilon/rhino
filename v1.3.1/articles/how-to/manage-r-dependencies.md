# How-to: Manage R dependencies

Rhino uses [renv](https://rstudio.github.io/renv/) to manage the R
package dependencies of your project. To learn about the details and
rationale for the particular setup used by Rhino, please refer to
[Explanation: Renv
configuration](https://appsilon.github.io/rhino/articles/explanation/renv-configuration.html).

This article offers short recipes for the most common tasks: adding,
updating and removing dependencies.

### Add a dependency

1.  Add a [`library(package)`](https://rdrr.io/r/base/library.html) line
    to `dependencies.R`.
2.  Call `renv::install("package")`.
3.  Call
    [`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html).

### Update a dependency

1.  Call `renv::update("package")`.
2.  Call
    [`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html).

### Remove a dependency

1.  Remove the [`library(package)`](https://rdrr.io/r/base/library.html)
    line from `dependencies.R`.
2.  Call
    [`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html).
3.  Call `renv::restore(clean = TRUE)`.
