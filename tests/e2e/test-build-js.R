# Verifies `build_js()` drives the full webpack + babel toolchain, not just that it runs:
# - ES module `import` resolution and multi-file bundling (webpack),
# - JSX transpilation (@babel/preset-react -> `React.createElement`),
# - modern-JS transpilation (@babel/preset-env lowers optional chaining `?.`).
# These are the capabilities a dependency bump is most likely to break.

min_js_path <- fs::path("app", "static", "js", "app.min.js")
index_js_path <- fs::path("app", "js", "index.js")
greeting_js_path <- fs::path("app", "js", "greeting.js")
widget_jsx_path <- fs::path("app", "js", "Widget.jsx")

# A realistic entry: imports a helper module and a JSX component, and uses
# optional chaining so we can assert preset-env actually transpiled it.
# `finally` removes the extra modules even if an assertion fails, so a failure here
# does not leave fixtures behind for the later `if: always()` workflow steps.
tryCatch(
  {
    cat(
      "const greeting = (name) => `Hi ${name}`;\nexport { greeting };\n",
      file = greeting_js_path
    )
    cat(
      paste0(
        "export default function Widget({ label }) {\n",
        "  return <div className=\"widget\">{label}</div>;\n",
        "}\n"
      ),
      file = widget_jsx_path
    )
    cat(
      paste0(
        "import { greeting } from './greeting';\n",
        "import Widget from './Widget';\n\n",
        "const message = greeting('Rhino');\n",
        "const upper = message?.toUpperCase();\n\n",
        "export { Widget, message, upper };\n"
      ),
      file = index_js_path
    )
    rhino::build_js()
    bundle <- paste(readLines(min_js_path, warn = FALSE), collapse = "\n")

    # Not the empty-input bundle (something was actually built).
    testthat::expect_false(identical(bundle, "var App;App={};"))
    # JSX was transpiled by @babel/preset-react (classic runtime emits React.createElement).
    testthat::expect_match(bundle, "createElement", fixed = TRUE)
    # Optional chaining was lowered by @babel/preset-env (no `?.` survives in the output).
    # The template configures no `targets`/Browserslist, so preset-env down-levels all
    # modern syntax regardless of caniuse-lite updates. If a Browserslist config is ever
    # added to the Node template, revisit this assertion.
    testthat::expect_false(grepl("?.", bundle, fixed = TRUE))
    # The imported module was resolved and bundled (its string literal is present).
    testthat::expect_match(bundle, "Hi ", fixed = TRUE)
  },
  finally = {
    # Remove the extra modules and reset the entry to a clean (empty) state.
    unlink(c(greeting_js_path, widget_jsx_path))
    cat("\n", file = index_js_path)
  }
)

# Revert to an empty entry and check the resulting (empty) bundle.
cat("\n", file = index_js_path)
rhino::build_js()
testthat::expect_identical(
  readLines(min_js_path, warn = FALSE),
  "var App;App={};"
)
