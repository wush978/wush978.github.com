---
layout: post
title: "試用Interactive charts and slides with R"
date: 2012-06-04 10:18
comments: true
categories: 
---

# 簡介 #

新版的RStudio(0.98.228) 推出了[Using Markdown with RStudio](http://www.rstudio.org/docs/authoring/using_markdown)，這對於我這個markdown愛好者來說可是大利多呀!!

簡單來說，就是透過以下的流程產生文件:

Rmd --> Markdown --> HTML

這裡的Markdown同時還支援:

- [Github的擴充](https://github.github.com/github-flavored-markdown)，更方便的插入code block
- [Sundown](https://github.com/tanoku/sundown)，支援表格等其他功能
- [MathJax](http://www.mathjax.org/)，支援數學方程式

想了就覺得非常方便!

# 使用 #

1. 安裝R package [knitr](http://yihui.name/knitr/)。我在2.13版本之前的R是無法安裝的，所以想試用的朋友記得把R的版本更新。
2. 打開Rstudio ，File --> New --> R Markdown
3. 編輯markdown檔案，儲存為`xxx.Rmd`或`xxx.md`。注意: 副檔名若為`md`，就無法使用嵌入R圖片的功能。
4. 點選編輯器上的`Knit HTML`就可以預覽產生的HTML格式。目前我個人在這部分遇到困難: 我沒有辦法把R畫出來的圖嵌入產生的HTML內。

# 語法範例 #

這裡是我試過的範例。有興趣的大大可以到[knitr-example](https://github.com/yihui/knitr/tree/master/inst/examples) 看看更多的範例。

- 嵌入R語法:
        ``` {r}
        cat("hello world")
        ```
- 嵌入R圖面
        ``` {r 圖片標題, message=FALSE, fig.width=7, fig.height=5}
        plot(cars)
        ```
- 行內嵌入方程式
        $latex X_t = \mu_t + \varepsilon_t$
- 方程式區塊
        $$latex
            \begin{aligned}
            X_t = \mu_t + \varepsilon_t \\
            \varepsilon_t ~ Normal(0,1)
            \end{aligned}
        $$
- 跳脫字元
    - 要跳脫`$latex`，使用HTML的語法: `&#36;latex`
    
# 全命令列環境

根據stackoverflow裏的某位大大提示，其實knitr套件提供了直接在R中轉換.Rmd至.md的語法：

``` r rmd2md
require(knitr) # required for knitting from rmd to md
require(markdown) # required for md to html 
knit('test.rmd', 'test.md') # creates md file
markdownToHTML('test.md', 'test.html') # creates html file
browseURL(paste('file://', file.path(getwd(),'test.html'), sep='')) # open file in browser
```

理解了這件事情後，就可以寫出Makefile來在命令列編譯。

# 我自己的擴充

我都是透過php + R 來拼湊出下面這耶東西，環境都是Ubuntu

* [knitr2octopress](https://github.com/wush978/knitr2octopress) : 將Rmd轉換出來的.md檔案內的圖片連結，轉換為使用[Data URI scheme](http://en.wikipedia.org/wiki/Data_URI_scheme)的格式。
* [yml2rmd](https://github.com/wush978/yml2rmd) : 利用yml格式來產生大量圖表的.Rmd檔案，這個文件我還沒空寫, 以後慢慢補...

# 參考資料 #

[Interactive charts and slides with R, googleVis and knitr](https://gist.github.com/2816027)
[R-blogger: Interactive HTML presentation with R, googleVis, knitr, pandoc and slidy](http://www.r-bloggers.com/interactive-html-presentation-with-r-googlevis-knitr-pandoc-and-slidy/)
[How to convert R Markdown to HTML? I.e., What does “Knit HTML” do in Rstudio 0.96?](http://stackoverflow.com/questions/10646665/how-to-convert-r-markdown-to-html-i-e-what-does-knit-html-do-in-rstudio-0-9)
