#include <Rcpp.h>
#include <algorithm>

bool containsNumber(Rcpp::IntegerVector& vec, int target);


// [[Rcpp::export]]
Rcpp::NumericMatrix recurseAugmented(Rcpp::NumericMatrix& x, Rcpp::IntegerVector& feature, Rcpp::NumericVector& split,
                            Rcpp::IntegerVector& yes, Rcpp::IntegerVector& no, Rcpp::NumericVector& quality, Rcpp::IntegerVector& cover, 
                            std::vector<std::vector<unsigned int> >& U, unsigned int node, Rcpp::Function leafEvalFunction) {

  // Start with all 0
  unsigned int n = x.nrow();
  Rcpp::NumericMatrix mat(n, U.size());

  // If leaf, just return value
  if (feature[node] == 0) {
    for (unsigned int j = 0; j < U.size(); ++j) {
      double p = Rcpp::as<double>(leafEvalFunction(node, U[j]));
      Rcpp::NumericMatrix::Column to_fill = mat(Rcpp::_ , j);
      std::fill(to_fill.begin(), to_fill.end(), quality[node] * p);
    }
  } else {
    // Call both children, they give a matrix each of all obs and subsets
    const int curr_feature = feature[node];
    Rcpp::IntegerVector this_values = Rcpp::clone(cover);
    if (!containsNumber(this_values, curr_feature)) this_values.push_back(curr_feature);
    Rcpp::NumericMatrix mat_yes = recurseAugmented(x, feature, split, yes, no, quality, this_values, U, yes[node], leafEvalFunction);
    Rcpp::NumericMatrix mat_no = recurseAugmented(x, feature, split, yes, no, quality, this_values, U, no[node], leafEvalFunction);

    for (unsigned int j = 0; j < U.size(); ++j) {
      // Is splitting feature out in this subset?
      bool isout = false;
      for (unsigned int k = 0; k < U[j].size(); ++k) {
        if (U[j][k] == feature[node]) {
          isout = true;
        }
      }

      if (isout) {
        // For subsets where feature is out, weighted average of left/right
        for (unsigned int i = 0; i < n; ++i) {
          mat(i, j) += mat_yes(i, j) + mat_no(i, j);
        }
      } else {
        // For subsets where feature is in, split to left/right
        for (unsigned int i = 0; i < n; ++i) {
          if (x(i, feature[node]-1) <= split[node]) {
            mat(i, j) += mat_yes(i, j);
          } else {
            mat(i, j) += mat_no(i, j);
          }
        }
      }
    }
  }

  // Return combined matrix
  return(mat);
}
