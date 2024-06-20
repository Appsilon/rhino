rhino::format_js()

# Create bad scripts and test if formatting returns the expected result
test_file_path <- fs::path("app", "js", "bad-style.js")
cat('const  someFunction = (a ,b) => a+ b + "asdf"', file = test_file_path)
rhino::format_js()
testthat::expect_identical(
  readLines(test_file_path),
  "const someFunction = (a, b) => a + b + 'asdf';"
)

# Clean up
file.remove(test_file_path)
