.onAttach <- function(libname, pkgname) {
  if( !restore_string_ops() ) {
    set_string_ops_session(concat = "&", format = "|")
  }
}