test_that("handle aliased package", {
  "box::use(
    alias = stringr,
  )
  
  alias$str_sub()
  "
})

test_that("handle aliased attached functions from packages", {
  "box::use(
    stringr[alias = str_sub],
  )
  
  alias()
  "
})

test_that("handle dplyr pipeline objects", {
  "box::use(
    dplyr[`%>%`, select, filter]
  )
  
  mtcars %>%
    select(mpg, cyl) %>%
    filter(mpg <= 10)
  "
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
})

test_that("handle function signature objects", {
  "
  some_function <- function(x) {
    x
  }
  "
})

test_that("handle function signature objects - function", {
  "
  some_function <- function(FUN = NULL) {
    FUN()
  }
  "
})

test_that("handle function signature objects - list", {
  "
  some_function <- function(x) {
    x$element
  }
  "
})

test_that("handle function signature objects - list of functions", {
  "
  some_function <- function(x) {
    x$fun()
  }"
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
})

test_that("handle attached box module", {
  "
  box::use(
    path/to/module
  )
  
  module$some_function()
  module$some_data
  "
})

test_that("handle attached box module functions", {
  "
  box::use(
    path/to/module[some_function]
  )

  some_function()  
  "
})

test_that("handle attached box module data objects", {
  "
  box::use(
    path/to/module[some_data]
  )
  
  some_data
  "
})

test_that("handle three-dots box module", {
  "
  box::use(
    path/to/module[...]
  )
  
  some_function()
  "
})

test_that("handle attached R6 class from box module" {
  "box::use(
    path/to/moduel[some_class]
  )
  
  new_object <- some_class$new()
  new_object$some_method()
  new_object$some_property
  "
})

test_that("handle aliased attached box module", {
  "
  box::use(
    alias = path/to/module
  )
  
  alias$some_function()
  alias$some_data
  "
})

test_that("handle aliased functions from box module", {
  "
  box::use(
    path/to/module[alias = some_function]
  )

  alias()  
  "
})

test_that("handle aliased R6 class from box module", {
  "box::use(
    path/to/moduel[alias = some_class]
  )
  
  new_object <- alias$new()
  new_object$some_method()
  new_object$some_property
  "
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
})
