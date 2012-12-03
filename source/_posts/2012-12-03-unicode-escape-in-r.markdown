---
layout: post
title: "unicode escape in R"
date: 2012-12-03 17:14
comments: true
categories: R unicode 中文
---

# 簡介

最近需要分析中文資料，就遇到了unicode escape的問題。

除了抓下來的資料問題外，就是轉JSON的時候也會跑出來

```r
library(rjson)
toJSON("測試")
toJSON("測試", "R")
```

```sh
> library(rjson)
> toJSON("測試")
[1] "\"\\u6e2c\\u8a66\""
> toJSON("測試", "R")
[1] "\"測試\""
> 
```

中間的`\u6e2c\u8a66`就是unicode escape

# 解法原理

上面的`\u6e2c`中，`\u`是header，`6e2c`是__UTF16BE__編碼的hex code。

了解這點之後，就很容易自己做出解決方法：

- 利用regular expression(如`gregexpr`)定位`\\u[0-9a-f]{4,4}`
- 利用iconv把後面的兩個byte從__UTF16BE__轉換回__UTF8__

# 很弱的實作

但是我在R裏面沒有找到原生的hex轉string的函數，最後就自己刻了兩個函數，效能很差。

- [`hex2str`](git://gist.github.com/4193275.git)
- [`remove_unicode_escape`](git://gist.github.com/4193405.git)

但是原理知道了，所以之後我有空可能刻個C++的解決方案。
