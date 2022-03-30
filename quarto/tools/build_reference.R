box::use(
  fs,
  pkgdown,
  rvest[html_elements, read_html],
  withr[with_dir],
)

html_to_qmd <- function(input_file, output_file) {
  contents <- read_html(input_file) |> html_elements("#main") |> as.character()
  lines <- c("```{=html}", contents, "```")
  writeLines(lines, output_file)
}

main <- function() {
  pkgdown$init_site()
  pkgdown$build_reference(devel = FALSE, examples = FALSE)

  src <- fs$path("docs", "reference")
  dst <- fs$path("quarto", "reference")
  if (fs$dir_exists(dst)) fs$dir_delete(dst)
  fs$file_move(src, dst)
  with_dir(dst, {
    for (file in fs$dir_ls(glob = "*.html")) {
      html_to_qmd(file, fs$path_ext_set(file, "qmd"))
    }
  })
}

with_dir(fs$path("..", ".."), main())
