% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/unit_strings.R
\name{deparse_unit}
\alias{deparse_unit}
\title{Deparse unit to string}
\usage{
deparse_unit(x)
}
\arguments{
\item{x}{Units object.}
}
\description{
Converts \code{units} to a character string in product power form (e.g. "m2 s-1").
}
\examples{
deparse_unit(parse_unit("m"))
deparse_unit(parse_unit("m-1"))
deparse_unit(parse_unit("m s-1"))
deparse_unit(parse_unit("kg2 m Pa-2 s-1"))
}
