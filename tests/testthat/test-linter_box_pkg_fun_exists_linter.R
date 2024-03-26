test_that("box_pkg_fun_exists_linter skips valid package-function attachments", {
  linter <- box_pkg_fun_exists_linter()

  good_box_usage_1 <- "box::use(
    fs[path_file],
    glue[glue, glue_sql, trim],
    shiny,
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )
  "

  lintr::expect_lint(good_box_usage_1, NULL, linter)
})

test_that("box_pkg_fun_exists_linter blocks functions that do not exist in package", {
  linter <- box_pkg_fun_exists_linter()
  lint_message <- rex::rex("Function not exported by package.")

  bad_box_usage_1 <- "box::use(
    fs[path_file],
    glue[glue, xyz, trim],
    shiny,
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message), linter)
})
