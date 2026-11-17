"""Figures from the documented project comparison tables."""
from pathlib import Path
import csv
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

root = Path(__file__).resolve().parent
with (root/'results/project-variant-comparison.csv').open() as f:
    rows = [r for r in csv.DictReader(f) if r['stocks']=='5']
windows = [int(r['sma_observations']) for r in rows]
win = [float(r['mean_percent_positive']) for r in rows]
trades = [float(r['mean_num_trades']) for r in rows]
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11, 'svg.fonttype':'none',
                     'axes.spines.top':False,'axes.spines.right':False})
fig, axes = plt.subplots(1,2,figsize=(10.6,4.6),facecolor='#faf9f6',layout='constrained')
colors = ['#a8bdb2' if w!=120 else '#285b4c' for w in windows]
for ax, vals, ylabel in zip(axes,[win,trades],['Mean winning trades (%)','Mean closed trades per stock']):
    ax.set_facecolor('#faf9f6')
    bars=ax.bar([str(w) for w in windows],vals,color=colors,width=.65)
    ax.bar_label(bars,labels=[f'{v:.2f}' if ylabel.startswith('Mean winning') else f'{v:g}' for v in vals],padding=5,fontsize=10)
    ax.set_xlabel('SMA window (trading observations)');ax.set_ylabel(ylabel)
    ax.set_ylim(0,max(vals)*1.19);ax.grid(axis='y',alpha=.15);ax.set_axisbelow(True)
fig.suptitle('ADL divergence: smoothing changes the trade-off',fontweight='bold',fontsize=15)
fig.supxlabel('Project presentation · five stocks · 2010–2024 · unweighted per-stock averages',fontsize=9,color='#52675e')
(root/'figures').mkdir(exist_ok=True)
fig.savefig(root/'figures/window-comparison.svg');plt.close(fig)

fig,ax=plt.subplots(figsize=(9.6,4.2),facecolor='#faf9f6',layout='constrained');ax.set_facecolor('#faf9f6')
values=[float(r['mean_ann_sharpe_field']) for r in rows]
bars=ax.bar([str(w) for w in windows],values,color=colors,width=.6)
ax.bar_label(bars,labels=[f'{v:.2f}' for v in values],padding=5)
ax.set_ylim(0,12.5);ax.set_xlabel('SMA window (trading observations)')
ax.set_ylabel('Mean tradeStats Ann.Sharpe');ax.grid(axis='y',alpha=.15);ax.set_axisbelow(True)
ax.set_title('Risk-adjusted trade statistic across smoothing windows',fontweight='bold',pad=16)
fig.supxlabel('Project presentation · P&L-based statistic on selected trading days; not daily portfolio-return Sharpe',fontsize=9,color='#52675e')
fig.savefig(root/'figures/trade-statistic-comparison.svg');plt.close(fig)
