concat_op <- ""
format_op <- ""

allowed_ops <- c("$", "@", "^", "*", "/", "-", "+", "&", "|", "&&", "||")

set_string_ops_session <- function(concat = "&", format = "|") {
  # ns <- getNamespace("base")
  # rlang::env_unlock(ns)
  # unlockBinding(concat, ns)
  # unlockBinding(format, ns)
  assign(concat, string_concat_op, envir = globalenv(), inherits=FALSE)
  assign(format, string_format_op, envir = globalenv(), inherits=FALSE)
  # rlang::env_lock(ns)
  
  ns <- getNamespace("stringplus")
  rlang::env_unlock(ns)
  unlockBinding("concat_op", ns)
  unlockBinding("format_op", ns)
  assign("concat_op", concat, envir = ns, inherits=FALSE)
  assign("format_op", format, envir = ns, inherits=FALSE)
  rlang::env_lock(ns)
}

store_string_ops <- function(concat = "&", format = "|") {
  dir_path <- rappdirs::user_config_dir(appname = "r_stringplus")
  config_path <- paste0(dir_path, "/r_stringplus.tsv")
  config_df <- data.frame(fun = c("concat", "format"), op = c(concat, format))
  dir.create(dir_path, recursive=TRUE, showWarnings=FALSE)
  write.table(config_df, file = config_path, sep = "\t", quote = TRUE, row.names = FALSE)
}

restore_string_ops <- function() {
  dir_path <- rappdirs::user_config_dir(appname = "r_stringplus")
  config_path <- paste0(dir_path, "/r_stringplus.tsv")
  if(file.exists(config_path)) {
    config_df <- read.table(config_path, stringsAsFactors=FALSE, header=TRUE)
    concat <- config_df[["op"]] [ config_df[["fun"]] == "concat" ]
    format <- config_df[["op"]] [ config_df[["fun"]] == "format" ]
    set_string_ops_session(concat, format)
    TRUE
  } else {
    FALSE
  }
}

#' Set infix string operators
#'
#' Set infix string operators for concatenation and format functions
#'
#' @usage set_string_ops(concat = "&", format = "&", permanent = TRUE)
#'
#' @param concat The concatenation operator (see `string_concat_op`)
#' @param format The format operator (see `string_format_op`)
#' @param permanent If `TRUE` store these settings to load for future sessions
#' @export
set_string_ops <- function(concat = "&", format = "|", permanent = TRUE) {
  if( (!concat %in% allowed_ops) || (!format %in% allowed_ops) ) {
    stop(paste0("Infix operators must be one of ", paste0(allowed_ops, collapse = " ")))
  }
  set_string_ops_session(concat, format)
  if(permanent) {
    store_string_ops(concat, format)
  }
}


#' Concatenate two strings
#'
#' Concatenate together two strings. Not intended to be called directly, use `set_string_ops`.
#'
#' @usage string_concat_op(e1, e2)
#'
#' @param e1 Must be a character vector
#' @param e2 Anything, will be the second argument in `paste0`
#'
#' @return If e1 is a character vector, e1 and e2 pasted together. Equivalent to paste0(e1, e2).
#' @examples
#' set_string_ops(concat = "+", permanent = FALSE)
#' "hello" + "world" # output: "helloworld"
#' 1 + 2 # output: 3
#' @export
string_concat_op <- function(e1, e2) {
  if(is.character(e1)) {
    paste0(e1,e2)
  } else {
    do.call(.Primitive(concat_op), list(e1, e2), envir = parent.frame(2))
  }
}

#' Format a string
#'
#' Function for formatting a string using `glue::glue` or `sprintf`. Not intended to be called directly, use `set_string_ops`.
#'
#' @usage string_format_op(e1, e2)
#'
#' @param e1 Must be a character vector
#' @param e2 Anything, will be used as subsequent arguments.
#'
#' @return If e1 is a character vector, e1 and e2 will be combined using either `sprintf`
#' or `glue::glue` depending on whether e2 is named.
#' @examples
#' set_string_ops(format = "*", permanent = FALSE)
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
string_format_op <- function(e1, e2) {
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
    do.call(.Primitive(format_op), list(e1, e2), envir = parent.frame(2))
  }
}
