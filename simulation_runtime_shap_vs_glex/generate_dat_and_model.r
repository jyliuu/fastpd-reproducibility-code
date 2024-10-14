source("import_export_data.r")
source("../simulation_glex/simulate_functions.r")
source("../simulation_glex/cv.r")


sim_dat_fit_xgboost <- function(sim_dat_fun, learner_fun, save = TRUE) {
  dataset <- sim_dat_fun()
  xg <- learner_fun(dataset)
  if (save) {
    export_data_as_csv(dataset, "data.csv")
    export_xgboost_model(xg, "model.model")
  }

  return(list(xg = xg, dataset = dataset))
}


train_learner <- function(dataset) {
  # Run CV and obtain the best learner
  cv_res <- cv_and_obtain_learner(
    dataset,
    n_evals = 1, nrounds = 20, max_depth = 5
  )
  cv_res$learner$model
}

sim_dat_fit_xgboost(simulate_dat_7x, train_learner, save = TRUE)
