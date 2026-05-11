rhino::lint_js()

# Create bad scripts and test if formatting returns the expected result
test_js_path <- fs::path("app", "js", "badStyle.js")
cat("function sayHello() {console.log('Hello')}; export{sayHello};", file = test_js_path)
testthat::expect_error(rhino::lint_js())
rhino::lint_js(fix = TRUE)
testthat::expect_identical(
  readLines(test_js_path),
  "function sayHello() { console.log('Hello'); } export { sayHello };"
)
# Clean up
file.remove(test_js_path)
