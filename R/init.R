#' Create Shiny application using `{rhino}`
#'
#' Generates the file structure of a Rhino application.
#' Can be used to start a fresh project or to migrate an existing Shiny application
#' created without Rhino.
#'
#' The recommended steps for migrating an existing application to Rhino:
#' 1. Put all app files in the `app` directory,
#' so that it can be run with `shiny::shinyAppDir("app")` (assuming all dependencies are installed).
#' 2. If you have a list of dependencies in form of `library()` calls,
#' put them in the `dependencies.R` file.
#' If this file does not exist, Rhino will generate it based on `renv::dependencies("app")`.
#' 3. If your project uses renv, put `renv.lock` and `renv` directory in the project root.
#' Rhino will try to only add the necessary dependencies to your lockfile.
#' 4. Run `rhino::init()` in the project root.
#'
#' When using an existing `renv.lock` file,
#' Rhino will install itself using `renv::install("rhino")`.
#' You can use the `rhino_install_source` argument to change this behavior,
#' e.g. `Appsilon/rhino@v0.4.0` to install a specific version from GitHub.
#'
#' @param dir Name of the directory to create application in.
#' @param github_actions_ci Should the Github Actions CI be added?
#' @param rhino_install_source Passed to `renv::install()` when using an existing `renv.lock`.
#'
#' @export
init <- function(
  dir = ".",
  github_actions_ci = TRUE,
  rhino_install_source = "rhino"
) {
  fs::dir_create(dir)
  withr::with_dir(dir, {
    init_renv(rhino_install_source)
    create_app_structure()
    create_unit_tests_structure()
    create_e2e_tests_structure()
    if (isTRUE(github_actions_ci)) add_github_actions_ci()
  })
}

write_dependencies <- function() {
  deps <- "rhino"
  if (fs::file_exists("dependencies.R")) {
    deps <- c(deps, renv::dependencies("dependencies.R")$Package)
  } else if (fs::dir_exists("app")) {
    deps <- c(deps, renv::dependencies("app")$Package)
  }
  deps <- sort(unique(deps))
  deps <- purrr::map_chr(deps, function(name) glue::glue("library({name})"))
  deps <- c(
    "# This file allows packrat (used by rsconnect during deployment) to pick up dependencies.",
    deps
  )
  writeLines(deps, "dependencies.R")
}

init_renv <- function(rhino_install_source) {
  write_dependencies()
  copy_template("renv")
  if (fs::file_exists("renv.lock")) {
    renv::load()
    renv::restore(prompt = FALSE, clean = TRUE)
    renv::install(rhino_install_source)
    renv::snapshot()
  } else {
    renv::init()
  }
  cli::cli_alert_success("renv initialized")
}

create_app_structure <- function() {
  copy_template("app_structure")
  cli::cli_alert_success("Application structure created")
}

add_github_actions_ci <- function() {
  copy_template("github_ci")
  cli::cli_alert_success("Github Actions CI added")
}

create_unit_tests_structure <- function() {
  copy_template("unit_tests")
  cli::cli_alert_success("Unit tests structure created")
}

create_e2e_tests_structure <- function() {
  copy_template("e2e_tests")
  cli::cli_alert_success("E2E tests structure created")
}
