#' Test if units
#'
#' Tests whether an object is \code{units}.
#'
#' @param x Object to test.
#' @examples
#' is_units(1:5)
#' is_units(as_units(1:5))
#' @export
is_units <- function(x) {
  inherits(x, c("units"))
}

#' Coerce to units
#'
#' Converts an object to \code{units} using \code{\link[units]{as.units}}.
#'
#' @param x Object to coerce.
#' @param unit Units or character string (see \code{\link{parse_unit}}).
#' @examples
#' as_units(1:5)
#' as_units(1:5, "m/s")
#' as_units(1:5, parse_unit("m/s"))
#' dt <- as.difftime(1, units = "hours")
#' as_units(dt)
#' as_units(dt, "min")
#' @export
as_units <- function(x, unit) {
  missing_unit <- missing(unit)
  if (!missing_unit) {
    stopifnot(is_units(unit) || is.character(unit))
    if (is.character(unit)) {
      unit %<>% parse_unit()
    }
  }
  if (inherits(x, "difftime")) {
    x %<>% units::as.units()
    if (!missing_unit) {
      x %<>% convert_units(to = unit)
    }
  } else {
    if (missing_unit) {
      unit <- parse_unit("")
    }
    x %<>% units::as.units(value = unit)
  }
  x
}

#' Convert units
#'
#' Converts between different units of measure.
#'
#' @param x Object coercible to \code{units}.
#' @param from Units or character string (see \code{\link{parse_unit}}).
#' @param to Units or character string (see \code{\link{parse_unit}}).
#' @examples
#' convert_units(1, "km", "m")
#' x <- as_units(1, "km")
#' convert_units(x, to = x)
#' convert_units(x, to = "m")
#' @export
convert_units <- function(x, from = x, to) {
  x %>%
    as_units(from) %>%
    as_units(to)
}
