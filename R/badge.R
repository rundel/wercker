wercker_get_badge_key = function(repo) {
  app_info = purrr::map(repo, wercker_api_get_app)
  purrr::map_chr(app_info, "badgeKey", .default=NA)
}

strip_existing_badge = function(content) {
  md_badge_pattern = "\\[\\!\\[wercker status\\]\\(.*? \"wercker status\"\\)\\]\\(.*?\\)\n*"
  html_badge_pattern = "<a href=\".*?\"><img alt=\"Wercker status\" src=\".*?\"></a>"

  content = gsub(md_badge_pattern, "", content)
  content = gsub(html_badge_pattern, "", content)
}

#' Get wercker badge link
#'
#' Generates the appropriate badge link in either HTML or Markdown format for an existing wercker app.
#'
#' @param repo one or more repo names in `owner/repo` format
#' @param size size of the badge, either small or large
#' @param type link format, either markdown or html
#' @param branch repo branch, defaults to master
#'
#' @export
wercker_get_badge = function(repo, size = "small", type = "markdown", branch = "master") {
  size = match.arg(size, c("small", "large"), several.ok = TRUE)
  type = match.arg(type, c("markdown", "html"), several.ok = TRUE)

  size = switch(
    size,
    small = "s",
    large = "m"
  )

  key = wercker_get_badge_key(repo)

  purrr::pmap_chr(
    list(size, type, key, branch),
    function(size, type, key, branch) {
      img_url = sprintf("https://app.wercker.com/status/%s/%s/%s", key, size, branch)
      app_url = sprintf("https://app.wercker.com/project/byKey/%s", key)

      if (type == "markdown")
        sprintf('[![wercker status](%s "wercker status")](%s)', img_url, app_url)
      else
        sprintf('<a href="%s"><img alt="Wercker status" src="%s"></a>', app_url, img_url)
    }
  )
}


#' Add wercker badge to github repo
#'
#' This function adds a wercker badge to a github repo's README.md.
#'
#' @param repo one or more repo names in `owner/repo` format
#' @param badge one or more badge links, defaults to generating via `wercker_get_badge()`
#' @param branch github branch to alter
#' @param strip_existing_badge should any existing wercker badges be striped from the README.md?
#'
#' @export
wercker_add_badge = function(repo, badge = wercker_get_badge(repo, branch = branch),
                             branch = "master", strip_existing_badge = TRUE) {
  require_ghclass()

  res = purrr::pmap(
    list(repo, badge, branch),
    function(repo, badge, branch) {

      readme = ghclass::repo_get_readme(repo, branch)

      if (is.null(readme)) { # README.md does not exist
        content = paste0(badge,"\n\n")
        gh_file = "README.md"
      } else {
        if (strip_existing_badge)
          readme = strip_existing_badge(readme)

        gh_file = attr(readme,"path", exact = TRUE)
        content = paste0(badge, "\n\n", readme)
      }

      res = ghclass::repo_put_file(repo, file=gh_file, content=charToRaw(content),
               message="Added wercker badge", branch=branch)

      status_msg(
        res,
        glue::glue("Adding wercker badge to {usethis::ui_value(format_repo(repo, branch))}."),
        glue::glue("Adding wercker badge to {usethis::ui_value(format_repo(repo, branch))} failed.")
      )
    }
  )
}
