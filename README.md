units2
================

units2 is a simple (and probably temporary) wrapper to the units class provided by the [units](https://github.com/edzer/units) package. Specifically, it avoids non-standard evaluation and the silent creation of unitless units, as was needed for my programmatic and piping needs.

### Parse unit from string

#### String formats

`units::parse_unit` only supports product power form (e.g. `"kg m2 s-1"`). `units2::parse_unit` supports product power form (including `"+"`), arithmetic expressions (e.g. `"kg * (m^2 / s)"`), and any combination thereof (e.g. `"kg+1 (m^2 s-1)"`).

``` r
units2::parse_unit("kg m2 s-1")
```

    ## 1 kg*m^2/s

``` r
units2::parse_unit("kg (m^2 / s)")
```

    ## 1 kg*m^2/s

``` r
units2::parse_unit("kg+1 (m^2 s-1)")
```

    ## 1 kg*m^2/s

``` r
units2::parse_unit("in/s")
```

    ## 1 in/s

``` r
units2::parse_unit("°")
```

    ## 1 °

#### Unit names with numbers

`units::parse_unit` fails with units with numbers in their name. `units2::parse_unit` fixes this.

``` r
unit_names <- names(units::ud_units)
unit_names[grepl("[0-9]", unit_names)]
```

    ##   [1] "H2O"      "h2o"      "cm_H2O"   "cmH2O"    "ftH2O"    "fth2o"   
    ##   [7] "YH2O"     "ZH2O"     "EH2O"     "PH2O"     "TH2O"     "GH2O"    
    ##  [13] "MH2O"     "kH2O"     "hH2O"     "daH2O"    "dH2O"     "cH2O"    
    ##  [19] "mH2O"     "µH2O"     "μH2O"     "uH2O"     "nH2O"     "pH2O"    
    ##  [25] "fH2O"     "aH2O"     "zH2O"     "yH2O"     "Yh2o"     "Zh2o"    
    ##  [31] "Eh2o"     "Ph2o"     "Th2o"     "Gh2o"     "Mh2o"     "kh2o"    
    ##  [37] "hh2o"     "dah2o"    "dh2o"     "ch2o"     "mh2o"     "µh2o"    
    ##  [43] "μh2o"     "uh2o"     "nh2o"     "ph2o"     "fh2o"     "ah2o"    
    ##  [49] "zh2o"     "yh2o"     "Ycm_H2O"  "Zcm_H2O"  "Ecm_H2O"  "Pcm_H2O" 
    ##  [55] "Tcm_H2O"  "Gcm_H2O"  "Mcm_H2O"  "kcm_H2O"  "hcm_H2O"  "dacm_H2O"
    ##  [61] "dcm_H2O"  "ccm_H2O"  "mcm_H2O"  "µcm_H2O"  "μcm_H2O"  "ucm_H2O" 
    ##  [67] "ncm_H2O"  "pcm_H2O"  "fcm_H2O"  "acm_H2O"  "zcm_H2O"  "ycm_H2O" 
    ##  [73] "YcmH2O"   "ZcmH2O"   "EcmH2O"   "PcmH2O"   "TcmH2O"   "GcmH2O"  
    ##  [79] "McmH2O"   "kcmH2O"   "hcmH2O"   "dacmH2O"  "dcmH2O"   "ccmH2O"  
    ##  [85] "mcmH2O"   "µcmH2O"   "μcmH2O"   "ucmH2O"   "ncmH2O"   "pcmH2O"  
    ##  [91] "fcmH2O"   "acmH2O"   "zcmH2O"   "ycmH2O"   "YftH2O"   "ZftH2O"  
    ##  [97] "EftH2O"   "PftH2O"   "TftH2O"   "GftH2O"   "MftH2O"   "kftH2O"  
    ## [103] "hftH2O"   "daftH2O"  "dftH2O"   "cftH2O"   "mftH2O"   "µftH2O"  
    ## [109] "μftH2O"   "uftH2O"   "nftH2O"   "pftH2O"   "fftH2O"   "aftH2O"  
    ## [115] "zftH2O"   "yftH2O"   "Yfth2o"   "Zfth2o"   "Efth2o"   "Pfth2o"  
    ## [121] "Tfth2o"   "Gfth2o"   "Mfth2o"   "kfth2o"   "hfth2o"   "dafth2o" 
    ## [127] "dfth2o"   "cfth2o"   "mfth2o"   "µfth2o"   "μfth2o"   "ufth2o"  
    ## [133] "nfth2o"   "pfth2o"   "ffth2o"   "afth2o"   "zfth2o"   "yfth2o"

``` r
tryCatch(units::parse_unit("H2O"), error = function(e) print(e))
```

    ## Warning in parse_one(str): NAs introduced by coercion

    ## <simpleError in if (power < 0) u = 1/make_unit(substr(str, 1, r - 1)) else u = make_unit(substr(str,     1, r - 1)): missing value where TRUE/FALSE needed>

``` r
units2::parse_unit("H2O")
```

    ## 1 H2O

``` r
units2::parse_unit("H2O1")
```

    ## 1 H2O

``` r
units2::parse_unit("1 / H2O-1")
```

    ## 1 H2O

#### Unknown units

`units::parse_unit` silently creates new units. `units2::parse_unit` throws an error.

``` r
units::parse_unit("unknown")
```

    ## 1 unknown

``` r
tryCatch(units2::parse_unit("unknown"), error = function(e) print(e))
```

    ## <simpleError: udunits2::ud.is.parseable(string) is not TRUE>

#### Unit symbols

As a side effect of evaluating the constructed expression against `units::ud_units`, `units2::parse_unit` always replaces unit names with their corresponding symbols.

``` r
units::parse_unit("meters seconds-1")
```

    ## 1 meters/seconds

``` r
units2::parse_unit("meters seconds-1")
```

    ## 1 m/s

### Deparse unit to string

`units::as_cf` is renamed `units2::deparse_unit` for symmetry with `parse_unit`.

### Coercion and conversion

`units2::as_units` and `units2::convert_units` accept either string or units objects as unit specifications, while `units::as.units` and `units::set_units` accepts only the latter.

``` r
library(magrittr)
x <- 1:10
from <- "meters s-1"
to <- "km hour-1"
# units
x %>%
  units::as.units(value = units::parse_unit(from)) %>%
  units::set_units(value = units::parse_unit(to))
```

    ## Units: km/hour
    ##  [1]  3.6  7.2 10.8 14.4 18.0 21.6 25.2 28.8 32.4 36.0

``` r
# units2 equivalent
x %>%
  units2::convert_units(from = from, to = to)
```

    ## Units: km/h
    ##  [1]  3.6  7.2 10.8 14.4 18.0 21.6 25.2 28.8 32.4 36.0

`units2` drops support for the non-standard evaluation in `units::set_units` because `units2::parse_unit` supports that notation in string form, avoiding confusing behavior:

``` r
units2::as_units(x, "meters/s")
```

    ## Units: m/s
    ##  [1]  1  2  3  4  5  6  7  8  9 10

``` r
tryCatch(units::set_units(x, meters/s), error = function(e) print(e))
```

    ## <simpleError in eval(expr, envir, enclos): object 'meters' not found>

``` r
meters <- 0.01
tryCatch(units::set_units(x, meters/s), error = function(e) print(e))
```

    ## Units: 1/s
    ##  [1] 0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10
