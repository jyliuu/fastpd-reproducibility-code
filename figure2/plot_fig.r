library(tidyverse)

BoxPlot <- function(
  res,
  settings,
  coord,
  MSEtype) {
  # Plots boxplots of different types of MSE for different settings
  # res: result of simulation
  # settings: settings for which to plot box plot
  # coord: coordinate to show MSE for
  # MSEtype: type of MSE to use
  data <- NULL
  for (i in settings) {
    estType <- c("TreeSHAP-path", "FastPD", "FastPD-50", "FastPD-100")
    if (as.numeric(res[[i]]$params[1]) > 500) {
      estType <- c(estType, "FastPD-500")
    }
    for (j in seq_along(res[[i]]$sim_res)) {
      glex_objs <- res[[i]]$sim_res[[j]]$glex_objs
      stats <- res[[i]]$sim_res[[j]]$stats

      table <- cbind(res[[i]]$params, stats[[1]][[MSEtype]], Method = estType, row.names = NULL)
      data <- rbind(data, table)
    }
  }
  data$Method <- factor(data$Method, levels = c("FastPD", "FastPD-500", "FastPD-100", "FastPD-50", "TreeSHAP-path"))
  levels(data$Method) <- c("FastPD", "FastPD-500", "FastPD-100", "FastPD-50", "TreeSHAP-path")

  addBox <- data[data$Method == "FastPD-100", ]
  addBox$Method <- factor("TreeSHAP-int")

  data <- rbind(data, addBox)
  data$Method <- factor(data$Method, levels = c("FastPD", "FastPD-500", "FastPD-100", "FastPD-50", "TreeSHAP-int", "TreeSHAP-path"))

  library(RColorBrewer)

  # Define the palette for the reds and blues
  reds <- brewer.pal(9, "YlOrRd")   # 3 shades of red
  blues <- brewer.pal(9, "Blues") # 2 shades of blues

  p <- ggplot(data, aes_string(x = "as.factor(n)", y = coord, fill = "Method")) +
    scale_y_log10() +
    geom_boxplot(width = 0.8, lwd = 0.1, outlier.size = 0.5) +
    labs(x = "$n$", y = "MSE") +
    scale_fill_manual(values = c(
    "FastPD" = reds[7],        # dark red
    "FastPD-500" = reds[6],    # med-dark red
    "FastPD-50" = reds[4],     # light red
    "FastPD-100" = reds[5],  # med red
    "TreeSHAP-path" = blues[8], # dark blue
    "TreeSHAP-int" = blues[5] # med blue
    )) +
    theme(
      legend.position = "right",
      legend.key.size = unit(0.4, "cm"),
      legend.text = element_text(size = 6)  # Adjust legend text size here
  )

  return(p)
}

load("../simulation_glex/complete_res.RData")

BoxPlot(res = complete_res, settings = c(1, 2), coord = "x1", MSEtype = "B_shap_mse")
