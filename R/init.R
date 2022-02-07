#' @export
init <- function(dir = ".") {
  init_setup(dir)

  create_app_structure()

  init_cleanup(dir)
}

#' @importFrom fs dir_create file_create path
init_setup <- function(dir) {
  dir_create(dir)
  # minimal requirement of usethis to accept directory as R project
  file_create(path(dir, ".here"))
  proj_set(dir)
}

#' @importFrom fs file_delete path
init_cleanup <- function(dir) {
  file_delete(path(dir, ".here"))
}

#' @importFrom usethis use_template proj_set
create_app_structure <- function() {
    use_template(
    template = "app_structure/app.R",
    save_as = "app.R",
    package = "rhino"
  )
}
