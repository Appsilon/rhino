# Verifies `lint_js()` actually enforces the eslint + airbnb ruleset and that
# @babel/eslint-parser still parses modern JS and JSX. A dependency bump could either
# break JSX parsing (valid code would then error) or silently stop enforcing rules
# (bad code would then pass) - both are guarded below.

# The default scaffolded app lints clean.
rhino::lint_js()

# @babel/eslint-parser parses JSX: a clean component lints without error.
clean_jsx_path <- fs::path("app", "js", "CleanWidget.jsx")
cat(
  paste0(
    "const { useState } = React;\n\n",
    "export default function CleanWidget({ label }) {\n",
    "  const [on, setOn] = useState(false);\n",
    "  return (\n",
    "    <button type=\"button\" onClick={() => setOn(!on)}>\n",
    "      {on ? label : 'off'}\n",
    "    </button>\n",
    "  );\n",
    "}\n"
  ),
  file = clean_jsx_path
)
testthat::expect_no_error(rhino::lint_js())
file.remove(clean_jsx_path)

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
