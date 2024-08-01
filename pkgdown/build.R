#' @param repo The path to the git repository to build.
#' @param versions A list of lists. Each sublist should contain the following keys:
#'   - `git_ref`: The git ref to build.
#'   - `url`: The URL path for the version.
#'   - `label`: The label to display in the navbar. To use the version from DESCRIPTION provide `TRUE`.
#' Additonally, exactly one version should have `url` set to "/".
#' @param root_url The root URL for all versions of the website.
#' @param destination The destination directory for the built website.
build_versioned <- function(repo, versions, root_url, destination) {
  validate_versions(versions)

  # Prepare a repo for building
  temp_repo <- fs::dir_copy(repo, fs::file_temp("versioned-build-repo-"))
  on.exit(fs::dir_delete(temp_repo))
  # NOTE: detach to avoid git worktree complaining about the current ref being checked out
  system2("git", c("-C", temp_repo, "switch", "--detach", "@"))
  build_version <- build_version_factory(temp_repo, versions, root_url, destination)

  # NOTE: building the root URL first, so pkgdown doesn't complain about a non-empty destination directory
  root_index <- purrr::detect_index(versions, \(x) isTRUE(x$url == "/"))
  purrr::walk(c(versions[root_index], versions[-root_index]), build_version)
}

validate_versions <- function(versions) {
  expected_names <- c("git_ref", "url", "label")
  n_root <- 0
  purrr::walk(versions, function(version) {
    diff <- setdiff(expected_names, names(version))
    if (length(diff) > 0) {
      stop("A version is missing the following keys: ", paste(diff, collapse = ", "))
    }
    if (isTRUE(version$url == "/")) {
      n_root <<- n_root + 1
    }
  })
  if (n_root != 1) {
    stop("Exactly one version should have url set to '/'")
  }
}

build_version_factory <- function(repo, versions, root_url, destination) {
  version_switcher <- version_switcher_factory(versions, root_url)
  destination <- fs::path_abs(destination)
  extra_css_path <- fs::path_join(c(repo, "pkgdown", "extra.css"))

  function(version) {
    # Prepare a worktree for building
    build_dir <- fs::file_temp("versioned-build-worktree-")
    on.exit(system2("git", c("-C", repo, "worktree", "remove", "--force", build_dir))) # NOTE: --force because we overwrite extra.css
    status <- system2("git", c("-C", repo, "worktree", "add", build_dir, version$git_ref))
    if (status != 0) {
      stop("Failed to create a worktree for ref ", version$git_ref)
    }

    # Write extra.css
    fs::file_copy(extra_css_path, fs::path_join(c(build_dir, "pkgdown", "extra.css")), overwrite = TRUE)

    # NOTE: providing an absolute path to build_site won't work: https://github.com/r-lib/pkgdown/issues/2172
    withr::with_dir(build_dir, {
      config <- yaml::read_yaml("pkgdown/_pkgdown.yml")
      pkgdown::build_site_github_pages(
        override = list(
          url = sub("/$", "", url_join(root_url, version$url)),
          navbar = list(type = "light"),
          template = list(
            includes = list(
              # Prepend the version switcher to before_navbar instead of overwriting it.
              before_navbar = paste(
                version_switcher(version),
                config$template$includes$before_navbar,
                sep = "\n"
              )
            )
          )
        ),
        dest_dir = fs::path_join(c(destination, version$url))
      )
    })
  }
}

url_join <- function(url, path) {
  paste(
    sub("/$", "", url),
    sub("^/", "", path),
    sep = "/"
  )
}

version_switcher_factory <- function(versions, root_url) {
  wrap_label <- function(label) {
    if (isTRUE(label)) {
      label <- paste(desc::desc_get_version(), "(dev)")
    }
    label
  }
  version_list <- purrr::map(
    versions,
    function(ver) {
      htmltools::tags$li(
        htmltools::a(
          class = "dropdown-item",
          href = url_join(root_url, ver$url),
          wrap_label(ver$label)
        )
      )
    }
  )
  function(version) {
    htmltools::div(
      id = "version-switcher",
      class = "dropdown",
      htmltools::a(
        href = "#",
        class = "nav-link dropdown-toggle",
        role = "button",
        `data-bs-toggle` = "dropdown",
        `aria-expanded` = "false",
        `aria-haspopup` = "true",
        wrap_label(version$label)
      ),
      htmltools::tags$ul(
        class = "dropdown-menu",
        version_list
      )
    ) |> as.character()
  }
}
