% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/higher_order_helpers.R
\name{mkLegalServerFunctions}
\alias{mkLegalServerFunctions}
\title{Make a fetcher and reader function to fetch a particular report from LegalServer.}
\usage{
mkLegalServerFunctions(report_name, creds_path)
}
\description{
Generate a pair of functions for fetching and reading legalserver data.
This is just a shortcut, as this is a common thing to do with the puddle library.
Requires LegalServerReader library.
}
