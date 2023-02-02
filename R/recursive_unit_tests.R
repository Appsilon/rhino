RecursiveUnitTests <- R6::R6Class("RecursiveUnitTests",       # nolint
  public = list(
    run_tests = function(
        paths = fs::dir_ls("tests/testthat/", regexp = "\\.R$", recurse = TRUE, type = "file"),
        inline_failures = FALSE,
        raw_output = FALSE
      ) {
      files <- private$traverse_paths(paths)

      private$show_header()
      test_results <- private$test_files(files, inline_failures)
      flat_test_results <- private$flatten_test_results(test_results)
      private$show_summary(flat_test_results, inline_failures)

      if (raw_output) {
        output <- test_results
      } else {
        output <- flat_test_results
      }

      invisible(output)
    }
  ),
  private = list(
    traverse_paths = function(paths) {
      list_of_files <- lapply(paths, function(path) {
        if (fs::is_file(path)) {
          return(path)
        } else if (fs::is_dir(path)) {
          return(
            fs::dir_ls(path, regexp = "\\.R$", recurse = FALSE, type = "file")
          )
        }
      })
      
      unlist(list_of_files, use.names = FALSE)
    },
    test_files = function(files, inline_failures) {
      test_results <- lapply(files, function(file) {
        invisible(capture.output(
          raw_result <- testthat::test_file(file, stop_on_failure = FALSE)
        ))

        if (length(raw_result) > 0) {
          raw_result_df <- as.data.frame(raw_result)
          raw_result_summary <- aggregate(
            cbind(failed, warning, skipped, passed) ~ context,
            data = raw_result,
            FUN = sum
          )

          if (raw_result_summary$failed > 0) {
            status <- cli::col_red(cli::symbol$cross)
          } else {
            status <- cli::col_green(cli::symbol$tick)
          }

          message <- paste0(
            status, " | ",
            private$col_format(raw_result_summary$failed, "fail"), " ",
            private$col_format(raw_result_summary$warning, "warn"), " ",
            private$col_format(raw_result_summary$skipped, "skip"), " ",
            sprintf("%3d", raw_result_summary$passed),
            " | ", raw_result_summary$context
          )

          cli::cat_line(message)

          if (inline_failures & raw_result_summary$failed > 0) {
            private$show_failures(raw_result_df)
          }
        }

        return(raw_result)
      })
    },
    flatten_test_results = function(test_results) {
      results_df <- lapply(test_results, `as.data.frame`)
      results_df <- private$compact(results_df)
      do.call("rbind", results_df)
    },
    get_final_results = function(flat_test_results) {
      colSums(flat_test_results[, c("failed", "warning", "skipped", "passed")])
    },
    show_header = function() {
      cli::cat_line(
        private$colourise(cli::symbol$tick, "success"), " | ",
        private$colourise("F", "failure"), " ",
        private$colourise("W", "warning"), " ",
        private$colourise("S", "skip"), " ",
        private$colourise(" OK", "success"),
        " | ", "Context"
      )
    },
    show_final_line = function(final_results) {
      cli::cat_line(
        private$summary_line(final_results[["failed"]],
                             final_results[["warning"]],
                             final_results[["skipped"]],
                             final_results[["passed"]])
      )

      private$cat_cr()
    },
    show_failures = function(test_results) {
      failed_tests <- test_results[test_results$failed > 0, "result"]

      lapply(failed_tests, function(failed_test) {
        result_body <- failed_test[[1]]
        srcref <- result_body[["srcref"]]
        srcfile <- attr(srcref, "srcfile")
        filename <- srcfile$filename
        line <- srcref[1]
        col <- srcref[2]
        test <- result_body[["test"]]
        message <- result_body[["message"]]
        
        failure_type <- private$colourise("Failure", "failure")
        location <- cli::format_inline("{.file {filename}:{line}}:{{col}}")
        issue_message <- cli::format_inline(
          cli::style_bold(
            "{failure_type} ({location}): {test}"
          )
        )

        private$cat_cr()
        cli::cat_line(issue_message)
        cli::cat_line(message)
      })
    },
    show_summary = function(flat_test_results, inline_failures) {
      final_results <- private$get_final_results(flat_test_results)
      
      if (!inline_failures & final_results[["failed"]] > 0) {
        private$cat_cr()
        cli::cat_rule(cli::style_bold("Failures"), line = 1)
        private$show_failures(flat_test_results)
      }

      private$cat_cr()
      cli::cat_rule(cli::style_bold("Results"), line = 2)
      private$cat_cr()

      private$show_final_line(final_results)
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
        private$colourise(n, type)
      }
    },
    colourise = function(text, as = c("success", "skip", "warning", "failure", "error")) {
      if (private$has_colour()) {
        unclass(cli::make_ansi_style(private$testthat_style(as))(text))
      } else {
        text
      }
    },
    has_colour = function() {
      isTRUE(getOption("testthat.use_colours", TRUE)) &&
        cli::num_ansi_colors() > 1
    },
    summary_line = function(n_fail, n_warn, n_skip, n_pass) {
      colourise_if <- function(text, colour, cond) {
        if (cond) private$colourise(text, colour) else text
      }

      # Ordered from most important to least important
      paste0(
        "[ ",
        colourise_if("FAIL", "failure", n_fail > 0), " ", n_fail, " | ",
        colourise_if("WARN", "warn", n_warn > 0),    " ", n_warn, " | ",
        colourise_if("SKIP", "skip", n_skip > 0),    " ", n_skip, " | ",
        colourise_if("PASS", "success", n_fail == 0), " ", n_pass,
        " ]"
      )
    },
    testthat_style = function(type = c("success", "skip", "warning", "failure", "error")) {
      type <- match.arg(type)

      c(
        success = "green",
        skip = "blue",
        warning = "magenta",
        failure = "orange",
        error = "orange"
      )[[type]]
    },
    compact = function(x) {
      x[private$viapply(x, length) != 0]
    },
    viapply = function(X, FUN, ...) {
      vapply(X, FUN, ..., FUN.VALUE = integer(1))
    }
  )
)

r_cmd_check_fix <- function() {
  testthat::test_check()
}