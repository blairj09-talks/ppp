library(loadtest)

test_data <- jsonlite::read_json("test-data.json", simplifyVector = FALSE)

hc_lt <- loadtest(
  url = "https://colorado.rstudio.com/rsc/ppp/health-check",
  method = "GET",
  threads = 2,
  loops = 10
)

plot_elapsed_times(hc_lt)

pred_lt <- loadtest(
  url = "https://colorado.rstudio.com/rsc/ppp/predict",
  method = "POST",
  body = head(test_data),
  # encode = "json",
  threads = 1,
  loops = 10
)

tibble::as_tibble(pred_lt)
plot_elapsed_times(pred_lt)

loadtest_report(pred_lt)
