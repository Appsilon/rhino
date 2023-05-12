library(rhino)
library(fs)

init("RhinoApp")

stopifnot(file.exists(fs::path("RhinoApp", "RhinoApp.Rproj")))
