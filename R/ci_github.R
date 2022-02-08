ci_github_file <- function() {
  list(
    src = fs::path_package("rhino", "ci_github.yml"),
    dst = fs::path(".github", "workflows", "test.yml")
  )
}

ci_github <- list(
  key = "ci_github",
  name = "GitHub CI",
  check = function(enabled) {
    file <- ci_github_file()
    dst_exists <- fs::file_exists(file$dst)
    if (enabled) {
      if (dst_exists) "OK" else "Missing"
    } else {
      if (dst_exists) "Dangling" else "OK"
    }
  },
  add = function() {
    file <- ci_github_file()
    fs::file_copy(file$src, file$dst, overwrite = TRUE)
  },
  remove =  function() {
    file <- ci_github_file()
    fs::file_delete(file$dst)
  }
)
