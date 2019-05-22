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
    usethis::ui_todo( c(
      'This functionality depends on the {usethis::ui_value(\"ghclass\")} package being installed.',
      'The package can be install via {usethis::ui_code("install.packages(\\"ghclass\\")")}.'
    ) )
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

succeeded = function(x) {
  !is.null(x$result)
}

failed = function(x) {
  !is.null(x$error)
}

error_msg = function(x) {
  x[["error"]][["message"]]
}

status_msg = function(x, success, fail, include_error_msg = TRUE) {
  if (succeeded(x) & !missing(success)) {
    usethis::ui_done(success)
  }

  if (failed(x) & !missing(fail)) {
    if (include_error_msg)
      fail = paste(fail, "[Error: {usethis::ui_value(error_msg(x))}]")
    usethis::ui_oops(fail)
  }
}


