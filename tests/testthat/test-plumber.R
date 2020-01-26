# Setup by starting APIs
root_path <- "http://localhost"
default_port <- 8000

pred_api <- callr::r_bg(
  ppp::run_predict_api,
  args = list(port = 8000, swagger = FALSE)
)

# Make sure the API has warmed up and fully initialized
Sys.sleep(5)

teardown(pred_api$kill())

test_that("API is alive", {
  expect_true(pred_api$is_alive())
})

test_that("Health Check works", {
  # Send request
  r <- httr::GET(url = root_path, port = default_port, path = "health-check")

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
