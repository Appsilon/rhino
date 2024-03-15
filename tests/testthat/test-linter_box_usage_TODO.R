test_that("handle aliased package", {
  "box::use(
    alias = stringr,
  )
  
  alias$str_sub()
  "

  expect_true(TRUE)
})

test_that("handle aliased attached functions from packages", {
  "box::use(
    stringr[alias = str_sub],
  )
  
  alias()
  "

  expect_true(TRUE)
})

test_that("handle dplyr pipeline objects", {
  "box::use(
    dplyr[`%>%`, select, filter]
  )
  
  mtcars %>%
    select(mpg, cyl) %>%
    filter(mpg <= 10)
  "

  expect_true(TRUE)
})

test_that("handle curried functions", {
  "
  some_function <- function(x) {
    function(y) {
      
    }
  }
  
  this_fun <- some_function(1)
  this_fun(2)
  "

  expect_true(TRUE)
})

test_that("handle function signature objects", {
  "
  some_function <- function(x) {
    x
  }
  "

  expect_true(TRUE)
})

test_that("handle function signature objects - function", {
  "
  some_function <- function(FUN = NULL) {
    FUN()
  }
  "

  expect_true(TRUE)
})

test_that("handle function signature objects - list", {
  "
  some_function <- function(x) {
    x$element
  }
  "

  expect_true(TRUE)
})

test_that("handle function signature objects - list of functions", {
  "
  some_function <- function(x) {
    x$fun()
  }"

  expect_true(TRUE)
})

test_that("will not lint in function with ... signature", {
  # unused ...
  "
  some_function <- function(x, y, ...) {
    some_value <- x + y
  }
  "

  # passed ...
  "
  another_function <- function(x, y, ...) {
    some_value <- x + y
    third_function(some_value, ...)
  }
  "

  expect_true(TRUE)
})

test_that("handle adding members to an existing R6 class", {
  "
  SomeClass <- R6('SomeClass', 
    public = list()
  )
  
  SomeClass$set('public', 'x', 10)
  
  s <- SomeClass$new()
  s$x
  "

  expect_true(TRUE)
})

test_that("handle cloned R6 objects", {
  "
  s <- SomeClass$new()
  
  t <- s$clone()
  t$x
  "

  expect_true(TRUE)
})

test_that("handle attached box module", {
  "
  box::use(
    path/to/module
  )
  
  module$some_function()
  module$some_data
  "

  expect_true(TRUE)
})

test_that("handle attached box module functions", {
  "
  box::use(
    path/to/module[some_function]
  )

  some_function()  
  "

  expect_true(TRUE)
})

test_that("handle attached box module data objects", {
  "
  box::use(
    path/to/module[some_data]
  )
  
  some_data
  "

  expect_true(TRUE)
})

test_that("handle three-dots box module", {
  "
  box::use(
    path/to/module[...]
  )
  
  some_function()
  "

  expect_true(TRUE)
})

test_that("handle attached R6 class from box module", {
  "box::use(
    path/to/moduel[some_class]
  )
  
  new_object <- some_class$new()
  new_object$some_method()
  new_object$some_property
  "

  expect_true(TRUE)
})

test_that("handle aliased attached box module", {
  "
  box::use(
    alias = path/to/module
  )
  
  alias$some_function()
  alias$some_data
  "

  expect_true(TRUE)
})

test_that("handle aliased functions from box module", {
  "
  box::use(
    path/to/module[alias = some_function]
  )

  alias()  
  "

  expect_true(TRUE)
})

test_that("handle aliased R6 class from box module", {
  "box::use(
    path/to/moduel[alias = some_class]
  )
  
  new_object <- alias$new()
  new_object$some_method()
  new_object$some_property
  "

  expect_true(TRUE)
})

test_that("not locally used exported functions and data objects in box modules should not lint", {
  "box::use(
  )
  
  #' @export
  exported_function <- function() {
  
  }
  
  #' @export
  exported_data <- ''
  "

  expect_true(TRUE)
})

test_that("all local private functions in box module should be used", {
  "box::use(
  )
  
  #' @export
  public_function <- function() {
    private_function()
  }
  
  private_function <- function() {
  
  }
  "

  expect_true(TRUE)
})

test_that("all local private data objects in box module should be used", {
  "box::use(
  )
  
  #' @export
  public_function <- function() {
    private_data
  }
  
  private_data <- 'something'
  "

  expect_true(TRUE)
})
