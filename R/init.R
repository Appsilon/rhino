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
#' @param e2e_tests Should the Cypress end-to-end test structure be added?
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
  e2e_tests = TRUE,
  rhino_version = "rhino",
  force = FALSE
)  {
  is_home <- is_dir_home(dir = dir)

  if (!is_home || force) {
    init_impl(
      dir = dir,
      github_actions_ci = github_actions_ci,
      agents_instructions = agents_instructions,
      e2e_tests = e2e_tests,
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
  e2e_tests = TRUE,
  rhino_version = "rhino"
) {
  init_impl(
    # No need to check if `dir` is home,
    # because RStudio's new project wizard always creates a new directory.
    dir = dir,
    github_actions_ci = github_actions_ci,
    agents_instructions = agents_instructions,
    e2e_tests = e2e_tests,
    rhino_version = rhino_version,
    new_project_wizard = TRUE
  )
}

init_impl <- function(
  dir,
  github_actions_ci,
  agents_instructions,
  e2e_tests,
  rhino_version,
  new_project_wizard
) {
  fs::dir_create(dir)
  withr::with_dir(dir, {
    create_rproj_file(new_project_wizard)
    init_renv(rhino_version)
    create_app_structure()
    create_unit_tests_structure()
    if (isTRUE(e2e_tests)) use_e2e_tests()
    if (isTRUE(github_actions_ci)) use_github_actions_ci()
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

create_unit_tests_structure <- function() {
  copy_template("unit_tests")
  cli::cli_alert_success("Unit tests structure created.")
}

#' Add end-to-end tests
#'
#' Adds the Rhino Cypress end-to-end test structure to a Rhino application:
#' the `tests/cypress.config.js` file and the `tests/cypress/` directory.
#'
#' This structure is added automatically by [init()].
#' Use this function to add it to an existing Rhino project.
#'
#' If `tests/cypress.config.js` or the `tests/cypress/` directory already exist
#' in an interactive session, you will be prompted to either abort (the default)
#' or back up the existing paths (each moved to a `.bak` path) and create new
#' ones. In non-interactive sessions the function aborts with an error.
#'
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Add the end-to-end test structure to the current Rhino project.
#'   use_e2e_tests()
#' }
#' @export
use_e2e_tests <- function() {
  conflicts <- c(
    fs::path("tests", "cypress"),
    fs::path("tests", "cypress.config.js")
  )
  if (!handle_existing_paths(conflicts)) {
    return(invisible())
  }
  copy_template("e2e_tests")
  cli::cli_alert_success("E2E tests structure created.")
}

#' Add GitHub Actions CI
#'
#' Adds the Rhino GitHub Actions CI workflow (`.github/workflows/rhino-test.yml`)
#' to a Rhino application.
#'
#' This workflow is added automatically by [init()] unless `github_actions_ci = FALSE`.
#' Use this function to add it to an existing Rhino project.
#'
#' If `.github/workflows/rhino-test.yml` already exists in an interactive session,
#' you will be prompted to either abort (the default) or back up the existing file
#' as `rhino-test.yml.bak` (with a numeric suffix if `rhino-test.yml.bak` is also
#' taken) and create a new one. In non-interactive sessions the function aborts
#' with an error.
#'
#' @return None. This function is called for side effects.
#'
#' @examples
#' if (interactive()) {
#'   # Add the GitHub Actions CI workflow to the current Rhino project.
#'   use_github_actions_ci()
#' }
#' @export
use_github_actions_ci <- function() {
  workflow <- fs::path(".github", "workflows", "rhino-test.yml")
  if (!handle_existing_paths(workflow)) {
    return(invisible())
  }
  copy_template("github_ci")
  cli::cli_alert_success("GitHub Actions CI added.")
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
  if (!handle_existing_paths("AGENTS.md")) {
    return(invisible())
  }
  copy_template("agents_md")
  cli::cli_alert_success("AGENTS.md added.")
}

is_dir_home <- function(dir) {
  # For Windows, home by default should be C:\Users\user\Documents.
  # For Unix, home by default should be /home/user.
  home_path <- normalizePath("~")
  dir_path <- normalizePath(dir, mustWork = FALSE)
  dir_path == home_path
}
