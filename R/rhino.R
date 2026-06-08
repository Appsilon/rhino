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

# Resolve conflicts for `use_*` helpers that scaffold files or directories.
# `paths` may name files and/or directories (a single value or a vector).
# Each existing path is moved aside to a fresh `.bak` path after a single
# confirmation. Returns TRUE if the caller should proceed (nothing existed, or
# everything was backed up) and FALSE if the user aborted. Errors in
# non-interactive sessions.
handle_existing_paths <- function(paths) {
  existing <- paths[fs::file_exists(paths)]
  if (length(existing) == 0) {
    return(TRUE)
  }

  if (prompt_conflict(existing) != 2) {
    cli::cli_alert_info("Aborted. {.path {existing}} {?was/were} not changed.")
    return(FALSE)
  }

  for (path in existing) {
    backup <- next_backup_path(path)
    fs::file_move(path, backup)
    cli::cli_alert_info("Existing {.path {path}} backed up as {.path {backup}}.")
  }
  TRUE
}

prompt_conflict <- function(paths) {
  if (!interactive()) {
    cli::cli_abort(
      c(
        "{.path {paths}} already {?exists/exist}.",
        i = "Remove or rename {cli::qty(paths)}{?it/them} before running this command."
      ),
      call = NULL
    )
  }
  utils::menu(
    choices = c("Abort", "Back up and create new"),
    title = cli::format_inline(
      "{.path {paths}} already {?exists/exist}. What would you like to do?"
    )
  )
}

next_backup_path <- function(path) {
  candidate <- paste0(path, ".bak")
  i <- 1
  while (fs::file_exists(candidate)) {
    candidate <- sprintf("%s.bak.%d", path, i)
    i <- i + 1
  }
  candidate
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

system_cmd_version <- function(cmd, throw_error = FALSE) {
  tryCatch(
    system2(cmd, "--version", stdout = TRUE, stderr = TRUE),
    error = function(e) {
      if (isTRUE(throw_error)) {
        cli::cli_abort(e)
      }

      e$message
    }
  )
}

check_system_dependency <- function(
  cmd,
  dependency_name,
  documentation_url,
  additional_message = NULL
) {
  message <- c(
    glue::glue("Do you have {dependency_name} installed?"),
    glue::glue("Check {documentation_url} for details."),
    additional_message
  )

  tryCatch(
    system_cmd_version(cmd, TRUE),
    error = function(e) cli::cli_abort(message)
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
#' @export
diagnostics <- function() {
  writeLines(c(
    paste(Sys.info()[c("sysname", "release", "version")], collapse = " "),
    R.version.string,
    paste("rhino:", utils::packageVersion("rhino")),
    paste("node:", system_cmd_version("node"))
  ))
}
