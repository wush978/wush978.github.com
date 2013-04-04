---
layout: post
title: "R 錯誤處理"
date: 2013-04-04 11:00
comments: true
categories: R error exception
---

R 的官方文件在[Exception handling](http://cran.r-project.org/doc/manuals/R-lang.html#Exception-handling)有介紹R的例外處理機制。

這裡我簡單介紹如何在R寫出類似java、c++或python等主流語言所使用的try-catch機制。

另外這裡講的都是以R2.15為主。

# 錯誤相關的函數

- `warning(...)`: 拋出一個警告
- `stop(...)`: 拋出一個例外
- `surpressWarnings(expr)`: 忽略`expr`中發生的警告
- `try(expr)`: 嘗試執行
- `tryCatch`: 最主流語言例外處理的方法
- `conditionMessage` : 顯示錯誤訊息

# R 和其他主流語言的不同

R 語言處理例外的方式，是透過函數，而非像其他主流語言使用try ... catch ... 等語法。這是因為R 語言幾乎所有功能都是用函數來實作的。請參考[Every operation is a function call](https://github.com/hadley/devtools/wiki/Functions#every-operation-is-a-function-call)。

# 一個`try`的範例

我自己最早是先發現`try`函數。`try`的用法近似於回傳expr的結果*或*執行時發生的錯誤。

```r
result <- try(..., silent=TRUE)
if (class(result) == "try-error") {
  ... # 錯誤處理
}
```

由於R是我第一個語言，所以我也就接受他了。直到我後來發現主流語言的try -- catch機制後，才覺得奇怪。

# 一個`tryCatch`的範例

後來我發現`tryCatch`函式提供了比較類似try -- catch機制的錯誤處理方法。

```r
tryCatch({
  result <- expr
}, warning = function(w) {
  ... # 警告處理
}, error = function(e) {
  ... # 錯誤處理
}, finally {
  ... # 清理
}
```

這種語法和其他主流語言的機制比起來接近多了。

# `conditionMessage`

有時候當錯誤發生時，我無法處理，需要直接回傳錯誤訊息給使用者時，或是log起來時，我們可以在`tryCatch`中使用`conditionMessage`來擷取錯誤訊息。

```r
tryCatch({
  stop("demo error")
}, error = function(e) {
  conditionMessage(e) # 這就會是"demo error"
})
```

# 錯誤處理的相關issue

就我的經驗來說，寫出一個穩健的程式碼是非常不容易的。在軟體工程中有許多文章介紹如何寫出這類程式碼。

大部份R 寫出來的script都是只用一次的，所以程式穩定不穩定就不是重點，也因此大家都很少去使用R 的例外處理機制。

某些R 使用者，會需要寫出自動化的script。而這時候為了要讓迴圈不中斷，使用者才開始使用例外處理。

但是當寫到套件時，例外處理就很重要了。這時候，函數的使用者將不再是開發者自己，而還包括其他的使用者，甚至是其他的開發者。此時例外處理就變成一門哲學了。這部份我也只略懂皮毛，下面只列出少許我知道的issue:

- 釋放資源: 由於錯誤發生時，函數會在不正常的地方退出，所以此時需要釋放一些函數中獲得的資源(如資料庫連線需要關閉)。這部份在C++可以用[RAII](http://en.wikipedia.org/wiki/Resource_Acquisition_Is_Initialization)等技術來保證資源不會被忘記釋放。然而在R中，我還不知道有什麼類似的安全機制。
- exception safety guarantees: 當使用者要基於某些函數建立複雜的程式時，通常希望這些函式是不會出錯的。[Exception safety](http://en.wikipedia.org/wiki/Exception_safety)就是在探討相關的issue。畢竟使用的函數有例外狀況時，原本的函數也跟著會有例外狀況。就像是蓋在危樓上的樓層，一定也很危險一樣。目前我也尚未看過R在這部份的功能。
- 錯誤訊息: 當錯誤發生時，提供的錯誤訊息是否能幫助使用者找到發生錯誤的理由。R在這部份也很不足，這造成要除錯R的程式時，沒有相當的經驗，是無法理解錯誤訊息的。

# 參考資料

- [Exception handling](http://cran.r-project.org/doc/manuals/R-lang.html#Exception-handling)
- [Using R — Basic error Handing with tryCatch()](http://mazamascience.com/WorkingWithData/?p=912)