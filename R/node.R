node_path <- function() fs::path(".rhino", "node")

run_yarn <- function(...) {
  if (!fs::dir_exists(node_path())) install_node()
  system2("yarn", c("--cwd", shQuote(node_path()), ...))
}

install_node <- function() {
  fs::dir_copy(
    path = fs::path_package("rhino", "node"),
    new_path = node_path(),
    overwrite = TRUE
  )
  fs::link_create(
    path = fs::path("..", ".."),
    new_path = fs::path(node_path(), "root")
  )
  run_yarn("install")
}
