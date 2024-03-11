test_that("box_usage_linter skips allowed box-imported package functions", {
  linter <- box_usage_linter()

  good_box_usage_1 <- "box::use(
    dplyr[`%>%`, select, filter],
  )

  mtcars %>%
    select(mpg, cyl) %>%
    filter(mpg <= 10)
  "

  good_box_usage_2 <- "box::use(
    shiny[NS],
    glue,
    fs[path_file],
  )

  name <- 'Fred'
  glue$glue('My name is {name}.')

  path_file('dir/file.zip')

  ns <- NS()
  "

  good_box_usage_3 <- "box::use(
    glue[...]
  )

  name <- 'Fred'
  glue_sql('My name is {name}.')
  "

  good_box_usage_4 <- "box::use(
    dplyr[`%>%`, filter, pull],
  )

  mpg <- mtcars %>%
    filter(mpg <= 10) %>%
    pull(mpg)

  mean(mpg)
  "



  lintr::expect_lint(good_box_usage_1, NULL, linter)
  lintr::expect_lint(good_box_usage_2, NULL, linter)
  lintr::expect_lint(good_box_usage_3, NULL, linter)
  lintr::expect_lint(good_box_usage_4, NULL, linter)
})

test_that("box_usage_linter blocks functions not box-imported", {
  linter <- box_usage_linter()
  lint_message_1 <- rex::rex("Function not imported.")
  lint_message_2 <- rex::rex("package$function does not exist.")

  # filter not imported
  bad_box_usage_1 <- "box::use(
    dplyr[`%>%`, select],
  )

  mtcars %>%
    select(mpg, cyl) %>%
    mutate(
      m = mean(mpg)
    )
  "

  # xyz is not exported by glue
  bad_box_usage_2 <- "box::use(
    glue,
    fs[path_file],
  )

  name <- 'Fred'
  glue$xyz('My name is {name}.')

  path_file('dir/file.zip')
  "

  # xyz function does not exist
  bad_box_usage_3 <- "box::use(
    glue[...]
  )

  name <- 'Fred'
  xyz('My name is {name}')
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
  lintr::expect_lint(bad_box_usage_2, list(message = lint_message_2), linter)
  lintr::expect_lint(bad_box_usage_3, list(message = lint_message_1), linter)
})

test_that("box_usage_linter blocks box-imported functions unused", {
  linter <- box_usage_linter()
  lint_message_1 <- rex::rex("Imported function unused.")

  # filter is unused
  bad_box_usage_1 <- "box::use(
    dplyr[`%>%`, select, filter],
  )

  mtcars %>%
    select(mpg, cyl)
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})
