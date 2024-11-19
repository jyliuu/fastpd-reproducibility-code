library(tidyverse)

bench_times_background_shap <- read_csv("../simulation_runtime_shap_vs_glex/bench_times_shap.csv")

# Create a vector of file names
file_names <- paste0("../simulation_runtime_shap_vs_glex/bench_times_fastpd", 1:8, ".rds")

# Read all .rds files and combine them into one tibble
bench_times_glex <- file_names %>%
  map_dfr(readRDS)

bench_times_glex

r1 <- bench_times_background_shap |>
  select(N, median) |>
  mutate(method = "A")

r2 <- bench_times_glex |>
  select(N, median) |>
  mutate(method = "B")

to_plot <- rbind(r1, r2)


p1 <- ggplot(to_plot, aes(x = N, y = median, color = method)) +
  geom_point() +
  geom_line(aes(group = method)) +
  labs(
    x = "$n_b, n_f$",
    y = "Time (s)",
    # title = "Time complexity for background = foreground",
    color = "Method" # Set the legend title
  ) +
  theme(legend.position = "right") # Set the legend position to bottom
p1
