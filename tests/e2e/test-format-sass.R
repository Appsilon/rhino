rhino::format_sass()

# Create bad scripts and test if formatting returns the expected result
test_file_path <- fs::path("app", "styles", "bad-style.scss")
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

# Clean up
file.remove(test_file_path)

# A nested SCSS block, so a prettier-major change to multi-level formatting is caught.
nested_path <- fs::path("app", "styles", "nested.scss")
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
file.remove(nested_path)
