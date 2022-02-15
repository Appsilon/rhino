read_config <- function() {
  yaml::read_yaml("rhino.yml")
}

template_path <- function(...) {
  fs::path_package("rhino", "templates", ...)
}

node_path <- function(...) {
  fs::path(".rhino", "node", ...)
}

copy_template <- function(src, dst) {
  src <- template_path(src)
  target <- function(x) {
    relative <- fs::path_rel(x, start = src)
    relative <- fs::path_split(relative)[[1]]
    relative <- sub("^dot.", ".", relative)
    relative <- sub(".template$", "", relative)
    relative <- fs::path_join(relative)
    fs::path(dst, relative)
  }
  fs::dir_create(dst)
  fs::dir_walk(
    path = src,
    recurse = TRUE,
    type = "directory",
    fun = function(dir) fs::dir_create(target(dir))
  )
  fs::dir_walk(
    path = src,
    recurse = TRUE,
    type = "file",
    fun = function(file) fs::file_copy(file, target(file))
  )
}
