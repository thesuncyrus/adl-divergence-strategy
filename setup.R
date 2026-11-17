cran <- c("quantmod", "xts", "zoo", "PerformanceAnalytics", "foreach", "remotes")
missing <- cran[!vapply(cran, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
repos <- c(FinancialInstrument = "braverock/FinancialInstrument@98bcf09fc80e25611897404dcd59321ef67850ac",
           blotter = "braverock/blotter@dddb448f7a5d6eb63dfbe421ba80779e820a3601",
           quantstrat = "braverock/quantstrat@1114e4a1a8a3b68d2fb7a62b52d743cbc5e4b39f")
for (pkg in names(repos)) if (!requireNamespace(pkg, quietly = TRUE))
  remotes::install_github(repos[[pkg]], upgrade = "never")
cat("R dependencies are available.\n")
