---
layout: post
title: "R: DateTime格式的心得"
date: 2012-02-29 21:53
comments: true
categories: 
---

*	[概述](#overview)
*	[函數心得](#functions)
	*	取得當前的時間
		* [Sys.time](#Sys.time)
		* [Sys.Date](#Sys.Date)
	*	時間格式間的轉換
		* [mktime](#mktime)
		* [localtime](#localtime)
		* [gmtime](#gmtime)
	*	時間和字串間的轉換
		* [strftime](#strftime)
		* [strptime](#strptime)
	* [trunc](#trunc)
*	[參考資料](#reference)

* * *

<h2 id="overview"> 概述 </h2>

R中主要的時間物件為<code>POSIXct</code>和<code>POSIXlt</code>。[Date-Time Classes]第8頁內提到設計者們在設計這類物件的考量：

-	日期格式應該由[locale]參數來決定。
-	時間應該由電腦的Time zones來決定。
-	參考資料庫標準(SQL99 ISO)中使用的時間格式<code>timestamp with time zone</code>
-	考量到跨平台，使用[POSIX]

[POSIX]是以[UTC](Coordinated Universal Time)為基準，以c語言的<code>double</code>型態來儲存的時間格式，
而<code>POSIXct</code>則是代表以這種絕對座標所表示的時間。<code>POSIXlt</code>則是另一種包含timezones的格式
(lt代表local time)。其中timezone是以屬性tzone來代表的。

以以下的程式碼為例：
``` r example from http://www.r-project.org/doc/Rnews/Rnews_2001-2.pdf
> file.info(dir())[, "mtime", drop=FALSE]
data                  2012-02-29 21:18:11
```
在預設下，是以ISO標準格式來表示日期時間。
``` r example from http://www.r-project.org/doc/Rnews/Rnews_2001-2.pdf
> file_time <- file.info(dir())[, "mtime", drop=FALSE]
> file_time
data                  2012-02-29 21:18:11
> format(file_time, format="%x %X")
data                  2012/2/29 下午 09:18:11
```

另外再列了幾個[Date-Time Classes]內的範例


	
<h2 id="functions"> 函數心得 </h2>

<h3 id="Sys.time"> Sys.time </h3>

``` r Sys.time
function ()
```
回傳<code>POSIXct</code>物件來表示現在的時間

<h3 id="Sys.Date"> Sys.Date</h3>

``` r Sys.time
function () {as.Date(as.POSIXlt(Sys.time()))}
```
回傳<code>Date</code>物件來表示現在的日期


<h3 id="trunc"> trunc </h3>

``` r trunc.POSIXt
function (x, units = c("secs", "mins", "hours", "days"), ...) 
```
將<code>x</code>的時間格式轉換為以<code>units</code>為單位

<h2 id="reference"> 參考資料 </h3>

[Date-Time Classes]: http://www.r-project.org/doc/Rnews/Rnews_2001-2.pdf
[locale]: http://en.wikipedia.org/wiki/Locale
[UTC]: http://en.wikipedia.org/wiki/Coordinated_Universal_Time