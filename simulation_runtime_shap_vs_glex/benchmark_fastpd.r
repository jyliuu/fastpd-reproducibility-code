source("import_export_data.r")
devtools::load_all("../glex")

save_bench_res <- function(bench_res, save_name) {
  saveRDS(bench_res, save_name)
}

benchmark_fastpd_xg_vs_N <- function(
  xg,
  dat,
  N = (1:5) * 100,
  min_iterations = 55,
  save_name = NULL
) {
  bench_res_increasing_N <- bench::press(
    N = N,
    {
      bench::mark(
        glex::glex(xg, dat[1:N, -8], probFunction = "fastpd"),
        check = FALSE,
        min_iterations = min_iterations,
        time_unit = "s"
      )
    }
  )
  if (!is.null(save_name)) {
    saveRDS(bench_res_increasing_N, save_name)
  }
  bench_res_increasing_N
}


# Load the data
xg <- import_xgboost_model("model.model")
dataset <- import_data_from_csv("data.csv")

# Function to run the benchmark for a given i
run_benchmark <- function(i) {
  benchmark_fastpd_xg_vs_N(
    xg, dataset,
    N = i * 1000,
    min_iterations = 100,
    save_name = paste0("bench_times_fastpd", i, ".rds")
  )
}


for (i in 1:8) {
  run_benchmark(i)
}
