min_js_path <- fs::path("app", "static", "js", "app.min.js")
index_js_path <- fs::path("app", "js", "index.js")

# Create minimal css and check app.min.css output
cat(
  "function sayHello() { console.log('Hello'); } export { sayHello };\n",
  file = index_js_path
)
rhino::build_js()
testthat::expect_true(readLines(min_js_path) != "var App;App={};")

# Revert to empty script and check otuput
cat(
  "\n",
  file = index_js_path
)
rhino::build_js()
testthat::expect_identical(
  readLines(min_js_path, warn = FALSE),
  "var App;App={};"
)
