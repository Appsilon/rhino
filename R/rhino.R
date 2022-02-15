read_config <- function() {
  yaml::read_yaml("rhino.yml")
}

template_path <- function(...) {
  fs::path_package("rhino", "templates", ...)
}

node_path <- function(...) {
  fs::path(".rhino", "node", ...)
}
