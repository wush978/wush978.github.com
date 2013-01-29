---
layout: post
title: "Using Eclipse CDT to develop Rcpp Package"
date: 2013-01-29 15:16
comments: true
categories: R Eclipse Rcpp Cmake
---

Rstudio is great, but it lacks some useful features for C/C++ provided 
by modern IDE such as tracing. Eclipse CDT is a good choice, but it is
complicated to setup the project correctly.

I just wrote a cmake script to generate Eclipse CDT project for 
developing Rcpp package.

# Environment

- CMake >= 2.8.7
- Eclipse >= 3.7
- Eclipse CDT >= 1.4.2
- R >= 2.15
- Rcpp >= 0.10

# Configuration

- Download FindLibR.cmake from [github](https://github.com/rstudio/rstudio/blob/master/cmake/modules/FindLibR.cmake) 
  provided by Rstudio
  
- Generate Rcpp package, for example

```r
library(Rcpp)
Rcpp.package.skeleton("RcppPackage")
```

- Put the following file, named *CMakeLists.txt* in the generated folder
  such as `RcppPackage` in the previous example

```cmake CMakeLists.txt
cmake_minimum_required(VERSION 2.8)
project(RcppPackage)
find_package(LibR)
if(${LIBR_FOUND})
else()
	message(FATAL_ERROR "No R...")
endif()
message(STATUS ${CMAKE_SOURCE_DIR})
execute_process(
    COMMAND ${LIBR_EXECUTABLE} "--slave" "-e" "stopifnot(require('Rcpp'));cat(Rcpp:::Rcpp.system.file('include'))"
    OUTPUT_VARIABLE LIBRCPP_INCLUDE_DIRS
    ) 
include_directories(BEFORE ${LIBR_INCLUDE_DIRS})
message(STATUS ${LIBR_INCLUDE_DIRS})
include_directories(BEFORE ${LIBRCPP_INCLUDE_DIRS})
message(STATUS ${LIBRCPP_INCLUDE_DIRS})
add_custom_target(RcppPackage ALL
	COMMAND find ${CMAKE_SOURCE_DIR} -name "*.o" -exec rm "{}" "\;"
	COMMAND find ${CMAKE_SOURCE_DIR} -name "*.so" -exec rm "{}" "\;"
	COMMAND ${LIBR_EXECUTABLE} "--slave" "-e" "\"stopifnot(require(roxygen2));roxygenize('${CMAKE_SOURCE_DIR}',roclets=c('rd','collate','namespace'))\""
	COMMAND ${LIBR_EXECUTABLE} CMD INSTALL "${CMAKE_SOURCE_DIR}")
```

- Customize CMakeLists.txt such `roxygenize` and `R CMD INSTALL`

- Generate project with cmake

```sh
mkdir build # don't create subdirectory of RcppPackage
cd build
cmake -G "Eclipse CDT4 - Unix Makefiles" <path to RcppPackage> -DCMAKE_ECLIPSE_GENERATE_SOURCE_PROJECT=TRUE
```

- Open eclipse and import project from `build`(See [cmake-eclipse-cdt] for example). 
  After indexing, enjoy several convenient features provided by Eclipse CDT 
  such as tracing and autocomplete.
  
- You can build the project which will be converted to `R CMD INSTALL` or
  anything in the *CMakeLists.txt*.

[cmake-eclipse-cdt]: http://www.vtk.org/Wiki/Eclipse_CDT4_Generator
