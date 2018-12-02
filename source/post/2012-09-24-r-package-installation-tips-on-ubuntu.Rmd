---
layout: post
title: "R package installation tips on Ubuntu"
date: 2012-09-24 13:18
comments: true
categories: R
---

# rgl

``` sh
sudo apt-get install r-cran-rgl
```

# RBGL, R interface to the Boost Graph Library

``` r
#! /usr/bin/R
source("http://bioconductor.org/biocLite.R")
biocLite("RBGL")
```
