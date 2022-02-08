read_config <- function() yaml::read_yaml("rhino.yml", eval.expr = FALSE)

#' @export
sync <- function() {
  config <- read_config()
  enabled <- config$features$ci_github
  message("Checking GitHub CI... ", appendLF = FALSE)
  status <- ci_github_status(enabled)
  message(status)
  if (status == "Missing") ci_github_add()
  else if (status == "Dangling") ci_github_remove()
}

ci_github_file <- function() {
  list(
    src = fs::path_package("rhino", "ci_github.yml"),
    dst = fs::path(".github", "workflows", "test.yml")
  )
}

ci_github_status <- function(enabled) {
  file <- ci_github_file()
  dst_exists <- fs::file_exists(file$dst)
  if (enabled) {
    if (dst_exists) "OK" else "Missing"
  } else {
    if (dst_exists) "Dangling" else "OK"
  }
}

ci_github_add <- function() {
  message("Adding GitHub CI")
  file <- ci_github_file()
  fs::file_copy(file$src, file$dst, overwrite = TRUE)
}

ci_github_remove <- function() {
  message("Removing GitHub CI")
  file <- ci_github_file()
  fs::file_delete(file$dst)
}
