# Explanation: Renv configuration

This article explains the internals of R dependency management in Rhino.
Practical instructions for adding, removing and updating dependencies
can be found in the documentation of
[`rhino::pkg_install()`](https://appsilon.github.io/rhino/v1.4.0/reference/dependencies.md)
and
[`rhino::pkg_remove()`](https://appsilon.github.io/rhino/v1.4.0/reference/dependencies.md).

Rhino relies on [renv](https://rstudio.github.io/renv/) to manage the R
package dependencies of your project. With
[renv](https://rstudio.github.io/renv/) you can create an isolated
package library for each application and easily restore it on a
different machine using the exact same package versions. This is crucial
for the maintainability of any project.

To learn more about [renv](https://rstudio.github.io/renv/) visit its
[website](https://rstudio.github.io/renv/index.html). This article
describes the specifics of how Rhino uses
[renv](https://rstudio.github.io/renv/) assuming some basic familiarity
with the package.

## Snapshot types

[renv](https://rstudio.github.io/renv/) offers different [snapshot
types](https://rstudio.github.io/renv/reference/snapshot.html#snapshot-type).
By default it performs an *implicit* snapshot: it tries to detect the
dependencies of your project by scanning your R sources. While
convenient in small projects, this approach lacks fine control and can
be inefficient in larger code bases.

It would be preferable to use *explicit* snapshots: the dependencies of
your project must be listed in a `DESCRIPTION` file. Unfortunately we
faced some issues with this snapshot type in deployments. Instead, Rhino
uses the following setup:

1.  Implicit snapshot (configured in `renv/settings.dcf`).
2.  A `dependencies.R` file with dependencies listed explicitly as
    [`library()`](https://rdrr.io/r/base/library.html) calls.
3.  A `.renvignore` file which tells
    [renv](https://rstudio.github.io/renv/) to only read
    `dependencies.R`.

This solution offers us the benefits of explicit snapshots (fine
control, efficiency) and works well in deployment.

## Manual dependency management

In most cases the only functions you will need are
[`rhino::pkg_install()`](https://appsilon.github.io/rhino/v1.4.0/reference/dependencies.md)
and
[`rhino::pkg_remove()`](https://appsilon.github.io/rhino/v1.4.0/reference/dependencies.md).
However it is still possible to manage dependencies using the underlying
[renv](https://rstudio.github.io/renv/) functions directly. This can be
helpful in some unusual situations (e.g. broken lockfile, installing a
specific package version).

[renv](https://rstudio.github.io/renv/) will only save to the lockfile
the packages which are installed in the local library, and it will
remove the packages which are not installed. Thus you should always run
`renv::restore(clean = TRUE)` before performing the steps below.

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

Calling `renv::install("package")` instead of `renv::update("package")`
will have the same effect.

### Remove a dependency

1.  Remove the [`library(package)`](https://rdrr.io/r/base/library.html)
    line from `dependencies.R`.
2.  Call
    [`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html).
3.  Call `renv::restore(clean = TRUE)`.

It is not recommended to use the
[`renv::remove()`](https://rstudio.github.io/renv/reference/remove.html)
function, as it will remove a package from the local library even if it
is still required by other packages. For example, `renv::remove("glue")`
followed by
[`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html)
will leave you without the [glue](https://glue.tidyverse.org/) package
in your lockfile, even though it is required by
[shiny](https://shiny.posit.co/).
