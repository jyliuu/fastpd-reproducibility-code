source("simulate_functions.r")
source("summary.r")
source("cv.r")

library(glex)


obtain_glex_objs <- function(dataset, model, cov_args, only_emp_p = F) {
  x <- dataset$x
  true_p <- function(...) probFunction_(..., cov_args)
  emp_p <- function(...) probFunctionEmp_(..., x)


  glex_treeshap <- glex(model, x, probFunction = "path-dependent")
  glex_true_p <- glex(model, x, probFunction = true_p)
  glex_emp_p <- glex(model, x, probFunction = "fastpd")
  glex_objs <- list(true_p = glex_true_p, TreeSHAP = glex_treeshap, fastpd = glex_emp_p)
  if (!only_emp_p) {
    # emp_p50 <- function(...) probFunctionEmp_(..., x[1:50, ])
    # emp_p100 <- function(...) probFunctionEmp_(..., x[1:100, ])

    glex_emp_p50 <- glex(model, x, probFunction = "fastpd50")
    glex_emp_p100 <- glex(model, x, probFunction = "fastpd100")
    glex_objs <- c(glex_objs, list(fastpd50 = glex_emp_p50, fastpd100 = glex_emp_p100))

    if (nrow(x) > 500) {
      # emp_p500 <- function(...) probFunctionEmp_(..., x[1:500, ])
      glex_emp_p500 <- glex(model, x, probFunction = "fastpd500")
      glex_objs <- c(glex_objs, list(fastpd500 = glex_emp_p500))
    }
  }

  glex_objs
}

obtain_shap_MSEs <- function(glex_true_p, to_explain) {
  emp_shap_MSEs <- lapply(to_explain, function(glex_obj) get_emp_shap_MSE(glex_obj, glex_true_p))
  emp_shap_REs <- lapply(to_explain, function(glex_obj) get_emp_shap_RE(glex_obj, glex_true_p))

  emp_shap_MSE_df <- do.call(rbind, lapply(emp_shap_MSEs, unlist))
  emp_shap_RE_df <- do.call(rbind, lapply(emp_shap_REs, unlist))

  list(B_shap_mse = emp_shap_MSE_df, B_shap_re = emp_shap_RE_df)
}

obtain_component_MSEs <- function(true_components_fun, glex_true_p, to_explain) {
  true_m <- true_components_fun(glex_true_p$x)
  emp_m <- glex_true_p$m

  true_m_MSEs <- lapply(to_explain, function(glex_obj) get_components_MSE(glex_obj, true_m))
  emp_m_MSEs <- lapply(to_explain, function(glex_obj) get_components_MSE(glex_obj, emp_m))


  true_m_MSEs_df <- do.call(rbind, lapply(true_m_MSEs, unlist))
  emp_m_MSEs_df <- do.call(rbind, lapply(emp_m_MSEs, unlist))

  list(A_m_mse = true_m_MSEs_df, B_m_mse = emp_m_MSEs_df)
}


simulate_inner <- function(n, c, s, ..., only_emp_p = F, sink = 0, par = T) {
  if (par) {
    sink(file = paste0("logs/log-", sink, "-", n, c, s, ".txt"))
    future::plan(future::multicore)
  }
  print(paste0("Simulating for n = ", n, ", c = ", c, ", s = ", s))
  sim_dat_res <- simulate_dat_wrapped(n, c, s)

  dataset <- sim_dat_res$dat
  cov_args <- sim_dat_res$cov_args

  res <- cv_and_obtain_learner(dataset, ...)
  model_mse <- res[[2]]$result$regr.mse
  model <- res[[1]]$model

  glex_objs <- obtain_glex_objs(dataset, model, cov_args, only_emp_p = only_emp_p)
  shap_MSEs <- obtain_shap_MSEs(
    glex_true_p = glex_objs[[1]],
    to_explain = glex_objs[-1]
  )
  m_MSEs <- obtain_component_MSEs(
    true_components_fun = function(...) true_components_m(..., cov_base = c),
    glex_true_p = glex_objs[[1]],
    to_explain = glex_objs[-1]
  )

  stats <- list(shap_MSEs, m_MSEs)
  list(dataset = dataset, model = model, glex_objs = glex_objs, stats = stats)
}

simulate_for_B <- function(n, c, s, B = 5, par = T, ...) {
  if (par) {
    future_lapply(1:B,
      function(iter) simulate_inner(n, c, s, sink = iter, par = T, ...),
      future.seed = T
    )
  } else {
    lapply(1:B, function(iter) simulate_inner(n, c, s, par = F, ...))
  }
}

simulate_for_N <- function(N, c, s, par = T, ...) {
  simulate_inner(N, c, s, par = par, sink = N, ...)
}


main_loop <- function(B = 100, N = c(500, 5000), C = c(0.3, 0), S = c(T, F)) {
  combinations_to_try <- expand.grid(n = N, c = C, s = S)

  complete_res <- list()
  for (i in seq_len(nrow(combinations_to_try))) {
    comb <- combinations_to_try[i, ]
    sim_res <- simulate_for_B(comb$n, comb$c, comb$s, B)

    complete_res[[i]] <- list(params = comb, sim_res = sim_res)
  }

  complete_res
}
