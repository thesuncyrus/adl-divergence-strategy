# Existing five-stock experiment. Importing settings does not alter RNG state.
adl_config <- list(
  symbols = c("KO", "NVDA", "AMZN", "IBM", "GOOG"),
  from = "2010-01-01", to = "2025-01-01", default_window = 120,
  comparison_windows = c(5, 30, 60, 120, 365),
  order_quantity = 1000, initial_equity = 1000000,
  initialization_date = "1950-01-01", execution_price = "Open", transaction_fees = 0
)
# Percentage-change signals, long-only additions and full exits are unchanged.
