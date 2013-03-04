---
layout: post
title: "Slidy and Scianimator"
date: 2013-03-04 11:22
comments: true
categories: slidy scianimator R knitr
---

In knitr, there is a hook for creating animation with javascript:

`hook_scianimator`

However, if you directly use it with `pandoc` and `slidy`, the animation
will not be correctly rendered. The reason is that the `.html` created by `pandoc`
will not include the source **scianimator** required.

Yesterday, I successfully intergrate **scianimator** into `slidy`.

## Environment

- Ubuntu 12.04 and ubuntu 12.10
- `pandoc` 1.10.0.4
- `R` 2.15.2
- `knitr` 1.0.5

## Hacks

- Download the zip file from [Scianimator](http://brentertz.github.com/scianimator/)
- Copy the subdirectory `assets` under your project.
- Copy the original template used by `pandoc`, `/<path to pandoc>/data/templates/default.slidy`, to
`slidy/slidy.scianimator`
- add the following line:

from:

```html origin
  ...
  <script src="$slidy-url$/scripts/slidy.js.gz"
    charset="utf-8" type="text/javascript"></script>
  ...
```

to:

```html origin
  ...
  <script src="$slidy-url$/scripts/slidy.js.gz"
    charset="utf-8" type="text/javascript"></script>
  <script src="assets/js/jquery-1.4.4.min.js"></script>
  <script src="assets/js/jquery.scianimator.pack.js"></script>
  <script src="assets/js/jquery.scianimator.js"></script>
  <script src="assets/js/index.js"></script>
  ...
```

- Use the following pandoc arguments:

```sh
pandoc -s -S -i -t slidy --template=slidy/slidy.scianimator --mathjax src.md -o target.html
```

That's it!
