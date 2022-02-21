#' Create Shiny application using `{rhino}`
#'
#' @param dir Name of the directory to create application in.
#' @param github_actions_ci Should the Github Actions CI be added.
#'
#' @export
init <- function(dir = ".", github_actions_ci = TRUE) {
  create_app_structure(dir)
  create_unit_tests_structure(dir)
  create_e2e_tests_structure(dir)
  if (isTRUE(github_actions_ci)) add_github_actions_ci(dir)
  init_renv(dir)
}

create_app_structure <- function(dir) {
  copy_template("app_structure", dir)
  cli::cli_alert_success("Application structure created")
}

add_github_actions_ci <- function(dir) {
  copy_template("github_ci", dir)
  cli::cli_alert_success("Github Actions CI added")
}

init_renv <- function(dir) {
  copy_template("renv", dir)
  withr::with_dir(dir, renv::init(restart = FALSE))
  cli::cli_alert_success("renv initialized")
}

create_unit_tests_structure <- function(dir) {
  copy_template("unit_tests", dir)
  cli::cli_alert_success("Unit tests structure created")
}

create_e2e_tests_structure <- function(dir) {
  copy_template("e2e_tests", dir)
  cli::cli_alert_success("E2E tests structure created")
}
