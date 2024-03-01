test_that("box_alphabetical_calls_linter() skips allowed box::use() calls", {
  linter <- box_alphabetical_calls_linter()

  good_box_calls_1 <- "box::use(
    dplyr,
    shiny,
    tidyr,
  )"

  good_box_calls_2 <- "box::use(
    path/to/fileA,
    path/to/fileB,
    path/to/fileC,
  )"

  good_box_calls_3 <- "box::use(
    dplyr[filter, mutate, select],
    shiny,
    tidyr[long, pivot, wide],
  )"

  good_box_calls_4 <- "box::use(
    path/to/fileA[functionA, functionB, functionC],
    path/to/fileB,
    path/to/fileC[functionD, functionE, functionF],
  )"

  lintr::expect_lint(good_box_calls_1, NULL, linter)
  lintr::expect_lint(good_box_calls_2, NULL, linter)
  lintr::expect_lint(good_box_calls_3, NULL, linter)
  lintr::expect_lint(good_box_calls_4, NULL, linter)
})

test_that("box_alphabetical_calls_linter() ignores aliases in box::use() calls", {
  linter <- box_alphabetical_calls_linter()

  good_box_calls_alias_1 <- "box::use(
    dplyr,
    alias = shiny,
    tidyr,
  )"

  good_box_calls_alias_2 <- "box::use(
    path/to/fileA,
    a = path/to/fileB,
    path/to/fileC,
  )"

  good_box_calls_alias_3 <- "box::use(
    dplyr[filter, alias = mutate, select],
    shiny,
    tidyr[long, pivot, wide],
  )"

  good_box_calls_alias_4 <- "box::use(
    path/to/fileA[functionA, alias = functionB, functionC],
    path/to/fileB,
    path/to/fileC[functionD, functionE, functionF],
  )"

  lintr::expect_lint(good_box_calls_alias_1, NULL, linter)
  lintr::expect_lint(good_box_calls_alias_2, NULL, linter)
  lintr::expect_lint(good_box_calls_alias_3, NULL, linter)
  lintr::expect_lint(good_box_calls_alias_4, NULL, linter)
})

test_that("box_alphabetical_calls_linter() blocks unsorted imports in box::use() call", {
  linter <- box_alphabetical_calls_linter()

  bad_box_calls_1 <- "box::use(
    dplyr,
    tidyr,
    shiny,
  )"

  bad_box_calls_2 <- "box::use(
    path/to/fileC,
    path/to/fileB,
    path/to/fileA,
  )"

  bad_box_calls_3 <- "box::use(
    dplyr[filter, mutate, select],
    shiny,
    tidyr[wide, pivot, long],
  )"

  bad_box_calls_4 <- "box::use(
    dplyr[select, mutate, filter],
    shiny,
    tidyr[wide, pivot, long],
  )"

  bad_box_calls_5 <- "box::use(
    path/to/fileA[functionC, functionB, functionA],
    path/to/fileB,
    path/to/fileC[functionD, functionE, functionF],
  )"

  bad_box_calls_6 <- "box::use(
    path/to/fileA[functionC, functionB, functionA],
    path/to/fileB,
    path/to/fileC[functionF, functionE, functionD],
  )"

  lint_message <- rex::rex("Module and function imports must be sorted alphabetically.")

  lintr::expect_lint(bad_box_calls_1, list(
    list(message = lint_message, line_number = 3),
    list(message = lint_message, line_number = 4)
  ), linter)
  lintr::expect_lint(bad_box_calls_2, list(
    list(message = lint_message, line_number = 2),
    list(message = lint_message, line_number = 4)
  ), linter)
  lintr::expect_lint(bad_box_calls_3, list(
    list(message = lint_message, line_number = 4, column_number = 11),
    list(message = lint_message, line_number = 4, column_number = 24)
  ), linter)
  lintr::expect_lint(bad_box_calls_4, list(
    list(message = lint_message, line_number = 2, column_number = 11),
    list(message = lint_message, line_number = 2, column_number = 27),
    list(message = lint_message, line_number = 4, column_number = 11),
    list(message = lint_message, line_number = 4, column_number = 24)
  ), linter)
  lintr::expect_lint(bad_box_calls_5, list(
    list(message = lint_message, line_number = 2, column_number = 19),
    list(message = lint_message, line_number = 2, column_number = 41)
  ), linter)
  lintr::expect_lint(bad_box_calls_6, list(
    list(message = lint_message, line_number = 2, column_number = 19),
    list(message = lint_message, line_number = 2, column_number = 41),
    list(message = lint_message, line_number = 4, column_number = 19),
    list(message = lint_message, line_number = 4, column_number = 41)
  ), linter)
})
