---
layout: post
title: "Profiling R code"
date: 2012-06-14 23:29
comments: true
categories: R
---

# 簡介

Profiling的意思就是去測量程式中每個函數的執行時間。
根據經驗法則，通常有80%的執行時間耗費在20%的程式碼中！
所以若有提昇執行效能的需求，第一步就是找出跑得慢得程式碼(bottlenecks)，再針對慢得程式碼去做優化。

# 介紹

ps. 以下的程式碼取自[Rdebug](http://www.math.ncu.edu.tw/~chenwc/R_note/reference/debug/Rdebug.pdf)  

考慮以下三個函數：

``` r fun1.R
fun1 <- function(x) {
	res <- NULL
	n <- nrow(x)
	for(i in 1:n) {
		if (!any(is.na(x[i,]))) {
			res <- rbind(res, x[i,])
		}
	}
	res
}
```

``` r fun2.R
fun2 <- function(x) {
	n <- nrow(x)
	res <- matrix(0, n, ncol(x))
	k <- 1
	for(i in 1:n) {
		if (!any(is.na(x[i,]))) {
			res[k,] <- x[i,]
			k <- k + 1
		}
	}
	res[1:(k-1),]
}
```

``` r fun3.R
fun3 <- function(x) {
	omit <- FALSE
	n <- ncol(x)
	for(i in 1:n) {
		omit <- omit | is.na(x[,i])
	}
	x[!omit,]
}
```

將上述三個function分別寫成script檔案後，執行：

``` r Rprof-exp-1.R
source('fun1.R')
source('fun2.R')
source('fun3.R')

size.row <- 10L^5
size.col <- 20L

x = matrix(rnorm(size.row * size.col),size.row,size.col)
x[x > 1.5] = NA
Rprof("method1.out")
fun1(x)
Rprof(NULL)
Rprof("method2.out")
fun2(x)
Rprof(NULL)
Rprof("method3.out")
fun3(x)
Rprof(NULL)
```

此時根目錄會有`method1.out`, `method2.out`, `method3.out`等三個檔案。

打開命令列，執行：

``` sh
R CMD Rprof method1.out
R CMD Rprof method2.out
R CMD Rprof method3.out
```

以`method1.out`的output為例：

	Each sample represents 0.02 seconds.
	Total run time: 1.3 seconds.

	Total seconds: time spent in function and callees.
	Self seconds: time spent in function alone.

	   %       total       %        self
	 total    seconds     self    seconds    name
	 100.0      1.30       4.6      0.06     fun1
	  93.8      1.22      93.8      1.22     rbind
	   1.5      0.02       1.5      0.02     any


	   %        self       %      total
	  self    seconds    total   seconds    name
	  93.8      1.22      93.8      1.22     rbind
	   4.6      0.06     100.0      1.30     fun1
	   1.5      0.02       1.5      0.02     any

這份報告顯示`fun1`所花得時間(1.30秒, 100%)中`rbind`佔了(1.22秒, 93.8%)、`any`佔了(0.02秒, 1.5%)。由這份報告可以很明顯的看出效能的問題出在rbind這個函數上。

# 參考資料

* [Rdebug](http://www.math.ncu.edu.tw/~chenwc/R_note/reference/debug/Rdebug.pdf)