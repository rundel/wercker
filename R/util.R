require_wercker_cli = function() {
  wercker = Sys.which("wercker")

  if (wercker == "") {
    url = "https://devcenter.wercker.com/development/cli/installation/"

    usethis::ui_todo(
      paste0(
        "wercker cli executable not found, if it is installed, ",
        "please make sure it can be found using your PATH variable. ",
        "If not installed see {usethis::ui_path(url)} for details."
      )
    )
  }

  return(wercker)
}

require_ghclass = function() {
  ghclass = requireNamespace("ghclass", quietly = TRUE)

  if (!ghclass) {
    usethis::ui_todo(
      paste0(
        "This functionality depends on the {usethis::ui_value(\"ghclass\")} package being installed. ",
        "Please install it to use this function."
      )
    )
  }
}

format_repo = function(repo, branch = "master", file = NULL) {
  repo = if (branch == "master") {
    repo
  } else{
    paste(repo, branch, sep="@")
  }

  if (!is.null(file))
    repo = file.path(repo, file)

  repo
}

