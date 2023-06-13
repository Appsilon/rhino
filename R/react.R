react_support <- shiny::tagList(
  shiny.react::reactDependency(),
  shiny::tags$script(shiny::HTML("
    window.Rhino = {
      registerReact: (components) => {
        window.jsmodule.RhinoReact ??= {};
        Object.assign(window.jsmodule.RhinoReact, components);
      },
    };
  "))
)

#' Rhino React
methods::setClass("RhinoReact", contains = "NULL")

#' Rhino React
#' @param x The Rhino React singleton.
#' @param name The name of the React component.
methods::setMethod("$", "RhinoReact", function(x, name) {
  function(...) {
    shiny.react::reactElement(
      module = "RhinoReact",
      name = name,
      props = shiny.react::asProps(...)
    )
  }
})

#' React components
#'
#' Access the React components defined in your app.
#'
#' @examples
#' react$MyComponent("Hello!")
#'
#' @export
react <- methods::new("RhinoReact")

# Workaround to avoid a NOTE ("All declared Imports should be used") on R CMD check.
# It seems that `methods::` functions are called during the build process,
# so they actually do not appear in the built package source code.
#' @importFrom methods new
NULL
