# Manage dependencies

Install, remove or update the R package dependencies of your Rhino
project.

## Usage

``` r
pkg_install(packages)

pkg_remove(packages)
```

## Arguments

- packages:

  Character vector of package names.

## Value

None. This functions are called for side effects.

## Details

Use `pkg_install()` to install or update a package to the latest
version. Use `pkg_remove()` to remove a package.

These functions will install or remove packages from the local `{renv}`
library, and update the `dependencies.R` and `renv.lock` files
accordingly, all in one step. The underlying `{renv}` functions can
still be called directly for advanced use cases. See the [Explanation:
Renv
configuration](https://appsilon.github.io/rhino/articles/explanation/renv-configuration.html)
to learn about the details of the setup used by Rhino.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Install dplyr
  rhino::pkg_install("dplyr")

  # Update shiny to the latest version
  rhino::pkg_install("shiny")

  # Remove dplyr
  rhino::pkg_remove("dplyr")
} # }
```
