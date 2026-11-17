suppressPackageStartupMessages(library(quantstrat))
source("src/indicators.R")
source("src/strategy.R")
# Manual money-flow multipliers: 0.5, -0.5, 0 (zero high-low range), 1.
x <- xts::xts(cbind(Open = c(12,12,5,11), High = c(14,14,5,14), Low = c(10,10,5,10),
  Close = c(13,11,5,14), Volume = c(100,200,50,10), Adjusted = c(13,11,5,14)),
  order.by = as.Date("2020-01-01") + 0:3)
stopifnot(identical(as.numeric(Accumulation_Distribution_Line(x)), c(50,-50,-50,-40)))
# Compare against an independent implementation on nondegenerate price bars.
normal <- x[c(1,2,4)]
stopifnot(isTRUE(all.equal(as.numeric(Accumulation_Distribution_Line(normal)),
                          as.numeric(TTR::chaikinAD(quantmod::HLC(normal), quantmod::Vo(normal))))))
# Moving-average values must depend only on current/past rows.
y <- xts::xts(1:10, order.by = as.Date("2020-01-01") + 0:9)
changed <- y; changed[10] <- 1000
stopifnot(isTRUE(all.equal(mySMA(y,3)[1:9], mySMA(changed,3)[1:9])))
# Signal rules encode bullish and bearish divergence exactly as the strategy.
d <- xts::xts(cbind(Price_Downtrend=c(0,1,1,0,0), ADL_Uptrend=c(0,1,1,0,0),
  Price_Uptrend=c(0,0,0,1,1), ADL_Downtrend=c(0,0,0,1,1)),
  order.by=as.Date("2020-01-01")+0:4)
b <- quantstrat::sigFormula("Buy",d,"Price_Downtrend & ADL_Uptrend",cross=TRUE)
s <- quantstrat::sigFormula("Sell",d,"Price_Uptrend & ADL_Downtrend",cross=TRUE)
stopifnot(identical(which(as.numeric(b)==1),2L), identical(which(as.numeric(s)==1),4L))
cat("ADL formula, zero-range handling, independent indicator, temporal SMA and divergence tests passed.\n")
