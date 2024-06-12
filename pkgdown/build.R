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
  navbar_template <- navbar_template_factory(versions, root_url)
  destination <- fs::path_abs(destination)
  extra_css_path <- fs::path_join(c(repo, "pkgdown", "extra.css"))

  function(version) {
    # Prepare a worktree for building
    build_dir <- fs::file_temp("versioned-build-worktree-")
    on.exit(system2("git", c("-C", repo, "worktree", "remove", "--force", build_dir))) # NOTE: --force because we add the navbar file
    status <- system2("git", c("-C", repo, "worktree", "add", build_dir, version$git_ref))
    if (status != 0) {
      stop("Failed to create a worktree for ref ", version$git_ref)
    }

    # Write the navbar template and extra.css
    template_dir <- fs::path_join(c(build_dir, "pkgdown", "templates"))
    fs::dir_create(template_dir)
    writeLines(navbar_template(version), fs::path_join(c(template_dir, "navbar.html")))
    fs::file_copy(extra_css_path, fs::path_join(c(build_dir, "pkgdown", "extra.css")), overwrite = TRUE)

    # NOTE: providing an absolute path to build_site won't work: https://github.com/r-lib/pkgdown/issues/2172
    withr::with_dir(build_dir, {
      pkgdown::build_site_github_pages(
        override = list(
          url = sub("/$", "", url_join(root_url, version$url)),
          navbar = list(type = "light")
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

navbar_template_factory <- function(versions, root_url) {
  navbar_code <- readLines("pkgdown/navbar_template.html")
  index_current <- grep("___CURRENT_PLACEHOLDER___", navbar_code)
  index_options <- grep("___OPTIONS_PLACEHOLDER___", navbar_code)
  stopifnot(index_current < index_options)
  wrap_label <- function(label) {
    if (isTRUE(label)) {
      label <- paste(desc::desc_get_version(), "(dev)")
    }
    label
  }
  function(version) {
    c(
      navbar_code[1:(index_current - 1)],
      wrap_label(version$label),
      navbar_code[(index_current + 1):(index_options - 1)],
      purrr::map_chr(
        versions,
        function(ver) {
          sprintf(
            '<li><a class="dropdown-item" href="%s">%s</a></li>',
            url_join(root_url, ver$url),
            wrap_label(ver$label)
          )
        }
      ),
      navbar_code[(index_options + 1):length(navbar_code)]
    )
  }
}
