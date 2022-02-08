#' @export
init <- function(dir = ".") {
  init_setup(dir)

  create_app_structure(dir)
  create_tests_structure(dir)
}

#' @importFrom fs dir_create
init_setup <- function(dir) {
  dir_create(dir)
}

#' @importFrom fs dir_copy file_copy path
create_app_structure <- function(dir) {
  file_copy(
    path = path_rhino(
      "app_structure",
      "app.R"
    ),
    new_path = dir
  )

  app_path <- path(dir, "app")
  dir_create(app_path)
  dir_copy(
    path = path_rhino(
      "app_structure",
      "app"
    ),
    new_path = app_path
  )
}

#' @importFrom fs dir_create dir_copy path
create_tests_structure <- function(dir) {
  tests_path <- path(dir, "tests")
  dir_create(tests_path)
  dir_copy(
    path = path_rhino(
      "tests_structure"
    ),
    new_path = tests_path
  )
}

#' @importFrom  fs path_package
path_rhino <- function(...) {
  path_package(
    "rhino",
    "templates",
    ...
  )
}
