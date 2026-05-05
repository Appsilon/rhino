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

  # Install a specific version of shiny
  rhino::pkg_install("shiny@1.6.0")

  # Install shiny.i18n package from GitHub
  rhino::pkg_install("Appsilon/shiny.i18n")

  # Install Biobase package from Bioconductor
  rhino::pkg_install("bioc::Biobase")

  # Install shiny from local source
  rhino::pkg_install("~/path/to/shiny")

  # Remove dplyr
  rhino::pkg_remove("dplyr")
} # }
```
