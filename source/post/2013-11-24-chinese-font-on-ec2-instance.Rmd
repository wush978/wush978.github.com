---
layout: post
title: "Chinese Font on EC2 Instance"
date: 2013-11-24 13:59
comments: true
categories: R, font
---

# Resolve Chinese font issue on AWS EC2

Record the step I used to resolve the font issue on AWS EC2

# Download chinese ttf font

- Download `.ttf` chinese font. For example, [DFLiYuanXBold1B](http://www.fontsaddict.com/font/dfliyuanxbold1b.html). Remember to rename the file extension from `TTF` to `ttf`

# Install R package `extrafont`

```r
install.packages('extrafont')
```

# Import ttf font

```r
library(extrafont)
font_import("<path to DFLIYX1B.ttf>")
```

# Summary

I didn't try it second times. Please let me know if it works or not.

