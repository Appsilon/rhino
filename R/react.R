shiny_react_available <- function() {
  requireNamespace("shiny.react", quietly = TRUE)
}

react_support <- function() {
  if (shiny_react_available()) {
    shiny::tagList(
      shiny.react::reactDependency(),
      shiny.react::shinyReactDependency(),
      shiny::tags$script(shiny::HTML("
        window.Rhino = {
          registerReactComponents: (components) => {
            window.jsmodule.RhinoReact ??= {};
            Object.assign(window.jsmodule.RhinoReact, components);
          },
        };
      "))
    )
  }
}

# nolint start: line_length_linter
#' React components
#'
#' Declare the React components defined in your app.
#'
#' There are three steps to add a React component to your Rhino application:
#' 1. Define the component using JSX and register it with `Rhino.registerReactComponents()`.
#' 2. Declare the component in R with `rhino::react_component()`.
#' 3. Use the component in your application.
#'
#' Please refer to the [Tutorial: Use React in Rhino](https://appsilon.github.io/rhino/articles/tutorial/use-react-in-rhino.html)
#' to learn about the details.
#'
#' @param name The name of the component.
#' @return A function representing the component.
#'
#' @examples
#' # Declare the component.
#' TextBox <- react_component("TextBox")
#'
#' # Use the component.
#' ui <- TextBox("Hello!", font_size = 20)
#' @export
# nolint end
react_component <- function(name) {
  if (!shiny_react_available()) {
    cli::cli_abort(
      "To use React components in your app, please add {.pkg shiny.react} to dependencies."
    )
  }
  function(...) {
    shiny.react::reactElement(
      module = "RhinoReact",
      name = name,
      props = shiny.react::asProps(...)
    )
  }
}
