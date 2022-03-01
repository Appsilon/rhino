#' Create Shiny application using `{rhino}`
#'
#' @param dir Name of the directory to create application in.
#' @param github_actions_ci Should the Github Actions CI be added.
#'
#' @export
init <- function(dir = ".", github_actions_ci = TRUE) {
  init_renv(dir)
  create_app_structure(dir)
  create_unit_tests_structure(dir)
  create_e2e_tests_structure(dir)
  if (isTRUE(github_actions_ci)) add_github_actions_ci(dir)
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

init_renv <- function(dir) {
  write_dependencies()
  copy_template("renv", dir)
  if (fs::file_exists("renv.lock")) {
    renv::load()
    renv::restore(prompt = FALSE, clean = TRUE)
    renv::install("~/git/rhino")
    renv::snapshot()
  } else {
    renv::init()
  }
  cli::cli_alert_success("renv initialized")
}

create_app_structure <- function(dir) {
  copy_template("app_structure", dir)
  cli::cli_alert_success("Application structure created")
}

add_github_actions_ci <- function(dir) {
  copy_template("github_ci", dir)
  cli::cli_alert_success("Github Actions CI added")
}

create_unit_tests_structure <- function(dir) {
  copy_template("unit_tests", dir)
  cli::cli_alert_success("Unit tests structure created")
}

create_e2e_tests_structure <- function(dir) {
  copy_template("e2e_tests", dir)
  cli::cli_alert_success("E2E tests structure created")
}
