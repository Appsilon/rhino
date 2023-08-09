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

addin_format_code <- function() {
  selected_code <- rstudioapi::getActiveDocumentContext()$path
  if (selected_code != "") {
    rhino::format_r(selected_code)
  } else {
    path <- rstudioapi::selectFile(
      caption = "Select Code script",
      filter = "(*.R)",
      existing = TRUE
    )
    rhino::format_r(path)
  }
}

addin_lint_code <- function() {
  rhino::lint_r(rstudioapi::getActiveProject())
}

addin_test_app <- function() {
  rhino::test_r()
}

addin_build_js <- function() {
  type <- rstudioapi::showQuestion(
    title = "With Watch?",
    message = "Would you like to add watch argument?",
    ok = "use watch",
    cancel = "without watch"
  )
  if (type) {
    path <- fs::path_package("rhino", "rstudio", "addins", "watch_js.r")
    rstudioapi::jobRunScript(path)
  } else {
    rhino::build_js(type)
  }
}

addin_build_sass <- function() {
  type <- rstudioapi::showQuestion(
    title = "With Watch?",
    message = "Would you like to add watch argument?",
    ok = "use watch",
    cancel = "without watch"
  )
  if (type) {
    path <- fs::path_package("rhino", "rstudio", "addins", "watch_sass.r")
    rstudioapi::jobRunScript(path)
  } else {
    rhino::build_sass(type)
  }
}

addin_lint_js <- function() {
  type <- rstudioapi::showQuestion(
    title = "Fix automatically?",
    message = "Would you like to lint js automatically?"
  )
  rhino::lint_js(type)
}

addin_lint_sass <- function() {
  type <- rstudioapi::showQuestion(
    title = "Fix automatically?",
    message = "Would you like to lint sass automatically?"
  )
  rhino::lint_sass(type)
}

addin_test_e2e <- function() {
  type <- rstudioapi::showQuestion(
    title = "Run interactive e2e test?",
    message = "Would you like to run interactive e2e test?"
  )
  rhino::test_e2e(type)
}
