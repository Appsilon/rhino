_**Disclaimer: Rhino is under an active development. Before version 1.0.0 release Rhino API might change.**_

# Rhino <a href="https://appsilon.github.io/rhino/"><img src="man/figures/rhino.png" align="right" alt="Rhino logo" style="height: 140px;"></a>
> _Build high quality, enterprise-grade [Shiny](https://shiny.rstudio.com/) apps at speed.._

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/rhino)](https://cran.r-project.org/package=rhino)
[![R build status](https://github.com/Appsilon/rhino/workflows/R-CMD-check/badge.svg)](https://github.com/Appsilon/rhino/actions)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: LGPL-3.0](https://img.shields.io/badge/License-LGPL--3.0-blue.svg)][LGPL-3.0 license]
<!-- badges: end -->


# Why Rhino?
Rhino allows you to create Shiny apps "The Appsilon Way"  - like a fullstack software engineer: apply best software engineering practices, modularize your code, test it well, make UI beautiful and think about adoption from the very beginning. It is an opinionated framework with a focus on software engineering practices and development tools.

Rhino supports your work in 3 main areas:

1. Clear code (scalable app architecture, modularization based on Box and Shiny modules.
2. Quality (unit tests, E2E tests with Cypress, logging and monitoring, linting).
3. Automation (project startup, CI with Github Actions, dependency management with renv, configuration management with config, Sass and Javascript bundling with ES6 support via Nodejs).

These features are often implemented using well-known packages. The biggest value in Rhino is that you instantly get all of them working together and pre-configured.

Read more: [Why Rhino?](articles/about-why-rhino.html) and [How is Rhino different from ...?](articles/about-how-is-it-different.html)

## Get it
Stable version:
```r
install.packages("rhino")
```

Development version:
```r
remotes::install_github("Appsilon/rhino")
```

## Usage

- 🏗️: `rhino::init()` creates a new Shiny Application with Rhino.
- :rocket: To learn more, follow the [Rhino tutorial](articles/tutorial-create-your-first-rhino-app.html)
- To migrate an existing application to Rhino, refer to [`rhino::init()` details section](https://appsilon.github.io/rhino/reference/init.html#details-1)

## About

Rhino is distributed under [LGPL-3.0 license]. Developed with :heart: at [Appsilon].

---

Appsilon is the **Full Service Certified RStudio Partner**. Learn more at [appsilon.com][Appsilon].

Get in touch: opensource@appsilon.com.

<a href="https://appsilon.com/careers/"><img src="http://d2v95fjda94ghc.cloudfront.net/hiring.png" alt="We are hiring!"></a>


<!-- Links -->
[LGPL-3.0 license]: https://opensource.org/licenses/LGPL-3.0
[Appsilon]: https://appsilon.com
