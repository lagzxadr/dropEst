#pragma once

#include "dropestr.h"
#include <RcppEigen.h>

#include <unordered_map>
#include <string>

//' @export
class CppMap{
public:
  using data_t = std::unordered_map<std::string, double>;

private:
  data_t _data;

public:
  CppMap();
  CppMap(s_vec_t names, std::vector<double> values);
  CppMap(SEXP sexp);

  operator SEXP() const {
    return WrapInReferenceClass(*this, "CppMap");
  }

  void set(const std::string &key, double value);
  void clear();

  Rcpp::NumericVector at(const s_vec_t &keys) const;
  const data_t& data() const;
  size_t size() const;
};

// Expose the classes
RCPP_MODULE(CppMap) {
  using namespace Rcpp;

  class_<CppMap>( "CppMap")
    .default_constructor("Default constructor")
    .constructor<SEXP>()
    .constructor<s_vec_t, std::vector<double>>()
    .method("at", &CppMap::at)
    .method("set", &CppMap::set)
    .method("size", &CppMap::size)
    .method("clear", &CppMap::clear)
  ;
}
