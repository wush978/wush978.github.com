---
layout: post
title: "Symfony2-Create-New-Page"
date: 2012-03-13 10:30
comments: true
categories: 
---

<h1>建立Bundle</h1>

<h2>簡介</h2>
Symfony2中的Bundle就像是一個package。所有的頁面都必須被放到某個Bundle中。所以在開始之前我們需要先建立一個Bundle。

``` sh Create Bundle
php app/console generate:bundle --namespace=Acme/HelloBundle --format=yml
```

<h2>啟用Bundle</h2>
要使用Bundle之前，必須要在`app/AppKernel.php`中註冊：

``` php5 app/AppKernel.php
<?php
public function registerBundles()
{
  $bundles = array(
    // ...
    new Acme\HelloBundle\AcmeHelloBundle(),
  );
  // ...
  return $bundles;
}
```

<h1>建立Routing</h1>

<h2>簡介</h2>
當Symfony2收到Url Request的時候，會根據Url去分析對應到的Controller，這個動作就是Routing
。在建立頁面的時候，我們需要先建立開啟該頁面的Routing。

Symfony2中的Routing被切割成兩塊:
*	`app/config/routing.yml`內的是供整個Symfony2專案使用的Routing，在此稱為Global Routing
*	`src/Acme/HelloBundle/Resources/config/routing.yml`內的routing.yml是該Bundle自己使用的Routing，在此稱為Local Routing

<h2>檢查global routing.yml</h2>
檢查`app/config/routing.yml`是否有include剛剛創建的Bundle的routing.yml
``` yml app/config/routing.yml
AcmeHelloBundle:
	resource: "@AcmeHelloBundle/Resources/config/routing.yml"
	prefix: /
```
*	resource: 代表被include的routing.yml的位置
*	prefix: 代表所有該routing.yml中的pattern前還額外需要符合的pattern

<h2>檢查local routing.yml</h2>
在Bundle中的routing.yml建立開啟新頁面的規則。

``` yml src/Acme/HelloBundle/Resources/config/routing.yml
hello:
    pattern:  /hello/{name}
    defaults: { _controller: AcmeHelloBundle:Hello:index }
```

*	pattern: 代表需要符合的url pattern。不符合的話Symfony會繼續往下找
*	defaults: 執行的controller

<h1>建立Controller</h1>

<h2>簡介</h2>
當`/hello/Ryan`已經被Symfony2分析後，依照上述的Routing，這個Request會由`AcmeHelloBundle:Hello:index`來負責處理。

要建立頁面的下一個步驟就是要建立這個Controller。

<h2>Controller的命名</h2>

<h1>建立Template</h1>