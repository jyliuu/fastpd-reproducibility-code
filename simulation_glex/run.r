library(future)
library(future.apply)
library(doFuture)

registerDoFuture()
plan(multicore)


devtools::load_all(path = "../glex")

source("main_loop.r")

params <- data.frame(
  n = c(500, 5000),
  c = c(0.3, 0.3),
  s = c(FALSE, FALSE)
)

set.seed(1)
complete_res <- list()
for (i in seq_along(params$n)) {
  sim_params <- params[i, ]
  nsim <- 100
  sim_res <- simulate_for_B(sim_params$n, sim_params$c, sim_params$s, B = nsim, par = T)

  complete_res[[i]] <- list(params = sim_params, sim_res = sim_res)
}


save(complete_res, file = paste0("complete_res.RData"))
print("Finished! and saved")
