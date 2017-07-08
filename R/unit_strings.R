#' Parse unit from string
#'
#' Converts a character string to \code{units}. If available, unit names are replaced by the corresponding symbol.
#'
#' The string may only contain unit names, numeric exponents, and operators "/", "*", "^", "(", and ")". Spaces between unit names are interpreted as "*". This includes the following standard formats:
#' \itemize{
#'   \item Product power form (e.g. "kg m2 s-1")
#'   \item Arithmetic expression (e.g. "kg * (m^2 / s)")
#'   \item ... and any combination thereof (e.g. "kg1 (m^2 s-1)")
#' }
#'
#' Unlike \code{\link[units]{parse_unit}}:
#' \itemize{
#'   \item Input must be a length-one character vector.
#'   \item Unknown units throw an error (via \code{\link[udunits2]{ud.is.parseable}}).
#'   \item Unit names are replaced by their symbol (via \code{\link[udunits2]{ud.get.symbol}}). This is a limitation of evaluating the constructed expression against \code{\link[units]{ud_units}}.
#'   \item An empty string results in \code{units::as.units(1, value = units::unitless)} rather than \code{units::make_unit("")}.
#' }
#'
#' For a list of supported units and their notation, see the UDUNITS-2 \href{https://www.unidata.ucar.edu/software/udunits/udunits-2.2.25/doc/udunits/udunits2.html#Database}{Units Database}.
#'
#' @param string (character) Unit string to parse.
#' @examples
#' parse_unit("m/s")
#' parse_unit("(m)/(s)")
#' parse_unit("m s-1")
#' parse_unit("meters/seconds")
#' parse_unit("meters seconds-1")
#' parse_unit("kg * (m^2 / s^3)")
#' parse_unit("kg (m^2 / s^3)")
#' parse_unit("kg m2 s-3")
#' parse_unit("in")
#' parse_unit("in/s")
#' parse_unit("°")
#' parse_unit("µm/s")
#' parse_unit("mm")
#' parse_unit("H2O+1 m1 s-1")
#' \dontrun{
#' parse_unit("unknown")
#' }
#' @export
parse_unit <- function(string) {
  stopifnot(
    is.character(string),
    length(string) == 1
  )
  # Validate string
  string %<>% gsub("\\s*\\*\\s*", " ", .) # (for validation only)
  stopifnot(udunits2::ud.is.parseable(string))
  # Parse string
  if (!nzchar(string)) {
    units::as.units(1, value = units::unitless)
  } else {
    string %>%
      # Replace names with symbols
      .apply_to_names(.get_symbol) %>%
      # Backtick names
      .apply_to_names(.backtick) %>%
      # Replace space between units, parentheses, or powers with "*"
      gsub("([`)0-9])\\s+([`(0-9])", "\\1*\\2", .) %>%
      # Insert ^ between unit and power
      gsub("`([-+]*[0-9]+)", "`^\\1", .) %>%
      # Convert to expression
      parse(text = .) %>%
      # Evaluate expression
      eval(envir = units::ud_units, enclos = baseenv())
  }
}

#' Apply function to unit names
#' @examples
#' .apply_to_names("m/s", function(x) {"."})
#' .apply_to_names("m^1 s-1", function(x) {"."})
#' .apply_to_names("H2O °-1", function(x) {"."})
.apply_to_names <- function(string, fun) {
  fun %<>% match.fun()
  # Unit names do not contain operators or whitespace and begin and end with non-number
  unit_names <- gregexpr("[^\\*/^()0-9\\s-+]([^\\*/^()\\s-+]*[^\\*/^()0-9\\s-+])*", string, perl = TRUE)
  unit_symbols <- unlist(regmatches(string, unit_names)) %>%
    sapply(fun) %>%
    list()
  regmatches(string, unit_names) <- unit_symbols
  string
}

#' Get unit symbol
.get_symbol <- function(string) {
  symbol <- udunits2::ud.get.symbol(string)
  ifelse(nzchar(symbol), symbol, string)
}

#' Backtick string
.backtick <- function(string) {
  paste0("`", string, "`")
}

#' Deparse unit to string
#'
#' Converts \code{units} to a character string in product power form (e.g. "m2 s-1").
#'
#' @param x Units object.
#' @examples
#' deparse_unit(parse_unit("m"))
#' deparse_unit(parse_unit("m-1"))
#' deparse_unit(parse_unit("m s-1"))
#' deparse_unit(parse_unit("kg2 m Pa-2 s-1"))
#' @export
deparse_unit <- function (x) {
  return(units::as_cf(x))
  ## NOTE: Below written in response to bug in as_cf, but can no longer reproduce bug...
  # stopifnot(is_units(x))
  # u <- units(x)
  # if (length(u$numerator) > 0) {
  #   tn <- table(u$numerator)
  #   symbols <- names(tn)
  #   powers <- as.character(tn) %>%
  #     replace(. == "1", "")
  #   nstr <- paste0(symbols, powers, collapse = " ")
  # } else {
  #   nstr <- NA
  # }
  # if (length(u$denominator) > 0) {
  #   td <- -table(u$denominator)
  #   symbols <- names(td)
  #   powers <- as.character(td)
  #   dstr <- paste0(symbols, powers, collapse = " ")
  # } else {
  #   dstr <- NA
  # }
  # paste2(nstr, dstr, na.rm = TRUE)
}
