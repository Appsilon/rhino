#' @export
init <- function(dir = ".") {
  init_setup(dir)

  create_app_structure(dir)
  add_github_actions_cli(dir)
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
    path = path_rhino(
      "app_structure",
      "app.R"
    ),
    new_path = dir
  )

  file_copy(
    path = path_rhino(
      "app_structure",
      "Rprofile"
    ),
    new_path = path(dir, ".Rprofile")
  )

  file_copy(
    path = path_rhino(
      "app_structure",
      "src.Rproj2"
    ),
    new_path = path(dir, "src.Rproj")
  )

  dir_copy(
    path = path_rhino(
      "app_structure",
      "app"
    ),
    new_path = dir
  )

  cli_alert_success("Application structure created")
}

#' @importFrom fs dir_create dir_copy path
#' @importFrom cli cli_alert_success
add_github_actions_cli <- function(dir) {
  github_path <- path(dir, ".github")
  dir_create(github_path)
  dir_copy(
    path = path_rhino(
      "github_ci",
      "workflows"
    ),
    new_path = github_path
  )

  cli_alert_success("Github Actions CI added")
}

#' @importFrom  fs path_package
path_rhino <- function(...) {
  path_package(
    "rhino",
    "templates",
    ...
  )
}
