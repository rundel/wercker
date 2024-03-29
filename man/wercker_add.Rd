% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/app.R
\name{wercker_add}
\alias{wercker_add}
\title{Create a wercker app for an existing github repo}
\usage{
wercker_add(repo, wercker_org = get_repo_owner(repo), add_badge = TRUE)
}
\arguments{
\item{repo}{one or more repo names in \code{owner/repo} format.}

\item{wercker_org}{name of the owning organization on wercker, only needs to be provided if this differs from github.}

\item{add_badge}{should a wercker badge be added to the github repo's README.md}
}
\description{
Create a wercker app for an existing github repo
}
\seealso{
Other app functions: \code{\link{wercker_check}}
}
\concept{app functions}
