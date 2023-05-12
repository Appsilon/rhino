library(rhino)

init("RhinoApp")

stopifnot(file.exists("RhinoApp.Rproj"))

renv::deactivate()
