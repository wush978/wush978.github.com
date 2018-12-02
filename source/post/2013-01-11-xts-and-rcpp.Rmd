---
layout: post
title: "xts and Rcpp"
date: 2013-01-11 14:54
comments: true
categories: xts R Rcpp
---

Here is my guideline to integrate xts with Rcpp in a R package.

Because the `xts_API` is written for c language, so we need to hack
somethings to make it work with c++.

# Modify `DESCRIPTION`
  
```sh
Depends: xts, Rcpp
linkingTo: xts, Rcpp
```

# Create files in `src` directory

```c xts_api.c
#include <xts.h>
#include <xts_stubs.c>
```

```cpp xts_api.h
extern "C" {
#define class xts_class
#include <xts.h>
#undef class
}


inline SEXP install(const char* x) {
  return Rf_install(x);
}

inline SEXP getAttrib(SEXP a, SEXP b) {
  return Rf_getAttrib(a, b);
}


inline SEXP setAttrib(SEXP a, SEXP b, SEXP c) {
  return Rf_setAttrib(a, b, c);
}
```

Without the macro, there will be  compile time error:
```
error: expected identifier before ‘)’ token
```
because `xts.h` use the keyword `class`.

Without the inline functions, there will be some compile time errors:
```
error: ‘install’ was not declared in this scope
error: ‘getAttrib’ was not declared in this scope
```

Now, almost all API could be invoked in c++:

```cpp rcpp_test.cpp
#include <Rcpp.h>

#include "xts_api.h"

using namespace Rcpp;

RcppExport SEXP get_xts_index(SEXP x) {
  BEGIN_RCPP
  
  return GET_xtsIndex(x);
  
  END_RCPP
}
```

except `SET_xtsIndexClass(x, value)`:

```sh compile time error
error: ‘xts_IndexvalueSymbol’ was not declared in this scope
```

I guess that we should replace `xts_IndexvalueSymbol` with `xts_IndexClassSymbol`

## Reference

- `file.show(system.file('api_example/README', package="xts"))`
