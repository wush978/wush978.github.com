---
layout: post
title: "RcppArmadillo"
date: 2012-08-21 20:08
comments: true
categories: R Rcpp RcppArmadillo
---

# Inroduction

Recently I am exploring the linear algebra features provided in [Armadillo](http://arma.sourceforge.net/) through [RcppArmadillo](http://dirk.eddelbuettel.com/code/rcpp.armadillo.html).

Here is the note for myself.

Note these functions are only my understanding of these operators and methods. I didn't check the source code of Armadillo and RcppArmadillo.

# Basic Elements and Methods

``` cpp mat
arma::mat a(5, 5); // Initialize a 5 x 5 matrix.

a.fill(0); // fill it with 0
a.n_rows;    //!< number of rows in the matrix (read-only)
a.n_cols;    //!< number of columns in the matrix (read-only)
a.n_elem;    //!< number of elements in the matrix (read-only)
a.vec_state; //!< 0: matrix layout; 1: column vector layout; 2: row vector layout
a.mem;	     //!< pointer to memory used by the matrix (memory is read-only)

a.min();
a.max();
```


# Feature

## Matrix Multiplication

``` cpp Matrix Multiplication
const arma::mat operator*(const arma::mat& x, const arma::mat& y);
```

## Transpose

``` cpp Transpose
const arma::mat arma::trans(const arma::mat& x);

// Methods of class arma::mat
// x.t() = arma::trans(x)
const arma::mat arma::mat::t();
```

## Inverse

``` cpp Inverse
const arma::mat arma::pinv(const arma::mat& x);
```

## Sum of Square

``` cpp Sum of Square
inline double sumOfSquare(arma::vec& x) {
	return std::inner_product(x.begin(), x.end(), x.begin(), 0.0);
}
```

## Diagonal Vector

``` cpp Diagonal Vector
const arma::colvec arma::diagvec(const arma::mat& x);
```

## Linear Regression

``` cpp Linear Regression
/**
 * @param X    the explanatory variables
 * @param y    the response variable
 * @return     the vector of regression coefficients
 */
const arma::colvec arma::solve(const arma::mat& X, const arma::vec& y);

// Residuals
arma::colvec residuals = y - X * coef;

// Residual Sum of Square
double s2 = sumOfSquare(residuals);

// Std of Coef.
arma::colvec sderr = arma::sqrt(s2 *
	arma::diagvec(arma::pinv(arma::trans(X)*X)));
```

