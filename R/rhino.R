node_path <- function(...) {
  fs::path(".rhino", "node", ...)
}

rename_template_path <- function(path) {
  path <- fs::path_split(path)[[1]]
  path <- sub("^dot\\.", ".", path)
  path <- sub("\\.template$", "", path)
  fs::path_join(path)
}

# Copy template from source path (relative to `inst/templates`) to destination
# with some renaming applied to the names of files and directories:
# 1. Leading `dot.` is replaced with `.`.
# 2. Trailing `.template` is removed.
copy_template <- function(src, dst = ".") {
  src <- fs::path_package("rhino", "templates", src)
  target <- function(path) {
    path <- fs::path_rel(path, start = src)
    path <- rename_template_path(path)
    fs::path(dst, path)
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

rproj_exists <- function() {
  length(fs::dir_ls(type = "file", glob = "*.Rproj")) > 0
}

copy_rproj <- function() {
  file_name <- paste0(
    basename(fs::path_abs(".")),
    ".Rproj"
  )

  fs::file_copy(
    fs::path_package("rhino", "templates", "rproj", "Rproj.template"),
    fs::path(".", file_name)
  )
}

system_cmd_version <- function(cmd) {
  tryCatch(
    system2(cmd, "--version", stdout = TRUE, stderr = TRUE),
    error = function(e) e$message
  )
}

#' Print diagnostics
#'
#' Prints information which can be useful for diagnosing issues with Rhino.
#'
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Print diagnostic information.
#'   diagnostics()
#' }
#'
#' @export
diagnostics <- function() {
  writeLines(c(
    paste(Sys.info()[c("sysname", "release", "version")], collapse = " "),
    R.version.string,
    paste("rhino:", utils::packageVersion("rhino")),
    paste("node:", system_cmd_version("node")),
    paste("yarn:", system_cmd_version("yarn"))
  ))
}
