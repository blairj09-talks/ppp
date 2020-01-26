library(plumber)

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

  ppp::predict_sale_price(new_data, all = all, log = log)
}
