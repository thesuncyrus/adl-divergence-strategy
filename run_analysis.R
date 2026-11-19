suppressPackageStartupMessages(library(quantstrat))
source("src/indicators.R")
source("src/strategy.R")
source("data/download_prices.R")
args <- commandArgs(trailingOnly = TRUE)
windows <- if (length(args)) as.integer(strsplit(args[1], ",", fixed = TRUE)[[1]]) else as.integer(adl_config$default_window)
symbols <- if (length(args) > 1) strsplit(args[2], ",", fixed = TRUE)[[1]] else project_symbols
out <- if (length(args) > 2) args[3] else "outputs"
stopifnot(!anyNA(windows), all(windows >= 2), !anyDuplicated(symbols))
prices <- read_or_download_prices(symbols)
summaries <- lapply(windows, function(w) run_backtest(prices, w, file.path(out, as.character(w))))
write.csv(do.call(rbind, summaries), file.path(out, "window-comparison.csv"), row.names = FALSE)
print(do.call(rbind, summaries))
