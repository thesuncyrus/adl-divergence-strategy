source("config.R")
# Retrieve OHLCV/adjusted prices directly from Yahoo Finance.
project_symbols <- adl_config$symbols
read_or_download_prices <- function(symbols = project_symbols, cache = "data/prices",
                                    from = adl_config$from, to = adl_config$to) {
  dir.create(cache, recursive = TRUE, showWarnings = FALSE)
  result <- setNames(vector("list", length(symbols)), symbols)
  for (symbol in symbols) {
    stopifnot(grepl("^[A-Za-z0-9.^=-]+$", symbol))
    path <- file.path(cache, paste0(symbol, ".csv"))
    if (file.exists(path)) {
      d <- read.csv(path, check.names = FALSE)
      stopifnot(identical(names(d), c("Date", "Open", "High", "Low", "Close", "Volume", "Adjusted")))
      x <- xts::xts(as.matrix(d[-1]), order.by = as.Date(d$Date))
    } else {
      x <- quantmod::getSymbols(symbol, src = "yahoo", from = from, to = to, auto.assign = FALSE)
      stopifnot(NCOL(x) == 6)
      d <- data.frame(Date = as.Date(zoo::index(x)), zoo::coredata(x), check.names = FALSE)
      names(d) <- c("Date", "Open", "High", "Low", "Close", "Volume", "Adjusted")
      write.csv(d, path, row.names = FALSE)
    }
    x <- x[paste0(from, "/", as.Date(to)-1)]
    stopifnot(NROW(x) > 365, !anyNA(x), !anyDuplicated(zoo::index(x)),
              !is.unsorted(zoo::index(x)))
    colnames(x) <- paste(symbol, c("Open", "High", "Low", "Close", "Volume", "Adjusted"), sep = ".")
    result[[symbol]] <- x
  }
  result
}

if (sys.nframe() == 0) {
  prices <- read_or_download_prices()
  cat("Cached", length(prices), "symbols under data/prices.\n")
}
