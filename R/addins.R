read_addin <- function(...) {
  path <- fs::path_package("rhino", "rstudio", "addins", ...)
  readChar(path, file.info(path)$size)
}

run_background <- function(file) {
  path <- fs::path_package("rhino", "rstudio", "addins", file)
  rstudioapi::jobRunScript(path, workingDir = rstudioapi::getActiveProject())
}

addin_module <- function() {
  rstudioapi::documentNew(
    read_addin("module.R"),
    type = "r",
    position = rstudioapi::document_position(0, 0),
    execute = FALSE
  )
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
    run_background("watch_js.R")
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
    run_background("watch_sass.R")
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
