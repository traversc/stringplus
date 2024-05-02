[![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)

# stringplus

Combine strings using `+` and `*` for convienence.

### Install
```
remotes::install_github("traversc/stringplus")
```

### Examples

Load library
```
library(stringplus, warn=FALSE)
```

Using the `+` operator simply concatenates two strings.
```
"hello" + "world"
# output: "helloworld"
```
This is equivalent to `paste0("hello", "world")`.

Using the `*` operator calls `sprintf` or `glue::glue` depending on whether the second argument is named.
```
"C:/folder/%s/file.txt" * "subfolder"
# Output: "C:/folder/subfolder/file.txt"
```
This is equivalent to `sprintf("C:/folder/%s/file.txt", "subfolder")`.

Alternatively:
```
"C:/folder/{var}/file.txt" * c(var="subfolder")
# Output: "C:/folder/subfolder/file.txt"
```
This is equivalent to `glue::glue("C:/folder/{var}/file.txt", var="subfolder")`.

### Details

`+` and `*` operators are base R functions that are hard coded to return an error on character vector inputs. 
This is unlike the behavior for custom classes, where they can be modified using the R dispatch system.

While these operators can't be modified for character input, they CAN be overwritten. In `stringplus`, the `+`
operator is overwritten to first check if its input is a character vector; if so it concatenates the two arguments,
if not it falls back to the base R functions. `*` is modified similarly. 

```
`+` <- function(e1, e2) {
  if(is.character(e1)) paste0(e1,e2)
  else .Primitive("+")(e1,e2)
}
```

This overridden function should not interfere with normal dispatch. 
```
library(stringplus, warn=FALSE)

1 + 2 # output: 3

1 * 2 # output: 2

setClass("Zoo", slots=list(animals="numeric"))
setMethod("+", signature = c("Zoo", "Zoo"),
          function(e1, e2) new("Zoo", animals=e1@animals + e2@animals))
sandiego <- new("Zoo", animals=4000)
columbus <- new("Zoo", animals=7000)
sandiego + columbus
# Output
# An object of class "Zoo"
# Slot "animals":
# [1] 11000
```

### Notes

Will this package be on CRAN? 
* Probably not

Isn't there a performance cost?
* Yes, there is a small performance cost around 1 microsecond per `+` or `*` op

Wouldn't this interfere with class dispatch using `+` or `*` methods?
* No, see examples

Could this break something else?
* I don't think so, please let me know if you can think of a way it does!