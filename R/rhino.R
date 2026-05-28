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

handle_existing_file <- function(path) {
  choice <- prompt_file_conflict(path)

  if (choice != 2) {
    cli::cli_alert_info("Aborted. {.file {path}} was not changed.")
    return(FALSE)
  }

  backup <- next_backup_path(path)
  fs::file_move(path, backup)
  cli::cli_alert_info("Existing {.file {path}} backed up as {.file {backup}}.")
  TRUE
}

prompt_file_conflict <- function(path) {
  if (!interactive()) {
    cli::cli_abort(
      c(
        "{.file {path}} already exists.",
        i = "Remove or rename it before running this command."
      ),
      call = NULL
    )
  }
  utils::menu(
    choices = c(
      "Abort",
      sprintf("Back up existing %s and create a new one", path)
    ),
    title = sprintf("%s already exists. What would you like to do?", path)
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
