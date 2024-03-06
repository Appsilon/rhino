test_that("box_usage_linter skips allowed box-imported package functions", {
  linter <- box_usage_linter()
  
  good_box_call_1 <- "box::use(
    dplyr[`%>%`, select, filter],
  )

  mtcars %>%
    select(mpg, cyl) %>%
    filter(mpg <= 10)
  "

  lintr::expect_lint(good_box_call_1, NULL, linter)
})

test_that("box_usage_linter blocks functions not box-imported", {
  linter <- box_usage_linter()
  lint_message <- "Function not imported."
  
  bad_box_call_1 <- "box::use(
    dplyr[`%>%`, select],
  )
  
  mtcars %>%
    select(mpg, cyl) %>%
    filter(mpg <= 10)
  "
  
  lintr::expect_lint(bad_box_call_1, list(message = lint_message), linter)
})

test_that("box_usage_linter blocks box-imported functions unused", {
  linter <- box_usage_linter()
  lint_message <- "Imported function unused."
  
  bad_box_call_1 <- "box::use(
    dplyr[`%>%`, select, filter],
  )
  
  mtcars %>%
    select(mpg, cyl)
  "
  
  lintr::expect_lint(bad_box_call_1, list(message = lint_message), linter)
})