
# Code Supplement for 'Fast Estimation of Partial Dependence Functions using Trees'
The following packages were cloned and modified for the simulations
- [shap](https://github.com/shap/shap), cloned 14/10/2024, SHA: `215c58525127761208dd2c9754bd468a0295f537` on `master`
- [glex](https://github.com/PlantedML/glex), cloned 19/11/2024, SHA: `bb2be47ca2eb2a657095ecfd1b51877dfe0debe9` on `master`

The folder `codeforsimulations` is a git repository, version history can be viewed with `git log`


## Reproducibility 
The seed used in the Figures for the main article is not the seed used in the simulations here, so therefore there might be slight variations in Figures 1 and 4 due to seed randomness. 

To reproduce Figures `1, 2` and `4`, follow these steps:
- Change working directory to `simulation_glex` 
- Ensure `R (4.4.1)` is installed with: `scico, devtools, data.table, tidyverse, reshape2, patchwork, future, future.apply, doFuture, xgboost, mvtnorm, mlr3verse`
- Run `run.r` to generate `complete_res.RData` (takes a long time, suggested to run this on a cluster)
- Run `plot_fig.r` in the folders `figure1, figure2, figure4` to generate the plots. The plot will use the data from `complete_res.RData`


To reproduce Figure `3`, follow these steps:
- Change working directory to `simulation_runtime_shap_vs_glex`
- Ensure `R (4.4.1)` is installed with: `scico, devtools, xgboost, data.table, xgboost, tidyverse, reshape2, bench`
- Run `generate_dat_and_model.r` to generate dataset of 10000 observations and XGBoost model with 20 trees
- Run `benchmark_fastpd.r` to get the FastPD benchmarks (takes a long time, suggested to run this on a cluster)
- Ensure `Python >=3.12` is installed
- Make a Python virutal environment using `python3.12 -m venv venv`
- Activate the venv `source venv/bin/activate`
- Install the modified SHAP package `pip install ../shap`
- Install XGBoost if not exists `pip install xgboost`
- Run `python benchmark_shap.py` to get the SHAP benchmarks (takes a long time, suggested to run this on a cluster)
- Change working directory to `figure3` 
- Run `plot_runtime.r` to get the benchmark plots

## SHAP package modifications
- Removed `docs, data, javascript, notebooks, scripts
- Modified `shap/explainers/_tree.py`

## glex package modifications
- Added `src/recurse_fastpd.cpp`
- Added `R/fastpd.R`
- Added auxillary functions in `glex.R` to call the FastPD implementation
