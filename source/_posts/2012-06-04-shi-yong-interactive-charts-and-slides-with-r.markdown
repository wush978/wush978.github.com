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
# 參考資料 #

[Interactive charts and slides with R, googleVis and knitr](https://gist.github.com/2816027)
[R-blogger: Interactive HTML presentation with R, googleVis, knitr, pandoc and slidy](http://www.r-bloggers.com/interactive-html-presentation-with-r-googlevis-knitr-pandoc-and-slidy/)