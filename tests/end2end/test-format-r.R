paths <- args <- commandArgs(trailingOnly = TRUE)
paths <- strsplit(paths, ",")

rhino::format_r(paths)
