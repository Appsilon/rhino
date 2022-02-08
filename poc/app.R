# Purge the box module cache, so the app can be reloaded without restarting the R session.
rm(list = ls(box:::loaded_mods), envir = box:::loaded_mods)

box::use(
  shiny[addResourcePath, shinyApp],
)
box::use(
  r/main,
)

addResourcePath("static", "app/static")

shinyApp(
  ui = main$ui("app"),
  server = function(input, output) {
    main$server("app")
  }
)
