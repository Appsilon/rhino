rhino::format_r(paths = c("app", "tests"))

# Create bad scripts and test if formatting returns the expected result
test_file_path <- fs::path("app", "logic", "bad-style.R")
cat("bad_object_style=12", file = test_file_path)
rhino::format_r(paths = "app")
testthat::expect_identical(
  readLines(test_file_path),
  "bad_object_style <- 12"
)

# Clean up
file.remove(test_file_path)
