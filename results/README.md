# Project result tables

- `project-five-stock-statistics.csv`: per-stock output from the supplied rendered project analysis (`Project-PT2.html`), using a 120-observation window. Its Average column is the mean of the displayed stock values.
- `project-variant-comparison.csv`: presentation pages 10–11, comparing five smoothing windows and five-/40-stock universes. Presentation values are rounded; they are not re-labeled as newly computed run outputs.

`mean_percent_positive` is an unweighted average of each stock's percentage of positive closed trades. It is not a pooled trade win rate. `mean_ann_sharpe_field` is the mean of `tradeStats`' P&L-based `Ann.Sharpe` field, not daily account-return Sharpe. `mean_profit_to_max_draw` is the mean per-stock profit-to-maximum-drawdown ratio.

Local analysis results are written under `outputs/`, including per-stock trade tables and a separately named daily-account-return Sharpe statistic.
