rhino::build_js()

min_js_path <- fs::path("app", "static", "js", "app.min.js")
index_js_path <- fs::path("app", "js", "index.js")

testthat::expect_equal(
  readLines(min_js_path, warn = FALSE),
  "var App;App={};"
)

# Create minimal css and check app.min.css output
cat(
  "function sayHello() { console.log('Hello'); } export { sayHello };\n",
  file = index_js_path,
  append = TRUE
)
rhino::build_js()
testthat::expect_equal(
  readLines(min_js_path),
  readLines(fs::path("..", "test-files", "sayHello-app-min-js.txt"))
)
# Clean up
cat(
  "",
  file = index_js_path
)
cat(
  "var App;App={};",
  file = min_js_path
)
