# This function is defined in the `inst` directory, as it must be sourced with `keep.source = TRUE`
# for reloading to work: https://github.com/Appsilon/rhino/issues/157
function(shiny_module) {
  list(
    # Wrap the UI in a function to support Shiny bookmarking.
    ui = function(request) shiny_module$ui("app"),
    # The curly braces below are essential: https://github.com/Appsilon/rhino/issues/157
    server = function(input, output) {
      shiny_module$server("app")
    }
  )
}
