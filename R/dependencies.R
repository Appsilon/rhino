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

#' Add (install) packages to Rhino app project
#'
#' Adds the requested packages to the 'dependencies.R' file, installs them and does a {renv}
#' snapshot in an already initialized Rhino app.
#'
#' @param packages character vector of package names
#' @return None. This function is called for side effects.
#' @export
dependency_add <- function(packages) {
  stopifnot(is.character(packages))
  renv::install(packages)
  write_dependencies(c(packages, read_dependencies()))
  renv::snapshot()
  invisible()
}

#' Remove (uninstall) packages from Rhino app project
#'
#' Remove the requested packages from the 'dependencies.R' file, uninstalls them and does a {renv}
#' snapshot in an already initialized Rhino app.
#'
#' @param packages character vector of package names
#' @return None. This function is called for side effects.
#' @export
dependency_remove <- function(packages) {
  stopifnot(is.character(packages))
  renv::remove(packages)
  write_dependencies(setdiff(read_dependencies(), packages))
  renv::snapshot()
  invisible()
}
