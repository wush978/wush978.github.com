---
layout: post
title: "texlipse tips with R Sweave"
date: 2012-12-29 09:29
comments: true
categories: latex texlipse
---

## Build Dependency

- Create an external program to build R Sweave
- touch the main tex or texlipse won't update the modified content.
```sh
touch document.tex
```

## IEEE submission

```sh
dvipdf -dPDFSETTINGS=/prepress -dSubsetFonts=true -dEmbedAllFonts=true -dMaxSubsetPct=100 -dCompatibilityLevel=1.4
```
