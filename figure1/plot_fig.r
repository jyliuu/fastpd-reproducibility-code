library(tidyverse)
library(patchwork)


plotMedianShapModel <- function(res, setting, MSEtype, coord) {
  # Plots the shap of the glex object with median MSE
  # res: result of simulation
  # setting: setting for which to plot
  # MSEtype: type of MSE for which to calculate median MSE. Number in list c("TreeSHAP", "Emp", "Emp50", "Emp100", "Emp500")
  # coord: coordinate to plot shap values for
  # tiles: titles of the plots
  shapMSE <- NULL
  for (i in 1:length(res[[setting]]$sim_res)) {
    shapMSE[i] <- res[[setting]]$sim_res[[i]]$stats[[1]]$B_shap_mse[MSEtype, coord]
  }
  medianIndex <- which(shapMSE == min(shapMSE[which(shapMSE >= median(shapMSE))]))
  x <- res[[setting]]$sim_res[[medianIndex]]$dataset$x
  data <- tibble(
    x1 = x[, 1], x2 = x[, 2],
    "Model SHAP" = res[[setting]]$sim_res[[medianIndex]]$glex_objs[[1]]$shap[[coord]]
  )
  # Create the left plot with shapB and treeshap
  data_left <- tibble(data, Estimate = res[[setting]]$sim_res[[medianIndex]]$glex_objs[[2]]$shap[[coord]])
  data_left <- reshape2::melt(data_left, id = colnames(x))
  data_left <- rename(data_left, Variable = variable)
  plot_left <- ggplot(data_left, aes_string(x = coord)) +
    geom_point(aes(y = value, color = Variable), alpha = 0.3) +
    scale_color_manual(values = c("red", "blue")) +
    labs(y = "$\\phi_1(x)$", x = "$x_1$", title = "Tree SHAP-Path", color = "Type")

  data_right <- tibble(data, Estimate = res[[setting]]$sim_res[[medianIndex]]$glex_objs[[3]]$shap[[coord]])
  data_right <- reshape2::melt(data_right, id = colnames(x))
  data_right <- rename(data_right, Variable = variable)
  plot_right <- ggplot(data_right, aes_string(x = coord)) +
    geom_point(aes(y = value, color = Variable), alpha = 0.3) +
    scale_color_manual(values = c("red", "blue")) +
    labs(y = NULL, x = "$x_1$", title = "FastPD", color = "Type")
  combined_plot <- plot_left + plot_right + plot_layout(guides = "collect") & theme(legend.position = "bottom")

  combined_plot
}

load("../simulation_glex/complete_res.RData")

plotMedianShapModel(res = complete_res, setting = 1, MSEtype = 2, coord = "x1")
