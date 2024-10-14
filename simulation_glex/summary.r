
# target parameter B
get_emp_shap_MSE <- function(glex_obj, glex_target_b) {
  lapply((glex_target_b$shap - glex_obj$shap)^2, mean)
}

get_emp_shap_RE <- function(glex_obj, glex_target_b) {
  lapply(abs(glex_target_b$shap - glex_obj$shap)/abs(glex_obj$shap), mean)
}


# m_target is data.table of "x1", "x2" and "x1:x2"
get_components_MSE <- function(glex_obj, m_target) {
  lapply((glex_obj$m - m_target)^2, mean)
}
