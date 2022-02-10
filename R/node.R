run_yarn <- function(...) {
  system2("yarn", c("--cwd", "node", ...))
}

install_node <- function() {
  node_path <- fs::path(".rhino", "node")
  if (fs::dir_exists(node_path)) return()
  fs::dir_copy(
    path = fs::path_package("rhino", "node"),
    new_path = node_path,
    overwrite = TRUE
  )
  fs::link_create(
    path = fs::path("..", ".."),
    new_path = fs::path(node_path, "root")
  )
}
