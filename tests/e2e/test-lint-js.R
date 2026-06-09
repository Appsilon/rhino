# Verifies `lint_js()` enforces the eslint + airbnb ruleset, and that `fix = TRUE` works.
# A dependency bump could silently stop enforcing a rule (bad code would then pass) -
# guarded below. Note: `lint_js()` only lints `.js` files (eslint is invoked on the
# `app/js` directory without `--ext`), so JSX linting is intentionally not covered here;
# JSX transpilation is guarded in `test-build-js.R`.

# The default scaffolded app lints clean.
rhino::lint_js()

# Representative airbnb rules are enforced (not merely present): each violation errors.
no_var_path <- fs::path("app", "js", "badVar.js")
cat("var x = 1;\nexport { x };\n", file = no_var_path) # no-var
testthat::expect_error(rhino::lint_js())
file.remove(no_var_path)

eqeqeq_path <- fs::path("app", "js", "badEq.js")
cat("const f = (a, b) => a == b;\nexport { f };\n", file = eqeqeq_path) # eqeqeq
testthat::expect_error(rhino::lint_js())
file.remove(eqeqeq_path)

# `fix = TRUE` auto-fixes style violations.
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
