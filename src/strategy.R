# Long-only divergence rules with 1,000-share additions and full exits.
build_strategy <- function(name, window = 120, order_quantity = 1000) {
  s <- quantstrat::strategy(name)
  s <- quantstrat::add.indicator(s, "Accumulation_Distribution_Line",
    arguments = list(stock_data = quote(mktdata)), label = "ADL")
  s <- quantstrat::add.indicator(s, "delt_price",
    arguments = list(stock_data = quote(mktdata), n = window), label = "Price_Change")
  s <- quantstrat::add.indicator(s, "delt_ADL",
    arguments = list(stock_data = quote(mktdata), n = window), label = "ADL_Change")
  # The source strategy constructs its zero reference with this comparison.
  # run_backtest checks that it is zero on the selected market data.
  s <- quantstrat::add.signal(s, "sigComparison",
    arguments = list(columns = c("Volume", "Price_Change"), relationship = "lt"), label = "zero")
  for (indicator in c("Price", "ADL")) {
    for (direction in c("Downtrend", "Uptrend")) {
      s <- quantstrat::add.signal(s, "sigComparison",
        arguments = list(columns = c(paste0(indicator, "_Change"), "zero"),
                         relationship = if (direction == "Downtrend") "lt" else "gt"),
        label = paste(indicator, direction, sep = "_"))
    }
  }
  s <- quantstrat::add.signal(s, "sigFormula",
    arguments = list(formula = "Price_Uptrend & ADL_Downtrend", cross = TRUE), label = "Sell")
  s <- quantstrat::add.signal(s, "sigFormula",
    arguments = list(formula = "Price_Downtrend & ADL_Uptrend", cross = TRUE), label = "Buy")
  s <- quantstrat::add.rule(s, "ruleSignal", arguments = list(sigcol = "Buy", sigval = TRUE,
    orderqty = order_quantity, ordertype = "market", orderside = "long", prefer = "Open",
    replace = FALSE, TxnFees = 0), type = "enter")
  s <- quantstrat::add.rule(s, "ruleSignal", arguments = list(sigcol = "Sell", sigval = TRUE,
    orderqty = "all", ordertype = "market", orderside = "long", prefer = "Open",
    replace = FALSE, TxnFees = 0), type = "exit")
  s
}

run_backtest <- function(prices, window = 120, out = "outputs/120", initial_equity = 1000000) {
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  symbols <- names(prices)
  name <- paste0("adl_", window, "_", length(symbols))
  suppressWarnings(quantstrat::rm.strat(name))
  FinancialInstrument::currency("USD")
  FinancialInstrument::stock(symbols, currency = "USD", multiplier = 1)
  for (symbol in symbols) assign(symbol, prices[[symbol]], envir = .GlobalEnv)
  blotter::initPortf(name, symbols = symbols, initDate = "1950-01-01")
  blotter::initAcct(name, portfolios = name, initEq = initial_equity, initDate = "1950-01-01")
  quantstrat::initOrders(portfolio = name, initDate = "1950-01-01")
  s <- build_strategy(name, window)
  for (symbol in symbols) {
    indicators <- quantstrat::applyIndicators(s, prices[[symbol]])
    signals <- quantstrat::applySignals(s, indicators)
    stopifnot(all(signals$zero == 0, na.rm = TRUE))
    for (column in c("Price_Change", "ADL_Change")) {
      values <- as.numeric(signals[, grep(column, colnames(signals), fixed = TRUE)])
      if (any(is.infinite(values))) stop("Infinite smoothed change; inspect ", symbol, ".")
    }
  }
  quantstrat::applyStrategy(s, portfolios = name, verbose = FALSE)
  blotter::updatePortf(name)
  dates <- zoo::index(blotter::getPortfolio(name)$summary)[-1]
  blotter::updateAcct(name, dates)
  blotter::updateEndEq(name)
  stats <- blotter::tradeStats(name)
  write.csv(stats, file.path(out, "trade-statistics.csv"), row.names = FALSE)
  for (symbol in symbols) {
    txns <- blotter::getTxns(name, symbol)
    write.csv(data.frame(Date = as.Date(zoo::index(txns), tz = "UTC"), zoo::coredata(txns)),
              file.path(out, paste0(symbol, "-transactions.csv")), row.names = FALSE)
  }
  equity <- blotter::getAccount(name)$summary$End.Eq
  equity <- equity[as.Date(zoo::index(equity), tz = "UTC") >= min(as.Date(zoo::index(prices[[1]])))]
  returns <- na.omit(PerformanceAnalytics::Return.calculate(equity))
  daily_sharpe <- as.numeric(PerformanceAnalytics::SharpeRatio.annualized(returns, Rf = 0, scale = 252))
  write.csv(data.frame(Date = as.Date(zoo::index(equity), tz = "UTC"), equity = as.numeric(equity)),
            file.path(out, "account-equity.csv"), row.names = FALSE)
  summary <- data.frame(window = window, stocks = length(symbols),
    mean_trades = mean(stats$Num.Trades, na.rm = TRUE), mean_positive_pct = mean(stats$Percent.Positive, na.rm = TRUE),
    mean_trade_stats_ann_sharpe = mean(stats$Ann.Sharpe, na.rm = TRUE),
    assets_with_trade_stats_sharpe = sum(!is.na(stats$Ann.Sharpe)),
    daily_account_sharpe_annualized = daily_sharpe,
    end_equity = as.numeric(tail(equity, 1)))
  write.csv(summary, file.path(out, "summary.csv"), row.names = FALSE)
  writeLines(c(paste("Symbols:", paste(symbols, collapse = ",")),
    "Daily account Sharpe and tradeStats Ann.Sharpe use different definitions.",
    capture.output(sessionInfo())), file.path(out, "session-info.txt"))
  summary
}
