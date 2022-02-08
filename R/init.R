rprofile_init <- function() {
  # This function is called from `.Rprofile` early on and shouldn't depend on any packages.

  options(box.path = c(
    file.path(getwd(), "app"), # Allow absolute module imports (relative to the app root).
    system.file("box_modules", package = "rhino")
  ))
}
