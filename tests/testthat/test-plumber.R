# Setup by starting APIs
root_path <- "http://localhost"
default_port <- 8000

pred_api <- setup(
  callr::r_bg(
    ppp::run_predict_api,
    args = list(port = 8000, swagger = FALSE)
  )
)

teardown(pred_api$kill())

test_that("API is alive", {
  expect_true(pred_api$is_alive())
})

test_that("Health Check works", {
  # Send request and ensure the API is fully initialized and listening. At most
  # wait 15 seconds for the API to initialize
  max_s <- 15
  for (i in 1:max_s) {
    try({
      r <- httr::GET(url = root_path, port = default_port, path = "health-check")
      break()
    }, silent = TRUE)
    Sys.sleep(1)
  }

  # Check response
  expect_equal(httr::status_code(r), 200)
  expect_equal(httr::content(r)[[1]], "Sale Price API is running")
})

test_that("Predict endpoint defaults", {
  # Send request
  r <- httr::POST(url = root_path,
                  port = default_port,
                  path = "predict",
                  body = httr::upload_file(system.file("plumber",
                                                       "model",
                                                       "test-data-small.json",
                                                       package = "ppp")
                  ))

  # Check response
  expect_equal(httr::status_code(r), 200)
  r_content <- httr::content(r)
  expect_type(r_content, "list")
  expect_equal(length(r_content), 6)
})

test_that("Predict endpoint params", {
  # Send request
  r <- httr::POST(url = root_path,
                  port = default_port,
                  path = "predict",
                  body = httr::upload_file(system.file("plumber",
                                                       "model",
                                                       "test-data-small.json",
                                                       package = "ppp")),
                  query = list(all = TRUE, log = TRUE))

  # Check response
  expect_equal(httr::status_code(r), 200)
  r_content <- httr::content(r)
  expect_type(r_content, "list")
  expect_equal(length(r_content), 6)
  expect_equal(length(unique(sapply(r_content, length))), 1)
})
