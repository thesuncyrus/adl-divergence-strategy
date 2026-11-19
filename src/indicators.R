source("config.R")
# Price-volume indicators used by the ADL strategy.
Accumulation_Distribution_Line <- function(stock_data) {
  multiplier <- ((quantmod::Cl(stock_data) - quantmod::Lo(stock_data)) -
                   (quantmod::Hi(stock_data) - quantmod::Cl(stock_data))) /
                (quantmod::Hi(stock_data) - quantmod::Lo(stock_data))
  multiplier[is.na(multiplier) | quantmod::Hi(stock_data) == quantmod::Lo(stock_data)] <- 0
  result <- cumsum(multiplier * quantmod::Vo(stock_data))
  colnames(result) <- "ADL"
  result
}

mySMA <- function(stock_data, n) {
  stopifnot(length(n) == 1, n >= 2, n == as.integer(n))
  result <- zoo::rollmeanr(stock_data, n, fill = NA)
  colnames(result) <- "sma"
  result
}

delt_price <- function(stock_data, n = adl_config$default_window) {
  change <- quantmod::Delt(mySMA(quantmod::Ad(stock_data), n))
  change[1] <- 0
  change
}

delt_ADL <- function(stock_data, n = adl_config$default_window) {
  change <- quantmod::Delt(mySMA(stock_data$ADL, n))
  change[1] <- 0
  change
}
