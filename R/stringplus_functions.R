#' Plus operator for strings
#'
#' Use `+` to paste together two strings
#'
#' @usage e1 + e2
#'
#' @param e1 Must be a character vector
#' @param e2 Anything, will be the second argument in `paste0`
#'
#' @return If e1 is a character vector, e1 and e2 pasted together. Equivalent to paste0(e1, e2).
#' @examples
#' "hello" + "world" # output: "helloworld"
#' 1 + 2 # output: 3
#' @export
`+` <- function(e1, e2) {
  if(is.character(e1)) paste0(e1,e2)
  else .Primitive("+")(e1,e2)
}

#' Multiply operator for strings
#'
#' Use `*` to combine strings
#'
#' @usage e1 * e2
#'
#' @param e1 Must be a character vector
#' @param e2 Anything, will be used as subsequent arguments.
#'
#' @return If e1 is a character vector, e1 and e2 will be combined using either `sprintf`
#' or `glue::glue` depending on whether e2 is named.
#' @examples
#' "C:/folder/%s/file.txt" * "subfolder"
#'
#' # Equivalent to 
#' sprintf("C:/folder/%s/file.txt", "subfolder")
#' 
#' "C:/folder/{var}/file.txt" * c(var="subfolder")
#' 
#' # Equivalent to 
#' glue::glue("C:/folder/{var}/file.txt", var="subfolder")
#' 
#' 1 * 2 # output: 2
#' @export
`*` <- function(e1, e2) {
  if(is.character(e1)) {
    e2 <- as.list(e2)
    if(is.null(names(e2))) {
      e2 <- c(list(fmt=e1), e2)
      return(do.call(sprintf, e2))
    } else {
      e2 <- c(list(e1), e2, list(.envir=NULL))
      do.call(glue::glue, e2)
    }
  } else {
    .Primitive("*")(e1,e2)
  }
}
