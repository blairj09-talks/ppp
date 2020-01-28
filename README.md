# Practical Plumber Patterns

This repository was used for a talk of the same name given at RStudio::conf 2020

---

This repository is an [R package](http://r-pkgs.had.co.nz/) that contains a
collection of resources demonstrating various patterns for developing APIs in R
using [Plumber](https://www.rplumber.io/). The patterns demonstrated here can be
used together or in isolation, and are designed to address specific points of
API development in R.

This package is based around the idea of deploying a machine learning model as
an API. The model is built on the [Ames Housing
Data](http://jse.amstat.org/v19n3/decock.pdf) and details about the model can be
found in [`/inst/plumber/model`](inst/plumber/model).

## Testing
Testing in R is best accomplished within an R package. The
[`testthat`](https://testthat.r-lib.org/) package provides a framework for
building unit tests in R. In order to take advantage of that framework, Plumber
APIs can be developed as R packages. This repository follows that pattern.
Further detail about this pattern can be found at
[sol-eng/plumbpkg](https://github.com/sol-eng/plumbpkg).

Testing Plumber APIs can be broken down into two distinct ideas:

1. Testing R behavior
Testing R behavior is the primary purpose of tools like `testthat`. The idea is
to write tests that verify the expected behavior of R functions.

2. Testing API behavior
Testing API behavior involves ensuring the API is acting as expected. This
includes checking response codes and types.

In this repository, R functions are written in [`R/predict.R`](R/predict.R) and
then referenced in
[`inst/plumber/pkg-api/plumber.R`](inst/plumber/pkg-api/plumber.R). The R
functions are tested in
[`tests/testthat/test-predict.R`](tests/testthat/test-predict.R) and the API
behavior is tested in
[`tests/testthat/test-plumber.R`](tests/testthat/test-plumber.R).

Testing API behavior requires a running version of the API to test against. This
can be accomplished using the [`callr`](https://callr.r-lib.org/) package to run
the API as a background R process.

## Deploying
There are a [variety of ways to deploy and host Plumber
APIs](https://www.rplumber.io/docs/hosting.html). This example uses [Git backed
deployment](https://docs.rstudio.com/connect/user/git-backed/) to [RStudio
Connect](https://rstudio.com/products/connect/).

## Scaling
Once an API has been deployed, understanding API performance becomes critical to
maintaining an acceptable user experience. There are a few common patterns
useful for understanding how and when to scale deployed APIs.

1. Implement API logging
A complete example of logging details from Plumber APIs is available at
[sol-eng/plumber-logging](https://github.com/sol-eng/plumber-logging). This
package implements the patterns outlined there. Logging allows you to understand
how often requests are being made along with details about the types of
requests.

2. Load test the API
Load testing is the process of simulating high load against a service (in this
case the service is a Plumber API) to determine how the service responds. Load
testing is not an idea unique to R, and there are [a variety of
tools](https://github.com/denji/awesome-http-benchmark) for load testing. One
option that may be attractive to R users is the
[`loadtest`](https://github.com/tmobile/loadtest) package, which uses [Apache
JMeter](http://jmeter.apache.org/) to conduct load testing from R.

Load testing and logging can be used to understand the perfermance of deployed
APIs. If performance isn't as expected, a number of actions can be taken:

1. The R code should be investigated to determine if there are any
inefficiencies to address. Tools like
[`profvis`](https://rstudio.github.io/profvis/) can be used to find areas of the
code that could be improved.
2. Adjust the [Runtime
settings](https://support.rstudio.com/hc/en-us/articles/231874748-Scaling-and-Performance-Tuning-in-RStudio-Connect)
in RStudio Connect.
3. Scale out the deployment infrastructure.

---

## Usage
This package can be installed with the following:

```r
# install.packages("remotes")
remotes::install_github("blairj09/ppp")
```

There are two functions exported in this package:

`predict_sale_price()` is an R function that will return predictions on new data based on the trained model.
`run_predict_api()` will run the Plumber API for providing predicted values
