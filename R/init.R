#' Create Rhino application
#'
#' Generates the file structure of a Rhino application.
#' Can be used to start a fresh project or to migrate an existing Shiny application
#' created without Rhino.
#'
#' The recommended steps for migrating an existing Shiny application to Rhino:
#' 1. Put all app files in the `app` directory,
#' so that it can be run with `shiny::shinyAppDir("app")` (assuming all dependencies are installed).
#' 2. If you have a list of dependencies in form of `library()` calls,
#' put them in the `dependencies.R` file.
#' If this file does not exist, Rhino will generate it based on `renv::dependencies("app")`.
#' 3. If your project uses `{renv}`, put `renv.lock` and `renv` directory in the project root.
#' Rhino will try to only add the necessary dependencies to your lockfile.
#' 4. Run `rhino::init()` in the project root.
#'
#' @param dir Name of the directory to create application in.
#' @param github_actions_ci Should the GitHub Actions CI be added?
#' @param agents_instructions Should an `AGENTS.md` file with guidance
#' for AI coding agents be added?
#' @param rhino_version When using an existing `renv.lock` file,
#' Rhino will install itself using `renv::install(rhino_version)`.
#' You can provide this argument to use a specific version / source, e.g.`"Appsilon/rhino@v0.4.0"`.
#' @param force Boolean; force initialization?
#' By default, Rhino will refuse to initialize a project in the home directory.
#' @return None. This function is called for side effects.
#'
#' @export
init <- function(
  dir = ".",
  github_actions_ci = TRUE,
  agents_instructions = TRUE,
  rhino_version = "rhino",
  force = FALSE
)  {
  is_home <- is_dir_home(dir = dir)

  if (!is_home || force) {
    init_impl(
      dir = dir,
      github_actions_ci = github_actions_ci,
      agents_instructions = agents_instructions,
      rhino_version = rhino_version,
      new_project_wizard = FALSE
    )
  } else {
    cli::cli_abort(
      c(
        "Refusing to create a Rhino app in home directory {.path {dir}}!",
        i = "Set {.code force = TRUE} to force initialization."
      ),
      call = NULL
    )
  }
}

init_rstudio <- function(
  dir = ".",
  github_actions_ci = TRUE,
  agents_instructions = TRUE,
  rhino_version = "rhino"
) {
  init_impl(
    # No need to check if `dir` is home,
    # because RStudio's new project wizard always creates a new directory.
    dir = dir,
    github_actions_ci = github_actions_ci,
    agents_instructions = agents_instructions,
    rhino_version = rhino_version,
    new_project_wizard = TRUE
  )
}

init_impl <- function(
  dir,
  github_actions_ci,
  agents_instructions,
  rhino_version,
  new_project_wizard
) {
  fs::dir_create(dir)
  withr::with_dir(dir, {
    create_rproj_file(new_project_wizard)
    init_renv(rhino_version)
    create_app_structure()
    create_unit_tests_structure()
    create_e2e_tests_structure()
    if (isTRUE(github_actions_ci)) add_github_actions_ci()
    if (isTRUE(agents_instructions)) use_agents_md()
  })
}

handle_old_rprofile <- function() {
  if (fs::file_exists(".Rprofile")) {
    cli::cli_alert_warning("Renaming existing '.Rprofile' to 'old.Rprofile'.")
    fs::file_move(".Rprofile", "old.Rprofile")
  }
}

init_renv <- function(rhino_version) {
  handle_old_rprofile()
  write_dependencies(read_dependencies())
  copy_template("renv")
  if (fs::file_exists("renv.lock")) {
    renv::load()
    renv::restore(prompt = FALSE, clean = TRUE)
    renv::install(rhino_version)
    renv::snapshot()
  } else {
    # With `restart = TRUE`, RStudio fails to create a project
    # with an "Unable to establish connection with R session" message.
    renv::init(restart = FALSE)
  }
  cli::cli_alert_success("Initialized renv.")
}

create_rproj_file <- function(new_project_wizard) {
  if (!new_project_wizard && !rproj_exists()) {
    copy_rproj()
    cli::cli_alert_success("Rproj file created.")
  }
}

create_app_structure <- function() {
  copy_template("app_structure")
  cli::cli_alert_success("Application structure created.")
}

add_github_actions_ci <- function() {
  copy_template("github_ci")
  cli::cli_alert_success("Github Actions CI added.")
}

create_unit_tests_structure <- function() {
  copy_template("unit_tests")
  cli::cli_alert_success("Unit tests structure created.")
}

create_e2e_tests_structure <- function() {
  copy_template("e2e_tests")
  cli::cli_alert_success("E2E tests structure created.")
}

#' Add AGENTS.md
#'
#' Adds an `AGENTS.md` file with guidance for AI coding agents
#' (e.g. GitHub Copilot, Claude Code) to a Rhino application.
#'
#' This file is added automatically by [init()] unless `agents_instructions = FALSE`.
#' Use this function to add it to an existing Rhino project.
#'
#' If `AGENTS.md` already exists in an interactive session, you will be prompted
#' to either abort (the default) or back up the existing file as `AGENTS.md.bak`
#' (with a numeric suffix if `AGENTS.md.bak` is also taken) and create a new one.
#' In non-interactive sessions the function aborts with an error.
#'
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Add AGENTS.md to the current Rhino project.
#'   use_agents_md()
#' }
#' @export
use_agents_md <- function() {
  if (fs::file_exists("AGENTS.md") && !handle_existing_agents_md()) {
    return(invisible())
  }
  copy_template("agents_md")
  cli::cli_alert_success("AGENTS.md added.")
}

handle_existing_agents_md <- function() {
  choice <- prompt_agents_md_conflict()

  if (choice != 2) {
    cli::cli_alert_info("Aborted. {.file AGENTS.md} was not changed.")
    return(FALSE)
  }

  backup <- next_backup_path("AGENTS.md")
  fs::file_move("AGENTS.md", backup)
  cli::cli_alert_info("Existing {.file AGENTS.md} backed up as {.file {backup}}.")
  TRUE
}

prompt_agents_md_conflict <- function() {
  if (!interactive()) {
    cli::cli_abort(
      c(
        "{.file AGENTS.md} already exists.",
        i = "Remove or rename it before running {.code use_agents_md()}."
      ),
      call = NULL
    )
  }
  utils::menu(
    choices = c(
      "Abort",
      "Back up existing AGENTS.md and create a new one"
    ),
    title = "AGENTS.md already exists. What would you like to do?"
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

is_dir_home <- function(dir) {
  # For Windows, home by default should be C:\Users\user\Documents.
  # For Unix, home by default should be /home/user.
  home_path <- normalizePath("~")
  dir_path <- normalizePath(dir, mustWork = FALSE)
  dir_path == home_path
}
