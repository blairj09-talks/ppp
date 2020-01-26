test_data <- jsonlite::read_json(system.file("plumber", "model", "test-data.json", package = "ppp"), simplifyVector = TRUE)
rand_nas <- function(v, p = 0.1) {
  ind <- runif(length(v))
  ifelse(ind <= p, NA, v)
}
bad_data <- dplyr::transmute_all(test_data, rand_nas)

test_that("predict works", {
  v_out <- predict_sale_price(test_data, all = FALSE, log = FALSE)
  vl_out <- predict_sale_price(test_data, all = FALSE, log = TRUE)
  d_out <- predict_sale_price(test_data, all = TRUE, log = FALSE)
  dl_out <- predict_sale_price(test_data, all = TRUE, log = TRUE)

  # Check return types
  expect_type(v_out, "double")
  expect_type(d_out, "list")

  # Check return values
  expect_gte(min(v_out), 0)
  expect_gte(min(vl_out), 0)
  expect_lt(max(vl_out), 10)
  expect_equal(log10(v_out), vl_out)
  expect_equal(10 ^ vl_out, v_out)

  # Bad data
  expect_error(predict_sale_price())
  expect_error(predict_sale_price(mtcars))
  expect_warning(predict_sale_price(bad_data))
})
