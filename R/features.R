read_config <- function() yaml::read_yaml("rhino.yml", eval.expr = FALSE)

#' @export
sync <- function() {
  config <- read_config()
  ci_github_update(config$features$ci_github)
}

ci_github_update <- function(config) {
  src <- fs::path_package("rhino", "ci_github.yml")
  dst <- fs::path(".github", "workflows", "test.yml")
  if (config) {
    fs::file_copy(src, dst, overwrite = TRUE)
  } else {
    fs::file_delete(dst)
  }
}
