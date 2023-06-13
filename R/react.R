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
