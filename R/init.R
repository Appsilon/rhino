rprofile_init <- function() {
  # This function is called from `.Rprofile` early on and shouldn't depend on any packages.

  # Allow absolute module imports (relative to the app root).
  options(box.path = file.path(getwd(), "app"))
}
