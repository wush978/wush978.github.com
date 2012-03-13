---
layout: post
title: "Symfony2-Controller"
date: 2012-03-13 10:30
comments: true
categories: 
---

<h1>簡介</h1>

Controller就是處理接收到的request中的information後，找出適當的response並回傳給client。

在Symfony2中，response可以是:

*	HTTP頁面
*	XML文件
*	JSON陣列

例如:

``` php Hello World
<?php
use Symfony\Component\HttpFoundation\Response;

public function helloAction()
{
    return new Response('Hello world!');
}
```

<h1>Request、Controller和Response的處理程序</h1>

以下是每一個到Symfony2專案的request的處理程序:

*	來自Client的Request是先由front controller來處理(例如: `app.php`或是`app_dev.php)
*	Router從request中擷取資訊，找到能處理的Controller
*	執行Controller並回傳Response物件
*	回傳Response物件到Client

```
Front Controller指的是在web/資料夾內的app.php和app_dev.php。開發者可以不去關心這些檔案。
```

<h1>一些簡單的範例</h1>

Controller事實上可以是所有的PHP callable，但是在Symfony2中通常是一個controller物件中的方法。Controller也叫做_actions_。

``` php src/Acme/HelloBundle/Controller/HelloController.php
<?php
namespace Acme\HelloBundle\Controller;
use Symfony\Component\HttpFoundation\Response;

class HelloController
{
    public function indexAction($name)
    {
      return new Response('<html><body>Hello '.$name.'!</body></html>');
    }
}
```

簡介中提到的Controller即是在`HelloController`內的`indexAction`方法。
`HelloController`則是一個Controller物件。一個Controller物件可能包含數個Controller。

*	第2行，我們將這個Controller物件宣告於`Acme\HelloBundle\Controller`這個namespace底下。
*	第3行，我們使用了位於namespace:`Symfony\Component\HttpFoundation\Response`的Response物件
*	第5行，這是慣用的命名規則。
*	第7行, 這也是慣用的命名規則；`$name`則是從routing.yml中的`{name}`來的。
*	第9行，這個Controller建立並回傳一個Response物件。

<h1>建立URL到Controller的對應</h1>

<h2>簡介</h2>

若要瀏覽剛剛建立的Controller，我們必須建立對應的routing.yml

``` yaml app/config/routing.yml
hello:
    pattern:      /hello/{name}
    defaults:     { _controller: AcmeHelloBundle:Hello:index }
```

這個routing rule的名稱就叫做`hello`，當url符合`/hello/{name}`的pattern的時候Symfony2就會將request去找對應的Controller。

如果使用者的Url給的是`/hello/Ryan`(完整的Url可能是`http://<server name>/app.php/hello/Ryan`)，那Symfony2會認為該Url符合這個routing，並同時把Ryan代入至`{name}`變數。

接下來Symfony2就會去找位於`Acme/HelloBundle`這個Bundle內叫做`Hello`的Controller物件，並且調用裡面的`indexAction`方法。

關於命名規則可以參考[Controller命名規則](http://symfony.com/doc/current/book/routing.html#controller-string-syntax)

這個範例將routing放置於global的routing.yml`app/config/routing.yml`，這並不是一個好的做法。較好的做法是把設定檔放到Bundle內部的routing.yml，並且在global的routing.yml中匯入Bundle內部的routing.yml。

關於更詳細的Routing資訊請參考[Routing](http://symfony.com/doc/current/book/routing.html)

<h2>傳遞參數</h2>

仔細看
``` php src/Acme/HelloBundle/Controller/HelloController.php
<?php
namespace Acme\HelloBundle\Controller;
use Symfony\Component\HttpFoundation\Response;

class HelloController
{
    public function indexAction($name)
    {
      return new Response('<html><body>Hello '.$name.'!</body></html>');
    }
}
```

`indexAction`這個方法有一個參數`$name`，這個和routing中的`/hello/{name}`有關係。事實上，Symfony2會自動在pattern比對的時候也存入對應的參數。

例如:

``` yaml app/config/routing.yml
hello:
    pattern:      /hello/{first_name}/{last_name}
    defaults: 
      _controller: AcmeHelloBundle:Hello:index
      color: green
```

上述的routing就會在對應/hello/Ryan/Wang的Url到以下的Action的同時填入變數`$first_name = "Ryan"`、`$last_name = "Wang"`和`$color = "green"`:

``` php
<?php
public function indexAction($first_name, $last_name, $color)
{
	// ...
}
```

使用時請注意以下的規則:
*	順序不重要

``` php
<?php
public function indexAction($first_name, $color, $last_name)
{
	// ...
}
```

這樣不會有問題

*	Controller「接」的參數不可以多於Routing「丟」的參數

``` php 會丟出RuntimeException
<?php
public function indexAction($first_name, $last_name, $color, $foo)
{
	// ...
}
```

``` php 使用預設值就沒有問題
public function indexAction($first_name, $last_name, $color, $foo = "bar")
{
	// ...
}
```

*	Controller「接」的參數可以少於Routing「丟」的參數
``` php 不接參數也沒問題
public function indexAction($first_name, $last_name)
{
	// ...
}
```

事實上每個Routing還會丟一個`$_route`參數代表該Routing的名稱。

<h2>用Request當參數</h2>

事實上，Controller也可以直接把整個Request物件當成參數。(我在Symfony 1.4都是這樣用的)

``` php 
<?php
use Symfony\Component\HttpFoundation\Request;

public function updateAction(Request $request)
{
    $form = $this->createForm(...);

    $form->bindRequest($request);
    // ...
}
```

<h1>base Controller物件</h1>

Symfony2已經先定義一個基礎物件公開發者繼承使用。

請見範例:

``` php src/Acme/HelloBundle/Controller/HelloController.php
<?php
namespace Acme\HelloBundle\Controller;
use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Symfony\Component\HttpFoundation\Response;

class HelloController extends Controller
{
    public function indexAction($name)
    {
      return new Response('<html><body>Hello '.$name.'!</body></html>');
    }
}
```

<h1>參考網頁</h1>

*	[Symfony2 Book Controller](http://symfony.com/doc/current/book/controller.html)