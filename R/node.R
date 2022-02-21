system_yarn <- function(...) {
  status <- system2(
    command = "yarn",
    args = c("--cwd", shQuote(node_path()), ...)
  )
  if (status != 0) {
    stop(glue::glue("yarn failed with exit status {status}"), call. = FALSE)
  }
}

add_node <- function() {
  copy_template("node", node_path())
  fs::link_create(
    path = fs::path("..", ".."),
    new_path = fs::path(node_path(), "root")
  )
}

yarn <- function(...) {
  if (!fs::dir_exists(node_path())) {
    add_node()
    system_yarn("install")
  }
  system_yarn(...)
}
