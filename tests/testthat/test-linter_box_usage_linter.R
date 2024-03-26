test_that("box_usage_linter skips allowed package[function] attachment.", {
  linter <- box_usage_linter()

  good_box_usage_1 <- "box::use(
    dplyr[`%>%`, select, filter],
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  mtcars %>%
    select(mpg, cyl) %>%
    filter(mpg <= 10)
  "

  lintr::expect_lint(good_box_usage_1, NULL, linter)
})

test_that("box_usage_linter skips allowed package attachment", {
  linter <- box_usage_linter()

  good_box_usage_2 <- "box::use(
    shiny[NS],
    glue,
    fs[path_file],
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  name <- 'Fred'
  glue$glue('My name is {name}.')

  path_file('dir/file.zip')

  ns <- NS()
  "

  lintr::expect_lint(good_box_usage_2, NULL, linter)
})

test_that("box_usage_linter skips allowed package[...] attachment", {
  linter <- box_usage_linter()

  good_box_usage_3 <- "box::use(
    glue[...]
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  name <- 'Fred'
  glue_sql('My name is {name}.')
  "

  lintr::expect_lint(good_box_usage_3, NULL, linter)
})

test_that("box_usage_linter skips allowed base packages functions", {
  linter <- box_usage_linter()

  good_box_usage_4 <- "box::use(
    dplyr[`%>%`, filter, pull],
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  mpg <- mtcars %>%
    filter(mpg <= 10) %>%
    pull(mpg)

  mean(mpg)
  "

  lintr::expect_lint(good_box_usage_4, NULL, linter)
})

test_that("box_usage_linter blocks package functions not box-imported", {
  linter <- box_usage_linter()
  lint_message_1 <- rex::rex("Function not imported.")

  # filter not imported
  bad_box_usage_1 <- "box::use(
    dplyr[`%>%`, select],
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  mtcars %>%
    select(mpg, cyl) %>%
    mutate(
      m = mean(mpg)
    )
  "

  lintr::expect_lint(bad_box_usage_1, list(message = lint_message_1), linter)
})

test_that("box_usage_linter blocks package functions exported by package", {
  linter <- box_usage_linter()
  lint_message_2 <- rex::rex("package$function does not exist.")

  # xyz is not exported by glue
  bad_box_usage_2 <- "box::use(
    glue,
    fs[path_file],
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  name <- 'Fred'
  glue$xyz('My name is {name}.')

  path_file('dir/file.zip')
  "

  lintr::expect_lint(bad_box_usage_2, list(message = lint_message_2), linter)
})

test_that("box_usage_linter blocks package functions not in global namespace", {
  linter <- box_usage_linter()
  lint_message_1 <- rex::rex("Function not imported.")

  # xyz function does not exist
  bad_box_usage_3 <- "box::use(
    glue[...]
  )
  
  box::use(
    path/to/module1,
    path/to/module2[a, b, c],
    path/to/module3[...]
  )

  name <- 'Fred'
  xyz('My name is {name}')
  "

  lintr::expect_lint(bad_box_usage_3, list(message = lint_message_1), linter)
})
