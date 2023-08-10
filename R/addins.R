read_addin <- function(...) {
  path <- fs::path_package("rhino", "rstudio", "addins", ...)
  readChar(path, file.info(path)$size)
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
  rhino::lint_r(rstudioapi::getActiveProject())
}

addin_test_r <- function() {
  rhino::test_r()
}

addin_build_js <- function() {
  type <- rstudioapi::showQuestion(
    title = "Watch argument",
    message = "Keep the process running and rebuilding Javascript whenever source files change?",
    ok = "Yes",
    cancel = "No"
  )
  if (type) {
    path <- fs::path_package("rhino", "rstudio", "addins", "watch_js.R")
    rstudioapi::jobRunScript(path, workingDir = rstudioapi::getActiveProject())
  } else {
    rhino::build_js(type)
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
    path <- fs::path_package("rhino", "rstudio", "addins", "watch_sass.R")
    rstudioapi::jobRunScript(path, workingDir = rstudioapi::getActiveProject())
  } else {
    rhino::build_sass(type)
  }
}

addin_lint_js <- function() {
  type <- rstudioapi::showQuestion(
    title = "Fix automatically?",
    message = "Would you like to automatically fix problems?",
    ok = "Yes",
    cancel = "No"
  )
  rhino::lint_js(type)
}

addin_lint_sass <- function() {
  type <- rstudioapi::showQuestion(
    title = "Fix automatically?",
    message = "Would you like to automatically fix problems?",
    ok = "Yes",
    cancel = "No"
  )
  rhino::lint_sass(type)
}

addin_test_e2e <- function() {
  type <- rstudioapi::showQuestion(
    title = "Run interactive mode?",
    message = "Should Cypress be run in the interactive mode?",
    ok = "Yes",
    cancel = "No"
  )
  rhino::test_e2e(type)
}
