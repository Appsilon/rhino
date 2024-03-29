% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/init.R
\name{init}
\alias{init}
\title{Create Rhino application}
\usage{
init(
  dir = ".",
  github_actions_ci = TRUE,
  rhino_version = "rhino",
  force = FALSE
)
}
\arguments{
\item{dir}{Name of the directory to create application in.}

\item{github_actions_ci}{Should the GitHub Actions CI be added?}

\item{rhino_version}{When using an existing \code{renv.lock} file,
Rhino will install itself using \code{renv::install(rhino_version)}.
You can provide this argument to use a specific version / source, e.g.\code{"Appsilon/rhino@v0.4.0"}.}

\item{force}{Boolean; force initialization?
By default, Rhino will refuse to initialize a project in the home directory.}
}
\value{
None. This function is called for side effects.
}
\description{
Generates the file structure of a Rhino application.
Can be used to start a fresh project or to migrate an existing Shiny application
created without Rhino.
}
\details{
The recommended steps for migrating an existing Shiny application to Rhino:
\enumerate{
\item Put all app files in the \code{app} directory,
so that it can be run with \code{shiny::shinyAppDir("app")} (assuming all dependencies are installed).
\item If you have a list of dependencies in form of \code{library()} calls,
put them in the \code{dependencies.R} file.
If this file does not exist, Rhino will generate it based on \code{renv::dependencies("app")}.
\item If your project uses \code{{renv}}, put \code{renv.lock} and \code{renv} directory in the project root.
Rhino will try to only add the necessary dependencies to your lockfile.
\item Run \code{rhino::init()} in the project root.
}
}
