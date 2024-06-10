#' @param repo The path to the git repository to build.
#' @param versions A list of lists. Each sublist should contain the following keys:
#'   - `ref`: The ref to build.
#'   - `href`: The URL path for the version.
#'   - `label`: The label to display in the navbar. To use the version from DESCRIPTION provide `TRUE`.
#' Additonally, exactly one version should have `href` set to "/".
#' @param url The rool URL for all versions of the website.
#' @param destination The destination directory for the built website.
build_versioned <- function(repo, versions, url, destination) {
  validate_versions(versions)

  # Prepare a repo for building
  temp_repo <- fs::dir_copy(repo, fs::file_temp("versioned-build-repo-"))
  on.exit(fs::dir_delete(temp_repo))
  # NOTE: detach to avoid git worktree complaining about the current ref being checked out
  system2("git", c("-C", temp_repo, "switch", "--detach", "@"))
  build_version <- build_version_factory(temp_repo, versions, url, destination)

  # NOTE: building the ref in root first, so pkgdown doesn't complain about a non-empty destination directory
  root_index <- purrr::detect_index(versions, \(x) isTRUE(x$href == "/"))
  purrr::walk(c(versions[root_index], versions[-root_index]), build_version)
}

validate_versions <- function(versions) {
  expected_names <- c("ref", "href", "label")
  n_root <- 0
  purrr::walk(versions, function(version) {
    diff <- setdiff(expected_names, names(version))
    if (length(diff) > 0) {
      stop("A version is missing the following keys: ", paste(diff, collapse = ", "))
    }
    if (isTRUE(version$href == "/")) {
      n_root <<- n_root + 1
      if (n_root > 1) {
        stop("Exactly one version should have href set to '/'")
      }
    }
  })
}

build_version_factory <- function(repo, versions, url, destination) {
  destination <- fs::path_abs(destination)
  extra_css_path <- fs::path_join(c(repo, "pkgdown", "extra.css"))

  function(version) {
    # Prepare a worktree for building
    build_dir <- fs::file_temp("versioned-build-worktree-")
    on.exit(system2("git", c("-C", repo, "worktree", "remove", "--force", build_dir))) # NOTE: --force because we add the navbar file
    status <- system2("git", c("-C", repo, "worktree", "add", build_dir, version$ref))
    if (status != 0) {
      stop("Failed to create a worktree for ref ", version$ref)
    }

    # Prepare template and write extra.css
    template <- template_override(before_navbar = version_selector(url, version, versions))
    fs::file_copy(extra_css_path, fs::path_join(c(build_dir, "pkgdown", "extra.css")), overwrite = TRUE)

    # NOTE: providing an absolute path to build_site won't work: https://github.com/r-lib/pkgdown/issues/2172
    withr::with_dir(build_dir, {
      pkgdown::build_site_github_pages(
        override = list(
          url = sub("/$", "", url_join(url, version$href)),
          template = template
        ),
        dest_dir = fs::path_join(c(destination, version$href))
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

template_override <- function(before_navbar) {
  template <- yaml::read_yaml("pkgdown/_pkgdown.yml")$template
  template$includes$before_navbar <- before_navbar
  template
}

format_label <- function(label) {
  if (isTRUE(label)) {
    label <- paste(desc::desc_get_version(), "(dev)")
  }
  label
}

version_selector <- function(root_url, current_version, versions) {
  current_label <- format_label(current_version$label)
  versions <- purrr::map_chr(
    versions,
    function(version) {
      sprintf(
        '<li><a class="dropdown-item" href="%s">%s</a></li>',
        url_join(root_url, version$href),
        format_label(version$label)
      )
    }
  ) |> paste0(collapse = "\n")
  glue::glue('
    <div id="version-switcher" class="dropdown">
      <a
        href="#"
        class="nav-link dropdown-toggle"
        data-bs-toggle="dropdown"
        role="button"
        aria-expanded="false"
        aria-haspopup="true"
      >
        {current_label}
      </a>
      <ul class="dropdown-menu">
        {versions}
      </ul>
    </div>
  ')
}
