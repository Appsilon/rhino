test_that("box_pkg_fun_exists_linter allows functions exported by package", {
  linter <- box_pkg_fun_exists_linter()

  bad_box_usage <- "box::use(
    glue[glue, glue_sql],
    fs[path_file],
  )
  "

  lintr::expect_lint(bad_box_usage, NULL, linter)
})

test_that("box_pkg_fun_exists_linter blocks functions not exported by package", {
  linter <- box_pkg_fun_exists_linter()
  lint_message <- rex::rex("Function not exported by package.")

  bad_box_usage <- "box::use(
    glue[glue, xyz],
    fs[path_file],
  )
  
  glue$xyz('Function does not exist.')
  "

  lintr::expect_lint(bad_box_usage, list(message = lint_message), linter)
})
