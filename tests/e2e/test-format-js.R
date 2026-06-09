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

# A larger case exercising prettier on modern JS (arrow fn, object method, template
# literal) so a prettier-major formatting change is caught, not just trivial spacing.
modern_path <- fs::path("app", "js", "modern.js")
cat(
  paste0(
    "const make=(name)=>{const o={name:name,greet(){return `hi ${name}`}};return o}\n",
    "export {make}\n"
  ),
  file = modern_path
)
rhino::format_js()
testthat::expect_identical(
  readLines(modern_path),
  c(
    "const make = (name) => {",
    "  const o = {",
    "    name: name,",
    "    greet() {",
    "      return `hi ${name}`;",
    "    },",
    "  };",
    "  return o;",
    "};",
    "export { make };"
  )
)
file.remove(modern_path)
