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

以`R CMD Rprof method1.out`的結果為例：

	Each sample represents 0.02 seconds.
	Total run time: 168.98 seconds.

	Total seconds: time spent in function and callees.
	Self seconds: time spent in function alone.

	   %       total       %        self
	 total    seconds     self    seconds    name
	 100.0    168.98       0.4      0.74     fun1
	  99.4    167.98      99.4    167.98     rbind
	   0.1      0.20       0.1      0.20     any
	   0.0      0.04       0.0      0.04     is.na
	   0.0      0.02       0.0      0.02     !


	   %        self       %      total
	  self    seconds    total   seconds    name
	  99.4    167.98      99.4    167.98     rbind
	   0.4      0.74     100.0    168.98     fun1
	   0.1      0.20       0.1      0.20     any
	   0.0      0.04       0.0      0.04     is.na
	   0.0      0.02       0.0      0.02     !

這份報告共有兩個表格：

- 表格一：
  - `fun1`(進入到退出之間)總共花了168.98秒，佔總時間的100%，但是本身(扣除可以分割的部份)只花了0.74秒，佔0.4%
  - `rbind`(進去到退出之間)花了167.98秒，佔總時間的99.4%，但是本身花了167.98秒，佔整體的99.4%
- 表格二則和表格一類似，只是表格一是依照進入和退出間所佔的時間來排序，而表格二是依照本身的執行時間來排序。

由此可知，我們只要能夠針對表格二的前面數列的函數進行優化，就可以大幅度改進程式效能。

接下來看`R CMD Rprof method2.out`的結果：


	Each sample represents 0.02 seconds.
	Total run time: 0.58 seconds.

	Total seconds: time spent in function and callees.
	Self seconds: time spent in function alone.

	   %       total       %        self
	 total    seconds     self    seconds    name
	 100.0      0.58      69.0      0.40     fun2
	  13.8      0.08      13.8      0.08     any
	  10.3      0.06      10.3      0.06     is.na
	   3.4      0.02       3.4      0.02     !
	   3.4      0.02       3.4      0.02     matrix


	   %        self       %      total
	  self    seconds    total   seconds    name
	  69.0      0.40     100.0      0.58     fun2
	  13.8      0.08      13.8      0.08     any
	  10.3      0.06      10.3      0.06     is.na
	   3.4      0.02       3.4      0.02     !
	   3.4      0.02       3.4      0.02     matrix


這裡使用`matrix`來取代`rbind`之後，剩下效能的瓶頸就落在`any`上。
所以`fun3`更進一步的不使用`any`，得到：


	Each sample represents 0.02 seconds.
	Total run time: 0.12 seconds.

	Total seconds: time spent in function and callee
	Self seconds: time spent in function alone.

	   %       total       %        self
	 total    seconds     self    seconds    name
	 100.0      0.12      16.7      0.02     fun3
	  66.7      0.08      66.7      0.08     |
	  16.7      0.02      16.7      0.02     is.na


	   %        self       %      total
	  self    seconds    total   seconds    name
	  66.7      0.08      66.7      0.08     |
	  16.7      0.02     100.0      0.12     fun3
	  16.7      0.02      16.7      0.02     is.na


可以看到效能又好了近5倍(0.12 : 0.58)！

# 參考資料

* [Rdebug](http://www.math.ncu.edu.tw/~chenwc/R_note/reference/debug/Rdebug.pdf)