RecursiveUnitTests <- R6::R6Class("RecursiveUnitTests",       # nolint
  public = list(
    initialize = function(path, filter = "test-.+\\.R$", recursive = TRUE) {
      if (length(path) > 1) {
        cli::cli_abort("Please provide a single path.")
      }
      private$path <- path
      private$filter <- filter
      private$recursive <- recursive

      private$get_valid_test_paths()
    },
    run_tests = function(...) {
      if (private$is_single_test_file()) {
        testthat::test_file(path = private$valid_paths, ...)
      } else if (private$is_single_test_dir()) {
        testthat::test_dir(path = private$valid_paths, ...)
      } else if (private$is_multiple_test_dirs()) {
        private$test_recursive(...)
      } else {
        cli::cli_abort("Test run failed!")
      }
    }
  ),
  private = list(
    filter = NULL,
    path = NULL,
    valid_paths = NULL,
    recursive = TRUE,
    get_valid_test_paths = function() {
      if (fs::is_file(private$path)) {
        private$valid_paths <- fs::path_filter(private$path, regexp = private$filter)
      }

      if (fs::is_dir(private$path)) {
        valid_paths <- unique(
          fs::path_dir(
            fs::dir_ls(path = private$path,
                       regexp = private$filter,
                       recurse = private$recursive, type = "file")
          )
        )

        private$valid_paths <- valid_paths[order(valid_paths)]
      }

      if (length(private$valid_paths) == 0) {
        cli::cli_abort("No valid test file/s found in {.var {private$path}}.",
                       call = rlang::caller_env(n = 3))
      }
    },
    is_single_test_file = function() {
      length(private$valid_paths) == 1 && fs::is_file(private$valid_paths)
    },
    is_single_test_dir = function() {
      length(private$valid_paths) == 1
    },
    is_multiple_test_dirs = function() {
      length(private$valid_paths) > 1
    },
    run_recursive_test_dir = function(...) {
      t(
        sapply(private$valid_paths, function(this_path) {
          private$cat_cr()
          cli::cat_line("Test Directory: ", this_path)

          single_test_result <- as.data.frame(
            testthat::test_dir(path = this_path, stop_on_failure = FALSE, ...))

          colSums(single_test_result[, c("failed", "warning", "skipped", "passed")])
        })
      )
    },
    show_final_line = function(test_results) {
      final_line_results <- colSums(test_results)

      cli::cat_line(
        summary_line(final_line_results[["failed"]],
                             final_line_results[["warning"]],
                             final_line_results[["skipped"]],
                             final_line_results[["passed"]])
      )

      private$cat_cr()
    },
    show_summary = function(test_results) {
      private$cat_cr()
      cli::cat_rule(cli::style_bold("Rhino App Summary"), line = 2)
      private$cat_cr()

      cli::cat_line(
        colourise(cli::symbol$tick, "success"), " | ",
        colourise("F", "failure"), " ",
        colourise("W", "warning"), " ",
        colourise("S", "skip"), " ",
        colourise(" OK", "success"),
        " | ", "Test Directory"
      )

      summary_results <- as.data.frame(test_results)

      sapply(row.names(summary_results), function(summary_row_name) {
        path_test_result <- summary_results[summary_row_name, ]

        if (path_test_result$failed > 0) {
          status <- cli::col_red(cli::symbol$cross)
        } else {
          status <- cli::col_green(cli::symbol$tick)
        }

        message <- paste0(
          status, " | ",
          private$col_format(path_test_result$failed, "fail"), " ",
          private$col_format(path_test_result$warning, "warn"), " ",
          private$col_format(path_test_result$skipped, "skip"), " ",
          sprintf("%3d", path_test_result$passed),
          " | ", summary_row_name
        )

        cli::cat_line(message)
      })

      private$cat_cr()
    },
    test_recursive = function(...) {
      test_results <- private$run_recursive_test_dir(...)

      private$show_summary(test_results)

      private$show_final_line(test_results)
    },
    cat_cr = function() {
      if (cli::is_dynamic_tty()) {
        cli::cat_line("\r")
      } else {
        cli::cat_line("\n")
      }
    },
    col_format = function(n, type) {
      if (n == 0) {
        " "
      } else {
        colourise(n, type)
      }
    }
  )
)

colourise <- getFromNamespace("colourise", "testthat")
has_colour <- getFromNamespace("has_colour", "testthat")
summary_line <- getFromNamespace("summary_line", "testthat")
testthat_style <- getFromNamespace("testthat_style", "testthat")

r_cmd_check_fix <- function() {
  testthat::test_check()
}