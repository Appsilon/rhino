test_that("r6_usage_linter allows R6Class and R6$R6Class function calls.", {
  linter <- r6_usage_linter()

  good_r6_class_1 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      initialize = function(...) {
        # do something
      }
    )
  )
  "

  good_r6_class_2 <- "box::use(
    R6,
  )

  newClass <- R6$R6Class('newClass',
    public = list(
      initialize = function(...) {
        # do something
      }
    )
  )
  "

  lintr::expect_lint(good_r6_class_1, NULL, linter)
  lintr::expect_lint(good_r6_class_2, NULL, linter)
})


test_that("r6_usage_linter skips valid R6 classes.", {
  linter <- r6_usage_linter()

  good_r6_class_1 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )
  "

  lintr::expect_lint(good_r6_class_1, NULL, linter)
})

test_that("r6_usage_linter handles more than one good R6 classes in the same file.", {
  linter <- r6_usage_linter()

  good_r6_class_1 <- "box::use(
    R6[R6Class],
  )

  firstClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )

  secondClass <- R6Class('secondClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )
  "

  lintr::expect_lint(good_r6_class_1, NULL, linter)
})

test_that("r6_usage_linter skips non-R6 class definitions in the same file.", {
  linter <- r6_usage_linter()

  good_r6_class_1 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )

  some_function <- function() {
    non_existing_function()
  }

  fs$path_file('path/to/file')
  "

  lintr::expect_lint(good_r6_class_1, NULL, linter)
})

test_that("r6_usage_linter blocks unused private objects (properties and methods).", {
  linter <- r6_usage_linter()
  lint_message <- rex::rex("Private object not used.")

  # property
  bad_r6_class_1 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {

      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )
  "

  # emthod
  bad_r6_class_2 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {

      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )
  "

  lintr::expect_lint(bad_r6_class_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_r6_class_2, list(message = lint_message), linter)
})

test_that("r6_usage_linter blocks unused private objects in second class", {
  linter <- r6_usage_linter()
  lint_message <- rex::rex("Private object not used.")

  # property
  bad_r6_class_1 <- "box::use(
    R6[R6Class],
  )

  firstClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )

  secondClass <- R6Class('secondClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {

      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )"

  # emthod
  bad_r6_class_2 <- "box::use(
    R6[R6Class],
  )

  firstClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {

      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )

  secondClass <- R6Class('secondClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )"

  lintr::expect_lint(bad_r6_class_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_r6_class_2, list(message = lint_message), linter)
})


test_that("r6_usage_linter blocks internal calls to invalid public objects", {
  linter <- r6_usage_linter()
  lint_message <- rex::rex("Internal object call not found.")

  # property
  bad_r6_class_1 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$no_such_property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )
  "

  # method
  bad_r6_class_2 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$no_such_method(value)
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )
  "

  lintr::expect_lint(bad_r6_class_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_r6_class_2, list(message = lint_message), linter)
})

test_that("r6_usage_linter blocks internal calls to invalid active objects", {
  linter <- r6_usage_linter()
  lint_message <- rex::rex("Internal object call not found.")

  bad_r6_class_1 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
        self$no_such_active_binding <- value
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )
  "

  lintr::expect_lint(bad_r6_class_1, list(message = lint_message), linter)
})

test_that("r6_usage_linter blocks internal calls to invalid private objects", {
  linter <- r6_usage_linter()
  lint_message <- rex::rex("Internal object call not found.")

  # property
  bad_r6_class_1 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
        private$no_such_property <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )
  "

  # method
  bad_r6_class_2 <- "box::use(
    R6[R6Class],
  )

  newClass <- R6Class('newClass',
    public = list(
      property = NULL,
      initialize = function(value) {
        self$property <- value
      },
      external_method = function(value) {
        private$internal_method(value)
        private$no_such_method(value)
      }
    ),
    active = list(
      binding = function(value) {
        private$secret <- value
      }
    ),
    private = list(
      secret = NULL,
      internal_method = function(value) {
        private$another_method()
      },
      another_method = function() {
        # do something
      }
    )
  )
  "

  lintr::expect_lint(bad_r6_class_1, list(message = lint_message), linter)
  lintr::expect_lint(bad_r6_class_2, list(message = lint_message), linter)
})
