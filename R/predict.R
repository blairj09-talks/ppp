# This function predicts house sale price based on a variety of features. This uses the model that is created and shipped as part of this package.

#' Predict sale price of a property
#'
#' @param new_data A \code{data.frame} or equivalent containing features necessary
#'   for predicting sale price
#' @param all Logical. Whether to return just predicted values or the
#'   transoformed \code{new_data} input along with predicted values. Defalt is
#'   TRUE.
#' @param log Logical. The model returns log10 sale price values. If this
#'   parameter is FALSE (the default) then the values will be transformed back
#'   before being returned.
#'
#' @examples
#' \dontrun{
#' predict_sale_price(new_data = jsonlite::read_json(system.file("plumber",
#'                                                               "model",
#'                                                               "test-data.json",
#'                                                               package = "ppp"),
#'                                                   simplifyVector = TRUE))
#' }
#' @return If \code{all} is \code{FALSE}, a vector containing the predicted
#'   values; if \code{all} is \code{TRUE}, a tibble containing the predicted
#'   values along with the transformed columns of \code{new_data}
#'
#' @importFrom parsnip predict.model_fit
#' @importFrom glmnet predict.glmnet
#' @export
predict_sale_price <- function(new_data, all = TRUE, log = FALSE) {
  # Load saved model and recipe
  model <- readRDS(system.file("plumber", "model", "ames-model.rds", package = "ppp"))
  recipe <- readRDS(system.file("plumber", "model", "ames-recipe.rds", package = "ppp"))

  # Convert character vectors to factors in new_data
  new_data <- dplyr::mutate_if(new_data, is.character, as.factor)

  # Apply recipe to new_data
  model_data <- recipes::bake(recipe, new_data)

  # Generate predictions using the model and model_data
  predictions <- parsnip::predict.model_fit(model, model_data)

  # If !log, transform predicted values back from log10
  if (!as.logical(log)) {
    predictions[[".pred"]] <- 10 ^ predictions[[".pred"]]
  }

  # Return either the model_data bound to predictions or just predictions, based
  # on the value of all
  if (as.logical(all)) {
    dplyr::bind_cols(model_data, predictions)
  } else {
    predictions[[".pred"]]
  }
}

#' Run the housing prediction API
#'
#' @param log Logical. Should Plumber APi log requests. Default is TRUE.
#' @param ... Options passed to \code{plumber::plumb()$run()}
#' @examples
#' \dontrun{
#' run_predict_api()
#' run_predict_api(swagger = TRUE, port = 8000)
#' }
#' @return A running Plumber API
#' @export
run_predict_api <- function(log = TRUE, ...) {
  if (log) {
    plumber::plumb(dir = system.file("plumber", "pkg-api", package = "ppp"))$run(...)
  } else {
    plumber::plumb(file = system.file("plumber", "pkg-api", "plumber.R", package = "ppp"))$run(...)
  }
}
