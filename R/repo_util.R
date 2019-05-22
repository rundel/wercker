repo_pattern ="^([A-Za-z0-9]+[A-Za-z0-9-]*[A-Za-z0-9]+)/([A-Za-z0-9_.-]+)$"
username_pattern = "^[A-Za-z\\d](?:[A-Za-z\\d]|-(?=[A-Za-z\\d])){0,38}$"

require_valid_repo = function(repo) {
  valid = valid_repo(repo)
  if (!all(valid))
    stop("Invalid repo names: \n\t", paste(repo[!valid], collapse="\n\t"), call. = FALSE)
}

valid_repo = function(repo) {
  grepl(repo_pattern, repo)
}

get_repo_name = function(repo) {
  gsub(repo_pattern, "\\2", repo)
}

get_repo_owner = function(repo) {
  gsub(repo_pattern, "\\1", repo)
}
