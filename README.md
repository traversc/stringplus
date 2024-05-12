[![experimental](http://badges.github.io/stability-badges/dist/experimental.svg)](http://github.com/badges/stability-badges)

# stringplus

Combine strings using builtin infix for convenience.

### Install
```
remotes::install_github("traversc/stringplus")
```

### Examples

Using the `&` operator concatenates two strings.
```
"hello" & "world"
# output: "helloworld"
```

Using the `|` operator formats a string using `sprintf` or `glue::glue` depending on whether the second argument is named.
```
# Using sprintf
"C:/folder/%s/file.txt" | "subfolder"

# Using glue::glue
"C:/folder/{var}/file.txt" | c(var="subfolder")

# Output: "C:/folder/subfolder/file.txt"
```

### Using a different infix operator
You can change the infix operators in the above examples by calling `set_string_ops`.
```
set_string_ops(concat = "+", format = "*", permanent = FALSE)
"hello" + "world"
# output: "helloworld"

"C:/folder/%s/file.txt" * "subfolder"
# Output: "C:/folder/subfolder/file.txt"
```
Setting `permanent = TRUE` will make these settings persist between sessions.

### Details

Many infix operators in base R functions are hard coded to return an error on character vector inputs. 
This is unlike the behavior for custom classes, where they can be modified using the R dispatch system.

While these operators can't be modified for string input, they CAN be overwritten. In `stringplus`, the built-in operators are overwritten to check if the first argument is a character vector; if so it concatenates (or formats) the two arguments, if not it falls back to the built-in operator.

This overridden function should not interfere with normal dispatch. 

```
set_string_ops(concat = "+", format = "*", permanent = FALSE)
library(ggplot2)

ggplot(mtcars, aes(x = mpg, y = cyl)) + geom_point()

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

Isn't there a performance cost?
* Yes, there is a small performance cost around 1-2 microsecond per op

Wouldn't this interfere with class dispatch methods?
* No, see examples

Could this break something else?
* I don't think so, please let me know if you can think of a way it does!
