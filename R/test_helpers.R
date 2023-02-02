traverse_test_paths <- function(paths) {
  list_of_files <- lapply(paths, function(path) {
    if (fs::is_file(path)) {
      return(path)
    } else if (fs::is_dir(path)) {
      return(
        fs::dir_ls(path, glob = "*.R", recurse = FALSE, type = "file")
      )
    }
  })
  
  unlist(list_of_files, use.names = FALSE)
}

test_files <- function(files, inline_issues, min_time = 0.1) {
  test_results <- lapply(files, function(file) {
    invisible(utils::capture.output(
      raw_result <- testthat::test_file(file, stop_on_failure = FALSE)
    ))

    if (length(raw_result) > 0) {
      raw_result_df <- as.data.frame(raw_result)
      raw_result_summary <- stats::aggregate(
        cbind(failed, warning, skipped, passed, real) ~ context,
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
        col_format(raw_result_summary$failed, "fail"), " ",
        col_format(raw_result_summary$warning, "warn"), " ",
        col_format(raw_result_summary$skipped, "skip"), " ",
        sprintf("%3d", raw_result_summary$passed),
        " | ", raw_result_summary$context
      )

      if (raw_result_summary$real > min_time) {
        message <- paste0(
          message,
          cli::col_grey(sprintf(" [%.1fs]", raw_result_summary$real))
        )
      }

      cli::cat_line(message)

      if (inline_issues & raw_result_summary$skipped > 0) {
        cli::cat_rule(line = 1)
        show_test_issues("skip", raw_result_df)
        cli::cat_rule(line = 1)
      }
      if (inline_issues & raw_result_summary$failed > 0) {
        cli::cat_rule(line = 1)
        show_test_issues("failure", raw_result_df)
        cli::cat_rule(line = 1)
      }
      
    }

    return(raw_result)
  })
  
  compact(test_results)
}

flatten_test_results <- function(test_results) {
  results_df <- lapply(test_results, `as.data.frame`)
  do.call("rbind", results_df)
}

get_final_test_results <- function(flat_test_results) {
  colSums(flat_test_results[, c("failed", "warning", "skipped", "passed", "real")])
}

show_test_header <- function() {
  cli::cat_line(
    colourise(cli::symbol$tick, "success"), " | ",
    colourise("F", "failure"), " ",
    colourise("W", "warning"), " ",
    colourise("S", "skip"), " ",
    colourise(" OK", "success"),
    " | ", "Context"
  )
}

show_test_final_line <- function(final_results) {
  cli::cat_line(
    summary_line(final_results[["failed"]],
                         final_results[["warning"]],
                         final_results[["skipped"]],
                         final_results[["passed"]])
  )

  cat_cr()
}

show_test_issues <- function(issue_type, test_results) {
  df_column <- switch(
    issue_type,
    "failure" = "failed",
    "skip" = "skipped"
  )

  issue_tests <- test_results[test_results[[df_column]] > 0, "result"]

  lapply(issue_tests, function(issue_test) {
    result_body <- issue_test[[1]]
    srcref <- result_body[["srcref"]]
    srcfile <- attr(srcref, "srcfile")
    filename <- srcfile$filename
    line <- srcref[1]
    col <- srcref[2]
    test <- result_body[["test"]]
    message <- result_body[["message"]]
    
    issue_header <- colourise(first_upper(issue_type), issue_type)
    location <- cli::format_inline("{.file {filename}:{line}:{col}}")
    issue_message <- cli::format_inline(
      cli::style_bold(
        "{issue_header} ({location}): {test}"
      )
    )

    if (issue_type == "skip") {
      message <- gsub(":?\n(\n|.)+", "", message) # only show first line
    }

    cli::cat_line(issue_message)
    cli::cat_line(message)
    cat_cr()
  })
}

show_test_summary <- function(flat_test_results, inline_issues, min_time = 0.1) {
  final_results <- get_final_test_results(flat_test_results)
  
  if (!inline_issues & final_results[["skipped"]] > 0) {
    cli::cat_rule(cli::style_bold("Skipped tests "), line = 1)
    show_test_issues("skip", flat_test_results)
  }

  if (!inline_issues & final_results[["failed"]] > 0) {
    cli::cat_rule(cli::style_bold("Failures"), line = 1)
    show_test_issues("failure", flat_test_results)
  }

  cli::cat_rule(cli::style_bold("Results"), line = 2)
  if (final_results[["real"]] > min_time) {
    cli::cat_line("Duration: ", sprintf("%.1f s", final_results[["real"]]), col = "cyan")
  }
  cat_cr()
  show_test_final_line(final_results)
}

cat_cr <- function() {
  if (cli::is_dynamic_tty()) {
    cli::cat_line("\r")
  } else {
    cli::cat_line("\n")
  }
}

col_format <- function(n, type) {
  if (n == 0) {
    " "
  } else {
    colourise(n, type)
  }
}

colourise <- function(text, as = c("success", "skip", "warning", "failure", "error")) {
  if (has_colour()) {
    unclass(cli::make_ansi_style(testthat_style(as))(text))
  } else {
    text
  }
}

has_colour <- function() {
  isTRUE(getOption("testthat.use_colours", TRUE)) &&
    cli::num_ansi_colors() > 1
}

summary_line <- function(n_fail, n_warn, n_skip, n_pass) {
  colourise_if <- function(text, colour, cond) {
    if (cond) colourise(text, colour) else text
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
}

testthat_style <- function(type = c("success", "skip", "warning", "failure", "error")) {
  type <- match.arg(type)

  c(
    success = "green",
    skip = "blue",
    warning = "magenta",
    failure = "orange",
    error = "orange"
  )[[type]]
}

compact <- function(x) {
  x[viapply(x, length) != 0]
}

viapply <- function(X, FUN, ...) {
  vapply(X, FUN, ..., FUN.VALUE = integer(1))
}

first_upper <- function(x) {
  substr(x, 1, 1) <- toupper(substr(x, 1, 1))
  x
}