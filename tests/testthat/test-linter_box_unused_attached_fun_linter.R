test_that("box_unused_attached_fun_linter skips used box-attached functions.", {
  linter <- box_unused_attached_fun_linter()

  good_box_usage <- "box::use(
    fs[dir_ls, path_file],
    shiny[...],
    stringr
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  dir_ls('path')
  path_file('path/to/file')
  stringr$str_sub('text', 1, 2)
  is.reactive(x)
  "

  lintr::expect_lint(good_box_usage, NULL, linter)
})

test_that("box_unused_attached_fun_linter blocks box-attached functions unused.", {
  linter <- box_unused_attached_fun_linter()
  lint_message_1 <- rex::rex("Imported function unused.")

  # filter is unused
  bad_box_usage_1 <- "box::use(
    fs[dir_ls, path_file],
    shiny[...],
    stringr
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  path_file('path/to/file')
  stringr$str_sub('text', 1, 2)
  is.reactive(x)
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})
