# Add AGENTS.md

Adds an `AGENTS.md` file with guidance for AI coding agents (e.g. GitHub
Copilot, Claude Code) to a Rhino application.

## Usage

``` r
use_agents_md()
```

## Value

None. This function is called for side effects.

## Details

This file is added automatically by
[`init()`](https://appsilon.github.io/rhino/dev/reference/init.md)
unless `agents_instructions = FALSE`. Use this function to add it to an
existing Rhino project.

If `AGENTS.md` already exists in an interactive session, you will be
prompted to either abort (the default) or back up the existing file as
`AGENTS.md.bak` (with a numeric suffix if `AGENTS.md.bak` is also taken)
and create a new one. In non-interactive sessions the function aborts
with an error.

## Examples

``` r
if (interactive()) {
  # Add AGENTS.md to the current Rhino project.
  use_agents_md()
}
```
