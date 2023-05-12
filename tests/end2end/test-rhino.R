library(rhino)

init("RhinoApp")

stopifnot(file.exists("RhinoApp.Proj"))
stopifnot(1 == 2)

renv::deactivate()