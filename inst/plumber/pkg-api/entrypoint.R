# Implement logging on a Plumber router
# Example from https://github.com/sol-eng/plumber-logging

library(plumber)
library(logger)
library(glue)

config <- config::get()

# Specify how logs are written
if (!fs::dir_exists(config$log_dir)) fs::dir_create(config$log_dir)
log_appender(appender_tee(tempfile("plumber_", config$log_dir, ".log")))

convert_empty <- function(string) {
  if (is.null(string)) return ("-")
  if (string == "") {
    "-"
  } else {
    string
  }
}

pr <- plumb("plumber.R")

pr$registerHooks(
  list(
    preroute = function() {
      # Start timer for log info
      tictoc::tic()
    },
    postroute = function(req, res) {
      end <- tictoc::toc(quiet = TRUE)
      # Log details about the request and the response
      log_info('{convert_empty(req$REMOTE_ADDR)} "{convert_empty(req$HTTP_USER_AGENT)}" {convert_empty(req$HTTP_HOST)} {convert_empty(req$REQUEST_METHOD)} {convert_empty(req$PATH_INFO)} {convert_empty(res$status)} {round(end$toc - end$tic, digits = getOption("digits", 5))} {convert_empty(req$CONTENT_LENGTH)}')
    }
  )
)

pr
