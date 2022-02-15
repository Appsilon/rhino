system_yarn <- function(...) {
  system2(
    command = "yarn",
    args = c("--cwd", shQuote(node_path()), ...)
  )
}

add_node <- function() {
  fs::dir_copy(
    path = template_path("node"),
    new_path = node_path(),
    overwrite = TRUE
  )
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
