# How-to: Build Rhino apps with LLM tools

LLM tools like [GitHub Copilot](https://github.com/features/copilot) and
[Claude Code](https://www.claude.com/product/claude-code) can be
extremely helpful when building apps with Rhino. However, the unique
project structure and the use of the box package for module imports can
make it harder for these tools to understand and assist effectively. The
good news is that their performance can be significantly improved by
providing custom instructions.

## AGENTS.md

Many AI coding tools (including Claude Code, Cursor, and others) read an
[`AGENTS.md`](https://agents.md) file at the project root for
repository-specific guidance. Rhino ships a curated [`AGENTS.md`
template](https://github.com/Appsilon/rhino/blob/main/inst/templates/agents_md/AGENTS.md)
tailored to Rhino projects, covering `box` imports, the Rhino module
layout, unit-test conventions, and code style.

- [`rhino::init()`](https://appsilon.github.io/rhino/reference/init.md)
  adds it by default. Set `agents_instructions = FALSE` to opt out.
- To add it to an existing Rhino project, run
  [`rhino::use_agents_md()`](https://appsilon.github.io/rhino/reference/use_agents_md.md).
  If `AGENTS.md` already exists you will be prompted to either abort or
  back up the existing file as `AGENTS.md.bak`.

## Tool-specific instruction files

Some AI coding tools read instructions from their own dedicated file
rather than `AGENTS.md`. If the tool you use does not pick up
`AGENTS.md` automatically, copy the content of the [Rhino `AGENTS.md`
template](https://github.com/Appsilon/rhino/blob/main/inst/templates/agents_md/AGENTS.md)
into the file that tool expects, for example:

- GitHub Copilot: `.github/copilot-instructions.md`
- Claude Code: `CLAUDE.md`
- Cursor: `.cursor/rules/` or `.cursorrules`

Refer to your tool’s documentation for the exact path it reads.
