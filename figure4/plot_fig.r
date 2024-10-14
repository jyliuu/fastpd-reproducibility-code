library(tidyverse)


plotMedianComponentsOnePlot <- function(
    res, setting, MSEtype, coord, titles,
    true_function = NULL) {
  # Plots the components of the glex object with median MSE
  # res: result of simulation
  # setting: setting for which to plot
  # MSEtype: type of MSE for which to calculate median MSE. Number in list c("\\hat{m}p", "TreeSHAP", "Emp", "Emp50", "Emp100", "Emp500")
  # coord: coordinate to plot components for
  # tiles: titles of the plots
  # true_function: insert function in plots. Set to NULL if length(coords)>2
  ggplot_colors <- scales::hue_pal()(5) # Generates the first two default ggplot colors
  coordsString <- paste0("x", coord)
  glexList <- list(NULL)
  compMSE <- NULL

  for (i in 1:length(res[[setting]]$sim_res)) {
    glexList[[i]] <- res[[setting]]$sim_res[[i]]$glex_objs
    compMSE[i] <- res[[setting]]$sim_res[[i]]$stats[[2]]$B_m_mse[MSEtype, coordsString] # stats 2 for components
  }

  medianIndex <- which.min(abs(compMSE - median(compMSE)))
  p <- list()

  glex_list_median <- glexList[[medianIndex]]
  glex_obj_B <- glex_list_median[[1]]
  glex_list_median <- glex_list_median[-1]

  to_plot <- data.frame(
    x = glex_obj_B$x[[coord]],
    model = glex_obj_B$m[[coord]],
    friedman  = glex_list_median[[1]]$m[[coord]],
    fastpd = glex_list_median[[2]]$m[[coord]],
    fastpd100 = glex_list_median[[4]]$m[[coord]]
  )

  names(to_plot) <- c("x", "$\\hat{m}_1(x)$", "\\texttt{Friedman-path}", "FastPD", "FastPD-100")

  to_plot_long <- to_plot |>
    pivot_longer(
      cols = -x, # Columns to pivot (excluding 'x')
      names_to = "type", # New column for variable names
      values_to = "value" # New column for values
    )

  plt <- ggplot(to_plot_long, aes(x = x, y = value, color = type, linetype = type)) +
    geom_line() +
    labs(
      x = "$x_1$",
      y = "Estimated $m_1(x)$"
    ) +
    stat_function(fun = true_function, aes(color = "$m_1^\\ast(x)$", linetype = "$m_1^\\ast(x)$"))  +
    scale_color_manual(
      name = "Line",
      values = c(
      "\\texttt{Friedman-path}" = ggplot_colors[4],
      "FastPD" = "#282424",
      "FastPD-100" = "#b739d3",
      "$\\hat{m}_1(x)$" = ggplot_colors[1],
      "$m_1^\\ast(x)$" = ggplot_colors[3]),
      limits = c("FastPD", "FastPD-100", "\\texttt{Friedman-path}", "$\\hat{m}_1(x)$", "$m_1^\\ast(x)$")
    ) +
    scale_linetype_manual(
      name = "Line",
      values = c(
        "\\texttt{Friedman-path}" = "twodash",
        "FastPD" = "twodash",
        "FastPD-100" = "twodash",
        "$\\hat{m}_1(x)$" = "solid",
        "$m_1^\\ast(x)$" = "solid"
      ),
      limits = c("FastPD", "FastPD-100", "\\texttt{Friedman-path}", "$\\hat{m}_1(x)$", "$m_1^\\ast(x)$")
    ) +
    theme(legend.position = "right")

  cat("plotting for simulation", medianIndex, "\n")
  return(plt)
}

load("../simulation_glex/complete_res.RData")

plotMedianComponentsOnePlot(
  res = complete_res, setting = 2, MSEtype = 2, coord = 1,
  true_function = function(x) {
    x - 2 * 0.3
  }
)
