#' Build local repos
#'
#' \code{wercker_local_build} uses the wercker cli tool to build local repos.
#'
#' @param repo_dir Vector of repo directories or a single directory containing one or more repos.
#' @param wecker_cli Path to the wercker cli tool.
#'
#' @examples
#' \dontrun{
#' wercker_local_build('hw1/')
#' }
#'
#' @family local repo functions
#'
#' @export
wercker_local_build = function(repo_dir,
                               wercker_cli = require_wercker_cli(),
                               verbose = TRUE) {
  stopifnot(all(fs::dir_exists(repo_dir)))
  stopifnot(fs::file_exists(wercker_cli))

  repo_dir = repo_dir_helper(repo_dir)

  purrr::walk(
    repo_dir,
    function(repo) {
      cur_dir = getwd()
      on.exit({
        setwd(cur_dir)
      })
      setwd(repo)

      usethis::ui_done("Running wercker build for {usethis::ui_value(repo)}.")

      cmd = paste(wercker_cli, "build --direct-mount")
      status = system(
        cmd, intern = FALSE, wait = TRUE,
        ignore.stdout = !verbose, ignore.stderr = !verbose
      )

      if (status != 0)
        usethis::ui_oops("wercker build for {usethis::ui_value(repo)} failed.")
    }
  )
}

# If we are given a single repo directory check if it is a repo or a directory of repos
repo_dir_helper = function(repo_dir) {
  if (length(repo_dir) == 1 & !fs::dir_exists(fs::path(repo_dir[1],".git"))) {
    dir = fs::dir_ls(repo_dir, type="directory")
  } else {
    dir = repo_dir
  }

  fs::path_real(dir)
}
