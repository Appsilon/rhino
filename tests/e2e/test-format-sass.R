rhino::format_sass()

test_file_path <- fs::path("app", "styles", "bad-style.scss")
nested_path <- fs::path("app", "styles", "nested.scss")

# `finally` removes the fixtures even if an expectation fails, so a failure here does not
# leave `.scss` files behind for the later `if: always()` workflow steps.
tryCatch(
  {
    # Create bad scripts and test if formatting returns the expected result
    cat("@import 'asdf';\nx+y{ color: red}", file = test_file_path)
    rhino::format_sass()
    testthat::expect_identical(
      readLines(test_file_path),
      c(
        '@import "asdf";',
        "x + y {",
        "  color: red;",
        "}"
      )
    )
    file.remove(test_file_path)

    # A nested SCSS block, so a prettier-major change to multi-level formatting is caught.
    cat(".card{ color:red; .title{font-weight:bold} }\n", file = nested_path)
    rhino::format_sass()
    testthat::expect_identical(
      readLines(nested_path),
      c(
        ".card {",
        "  color: red;",
        "  .title {",
        "    font-weight: bold;",
        "  }",
        "}"
      )
    )
  },
  finally = unlink(c(test_file_path, nested_path))
)
