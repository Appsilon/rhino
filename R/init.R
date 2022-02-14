#' Create Shiny application using `{rhino}`
#'
#' @param dir Name of the directory to create application in.
#' @param github_actions_ci Should the Github Actions CI be added.
#'
#' @export
init <- function(dir = ".", github_actions_ci = TRUE) {
  init_setup(dir)

  create_app_structure(dir)

  create_unit_tests_structure(dir)

  if (isTRUE(github_actions_ci)) add_github_actions_ci(dir)

  init_renv(dir)
}

#' @importFrom fs dir_create
#' @importFrom cli cli_alert_success
init_setup <- function(dir) {
  dir_create(dir)
  cli_alert_success("Application directory created")
}

#' @importFrom fs dir_copy file_copy path
#' @importFrom cli cli_alert_success
create_app_structure <- function(dir) {
  file_copy(
    path = path_rhino("app_structure", "app.R"),
    new_path = dir
  )

  file_copy(
    path = path_rhino("app_structure", "Rprofile"),
    new_path = path(dir, ".Rprofile")
  )

  file_copy(
    path = path_rhino("app_structure", "src.Rproj2"),
    new_path = path(dir, "src.Rproj")
  )

  dir_copy(
    path = path_rhino("app_structure", "app"),
    new_path = dir
  )

  cli_alert_success("Application structure created")
}

#' @importFrom fs dir_create dir_copy path
#' @importFrom cli cli_alert_success
add_github_actions_ci <- function(dir) {
  github_path <- path(dir, ".github")
  dir_create(github_path)
  dir_copy(
    path = path_rhino("github_ci", "workflows"),
    new_path = github_path
  )

  cli_alert_success("Github Actions CI added")
}

#' @importFrom fs file_copy
#' @importFrom renv init
#' @importFrom withr with_dir
#' @importFrom cli cli_alert_success
init_renv <- function(dir) {
  file_copy(
    path = path_rhino("renv", "renvignore"),
    new_path = path(dir, ".renvignore")
  )

  file_copy(
    path = path_rhino("renv", "dependencies.R"),
    new_path = path(dir)
  )

  with_dir(
    dir,
    renv::init(restart = FALSE)
  )

  cli_alert_success("renv initiated")
}

#' @importFrom fs dir_create dir_copy path
#' @importFrom cli cli_alert_success
create_unit_tests_structure <- function(dir) {
  tests_path <- path(dir, "tests")
  dir_create(tests_path)

  dir_copy(
    path = path_rhino("unit_tests", "testthat"),
    new_path = tests_path
  )

  cli_alert_success("Unit tests structure created")
}

#' @importFrom  fs path_package
path_rhino <- function(...) {
  path_package(
    "rhino",
    "templates",
    ...
  )
}
