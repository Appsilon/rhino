run_background <- function(file) {
  path <- fs::path_package("rhino", "rstudio", "addins", file)
  rstudioapi::jobRunScript(path, workingDir = rstudioapi::getActiveProject())
}

addin_module <- function() {
  module_path <- fs::path_package("rhino", "rstudio", "addins", "module.R")
  file_path <- rstudioapi::selectFile(
    caption = "Module name and location",
    path = fs::path("app", "view"),
    filter = ".R",
    label = "Save",
    existing = FALSE
  )
  if (is.null(file_path)) {
    message("Module creation canceled.")
    return()
  }

  if (tools::file_ext(file_path) == "") {
    file_path <- glue::glue("{file_path}.R")

    if (fs::file_exists(file_path)) {
      overwrite <- rstudioapi::showQuestion(
        title = "File already exists",
        message = "Would you like to overwrite it?",
        ok = "Yes",
        cancel = "No"
      )

      if (!overwrite) {
        message("Module creation canceled.")
        return()
      }
    }
  }

  fs::file_copy(module_path, file_path, overwrite = TRUE)
  fs::file_show(file_path)
}

addin_format_r <- function() {
  selected_code <- rstudioapi::getActiveDocumentContext()$path
  if (selected_code != "") {
    rhino::format_r(selected_code)
  } else {
    path <- rstudioapi::selectFile(
      caption = "Select R script",
      filter = "(*.R)",
      existing = TRUE
    )
    rhino::format_r(path)
  }
}

addin_lint_r <- function() {
  run_background("lint_r.R")
}

addin_test_r <- function() {
  run_background("test_r.R")
}

addin_build_js <- function() {
  type <- rstudioapi::showQuestion(
    title = "Watch argument",
    message = "Keep the process running and rebuilding Javascript whenever source files change?",
    ok = "Yes",
    cancel = "No"
  )
  if (type) {
    run_background("build_js_watch.R")
  } else {
    run_background("build_js.R")
  }
}

addin_build_sass <- function() {
  type <- rstudioapi::showQuestion(
    title = "Watch argument",
    message = "Keep the process running and rebuilding Sass whenever source files change?",
    ok = "Yes",
    cancel = "No"
  )
  if (type) {
    run_background("build_sass_watch.R")
  } else {
    run_background("build_sass.R")
  }
}

addin_lint_js <- function() {
  type <- rstudioapi::showQuestion(
    title = "Fix automatically?",
    message = "Would you like to automatically fix problems?",
    ok = "Yes",
    cancel = "No"
  )
  if (type) {
    run_background("lint_js_fix.R")
  } else {
    run_background("lint_js.R")
  }
}

addin_lint_sass <- function() {
  type <- rstudioapi::showQuestion(
    title = "Fix automatically?",
    message = "Would you like to automatically fix problems?",
    ok = "Yes",
    cancel = "No"
  )
  if (type) {
    run_background("lint_sass_fix.R")
  } else {
    run_background("lint_sass.R")
  }
}

addin_test_e2e <- function() {
  type <- rstudioapi::showQuestion(
    title = "Run interactive mode?",
    message = "Should Cypress be run in the interactive mode?",
    ok = "Yes",
    cancel = "No"
  )
  if (type) {
    run_background("test_e2e_int.R")
  } else {
    run_background("test_e2e.R")
  }
}
