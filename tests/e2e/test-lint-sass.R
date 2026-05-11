rhino::lint_sass()

# Create bad scripts and test if formatting returns the expected result
test_scss_path <- fs::path("app", "styles", "bad-style.scss")
cat(".my-class{color: #FFFFFF}", file = test_scss_path)
testthat::expect_error(rhino::lint_sass())
rhino::lint_sass(fix = TRUE)
testthat::expect_identical(
  readLines(test_scss_path),
  ".my-class { color: #fff; }"
)
# Clean up
file.remove(test_scss_path)
