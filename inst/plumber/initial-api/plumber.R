library(plumber)
library(glmnet)

# Load global objects ----
model <- readr::read_rds("ames-model.rds")
recipe <- readr::read_rds("ames-recipe.rds")

#* @apiTitle Sale Price Model

#* Check status of API
#* @get /health-check
function() {
  "Sale Price API is running"
}

#* Predict sale price of new data
#* @param all Whether or not to return the pre-processed input data (TRUE) along with the predictions, or just the predictions (FALSE)
#* @param log Should the predicted values remain in log10 (TRUE) or be converted back to actual prices (FALSE)
#* @post /predict
function(req, res, all = FALSE, log = FALSE) {
  # Check to see if input data can be serialized from JSON
  new_data <- tryCatch(jsonlite::parse_json(req$postBody, simplifyVector = TRUE),
                   error = function(e) NULL)
  if (is.null(new_data)) {
    res$status <- 400
    return(list(error = "Invalid data submitted"))
  }

  # Convert character vectors to factors in new_data
  new_data <- dplyr::mutate_if(new_data, is.character, as.factor)

  # Apply recipe to new_data
  model_data <- recipes::bake(recipe, new_data)

  # Generate predictions using the model and model_data
  predictions <- predict(model, model_data)

  # If !log, transform predicted values back from log10
  if (!as.logical(log)) {
    predictions[[".pred"]] <- predictions[[".pred"]] ^ 10
  }

  # Return either the model_data bound to predictions or just predictions, based
  # on the value of all
  if (as.logical(all)) {
    dplyr::bind_cols(model_data, predictions)
  } else {
    predictions[[".pred"]]
  }
}
