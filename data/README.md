# Market data

The analysis uses daily Open, High, Low, Close, Volume and Adjusted prices for **KO, NVDA, AMZN, IBM and GOOG**, from 2010-01-01 through 2024-12-31.

Run `Rscript data/download_prices.R` from the repository root, or run the main analysis to fetch prices automatically using `quantmod::getSymbols(src = "yahoo")`. Cached CSVs are written to `data/prices/` and are excluded from Git.

CSV columns: `Date, Open, High, Low, Close, Volume, Adjusted`. Dates must be unique and increasing; values must be present. These prices are retrieved online, not bundled datasets within R.

The five-stock and 40-stock summary statistics from the presentation are in `results/project-variant-comparison.csv`.

[quantmod Yahoo data-source documentation](https://search.r-project.org/CRAN/refmans/quantmod/html/getSymbols.yahoo.html)
