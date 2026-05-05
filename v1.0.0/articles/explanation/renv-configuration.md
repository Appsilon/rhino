# Explanation: Renv configuration

We use implicit snapshots and `dependencies.R` + `.renvignore`. This
gives us a similar behavior to explicit snapshots but works better with
deployments: rsconnect uses packrat, which only reads
[`library()`](https://rdrr.io/r/base/library.html) calls and does not
understand `DESCRIPTION` nor box.
