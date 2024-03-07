test_that("box_pkg_fun_exists_linter skips valid package-function attachments", {
  linter <- box_pkg_fun_exists_linter()

  good_box_call_1 <- "box::use(
    glue[glue, glue_sql, trim],
    shiny,
    fs[path_file],
  )
  "

  lintr::expect_lint(good_box_call_1, NULL, linter)
})

test_that("box_pkg_fun_exists_linter blocks functions that do not exist in package", {
  linter <- box_pkg_fun_exists_linter()
  lint_message <- rex::rex("Function not exported by package.")

  bad_box_call_1 <- "box::use(
    glue[glue, xyz, trim],
    shiny,
    fs[path_file],
  )
  "

  lintr::expect_lint(bad_box_call_1, list(message = lint_message), linter)
})
