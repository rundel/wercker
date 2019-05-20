.wercker = new.env(FALSE, parent=globalenv())

.onAttach = function(libname, pkgname) {
  assign("token", value = NULL, envir = .wercker)

  try(get_github_token(), silent = TRUE)
  try(get_wercker_token(), silent = TRUE)
}

.onUnload = function(libpath) {
}

