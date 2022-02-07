# This file allows packrat (used by rsconnect during deployment) to pick up dependencies.

# Development
library(covr)
library(DT) # Required to display the coverage report.
library(lintr)
library(rsconnect)
library(styler)
library(testthat)
library(yaml) # Used to load config for lintr.

# Production
library(box)
library(logger)
library(shiny)
