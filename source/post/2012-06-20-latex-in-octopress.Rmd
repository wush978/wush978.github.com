---
layout: post
title: "Latex in Octopress"
date: 2012-06-20 13:01
comments: true
categories: Latex Octopress
---

大致上參考[在Octopress中使用Latex](http://chen.yanping.me/cn/blog/2012/03/10/octopress-with-latex/)即可。

# 安裝

1. 安裝kramdown
``` sh install-kramdown
gem install kramdown
```
2. 修改`/source/_includes/custom/head.html`
``` html head.html
<!-- mathjax config similar to math.stackexchange -->

<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [ ['$','$'], ["\\(","\\)"] ],
      processEscapes: true
    }
  });
</script>

<script type="text/x-mathjax-config">
    MathJax.Hub.Config({
      tex2jax: {
        skipTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'code']
      }
    });
</script>

<script type="text/x-mathjax-config">
    MathJax.Hub.Queue(function() {
        var all = MathJax.Hub.getAllJax(), i;
        for(i=0; i < all.length; i += 1) {
            all[i].SourceElement().parentNode.className += ' has-jax';
        }
    });
</script>

<script type="text/javascript"
   src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML">
</script>
```

# 使用注意事項

1. 這個是我自己測出來的bug: _在latex中的符號 ` ^ ` 之後要接空格才能正常使用_。
