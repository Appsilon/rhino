#' @importFrom fs dir_create file_create path
#' @importFrom usethis use_template proj_set
#' @export
init <- function(dir = ".") {
  dir_create(dir)
  # minimal requirement of usethis to accept directory as R project
  file_create(path(dir, ".here"))
  proj_set(dir)

  use_template(
    template = "app_structure/app.R",
    save_as = "app.R",
    package = "rhino"
  )
}
