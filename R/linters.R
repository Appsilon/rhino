# R CMD Check "notes" that all declared Imports in DESCRIPTION should be used. box.linters is not
# used by the rhino package itself, but by the initialized rhino app. There are no calls to
# box.linters in the R/ or tests/ folders. box.linters is called in the rhino app dot.lintr
# template in inst/templates/app_structure. The following lines manually imports box.linters making
# R CMD Check happy.
#' @import box.linters
NULL
