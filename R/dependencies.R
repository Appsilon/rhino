read_dependencies <- function() {
  if (fs::file_exists("dependencies.R")) {
    cli::cli_alert_info("Reading '{.file dependencies.R}.'")
    renv::dependencies("dependencies.R")$Package
  } else if (fs::dir_exists("app")) {
    cli::cli_alert_info("Inferring dependencies from the {.file app} directory.")
    renv::dependencies("app")$Package
  } else {
    # It seems we are initializing a fresh project.
    character()
  }
}

write_dependencies <- function(deps) {
  deps <- sort(unique(c("rhino", deps))) # Rhino is always needed as a dependency.
  deps <- purrr::map_chr(deps, function(name) glue::glue("library({name})"))
  deps <- c(
    "# This file allows packrat (used by rsconnect during deployment) to pick up dependencies.",
    deps
  )
  writeLines(deps, "dependencies.R")
}

# nolint start: line_length_linter
#' Manage dependencies
#'
#' Install, remove or update the R package dependencies of your Rhino project.
#'
#' Use `pkg_install()` to install or update a package to the latest version.
#' Use `pkg_remove()` to remove a package.
#'
#' These functions will install or remove packages from the local `{renv}` library,
#' and update the `dependencies.R` and `renv.lock` files accordingly, all in one step.
#' The underlying `{renv}` functions can still be called directly for advanced use cases.
#' See the [Explanation: Renv configuration](https://appsilon.github.io/rhino/articles/explanation/renv-configuration.html)
#' to learn about the details of the setup used by Rhino.
#'
#' @param packages Character vector of package names.
#' @return None. This functions are called for side effects.
#' @name dependencies
#'
#' @examples
#' \dontrun{
#'   # Install dplyr
#'   rhino::pkg_install("dplyr")
#'
#'   # Update shiny to the latest version
#'   rhino::pkg_install("shiny")
#'
#'   # Remove dplyr
#'   rhino::pkg_remove("dplyr")
#' }
# nolint end
NULL

#' @rdname dependencies
#' @export
pkg_install <- function(packages) {
  stopifnot(is.character(packages))
  renv::install(packages)
  write_dependencies(c(packages, read_dependencies()))
  renv::snapshot()
  invisible()
}

#' @rdname dependencies
#' @export
pkg_remove <- function(packages) {
  stopifnot(is.character(packages))
  renv::remove(packages)
  write_dependencies(setdiff(read_dependencies(), packages))
  renv::snapshot()
  invisible()
}
