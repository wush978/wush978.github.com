---
layout: post
title: "Symfony2-Controller"
date: 2012-03-13 10:30
comments: true
categories: 
---

*	[簡介](#introduction)
*	[Request、Controller和Response的處理程序](#life_cycle)
*	[一些簡單的範例](#simple_example)
*	[建立URL到Controller的對應](#url_to_controller)
	*	[簡介](#url_to_controller_introduction)
	*	[傳遞參數](#url_to_controller_pass_arguments)
	*	[用Request當參數](#url_to_controller_request)
*	[base Controller物件](#base_controller)
	*	[Controller常用的功能](#base_controller_feature)
		*	[Redirecting](#base_controller_feature_redirecting)
		*	[Forwarding](#base_controller_feature_forwarding)
		*	[使用Template](#base_controller_feature_template)
		*	[存取其他服務](#base_controller_feature_other_service)
		*	[處理錯誤和404](#base_controller_feature_error_404)
		*	[Session管理](#base_controller_feature_session)
		*	[提示訊息](#base_controller_feature_flash)
	*	[Response物件](#base_controller_response_obj)
	*	[Request物件](#base_controller_request_obj)
*	[結尾](#final)
*	[參考網頁](#reference)

<h1 id="introduction">簡介</h1>

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

<h1 id="life_cycle">Request、Controller和Response的處理程序</h1>

以下是每一個到Symfony2專案的request的處理程序:

*	來自Client的Request是先由front controller來處理(例如: `app.php`或是`app_dev.php`)
*	Router從request中擷取資訊，找到能處理的Controller
*	執行Controller並回傳Response物件
*	回傳Response物件到Client

Front Controller指的是在web/資料夾內的app.php和app_dev.php。開發者可以不去關心這些檔案。

<h1 id="simple_example">一些簡單的範例</h1>

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

<h1 id="url_to_controller">建立URL到Controller的對應</h1>

<h2 id="url_to_controller_introduction>簡介</h2>

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

<h2 id="url_to_controller_pass_arguments">傳遞參數</h2>

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
<?php
public function indexAction($first_name, $last_name, $color, $foo = "bar")
{
	// ...
}
```

*	Controller「接」的參數可以少於Routing「丟」的參數
``` php 不接參數也沒問題
<?php
public function indexAction($first_name, $last_name)
{
	// ...
}
```

事實上每個Routing還會丟一個`$_route`參數代表該Routing的名稱。

<h2 id="url_to_controller_request">用Request當參數</h2>

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

<h1 id="base_controller">base Controller物件</h1>

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

該基礎物件包含了許多有用的helpers。最快學習使用這個物件的方法是看它的source code。

開發者可以自行決定是否要擴充Controller物件，甚至是定義自己的[Controller服務](http://symfony.com/doc/current/cookbook/controller/service.html)

<h2 id="base_controller_feature">Controller常用的功能</h2>

<h3 id="base_controller_feature_redirecting">Redirecting</h3>

如果需要將使用者redirect至其它的網頁，可直接使用`redirect()`方法。

``` php
<?php
public function indexAction()
{
    return $this->redirect($this->generateUrl('homepage'));
}
```

另一個相關的helper function是`generateUrl()`，給它一個route，它會回傳對應的Url。詳情請見[Routing](http://symfony.com/doc/current/book/routing.html)。

如果要修改相關的HTTP header，(例如要使用301，而非預設的302)那可以加上第二個參數:

``` php
<?php
public function indexAction()
{
    return $this->redirect($this->generateUrl('homepage'), 301);
}
```

事實上使用`redirect()`和以下的使用RedirectResponse物件是一樣的:

``` php
<?php
use Symfony\Component\HttpFoundation\RedirectResponse;

return new RedirectResponse($this->generateUrl('homepage'));
```

<h3 id="base_controller_feature_forwarding">Forwarding</h3>

你也可以使用`forward()`在內部偷偷的將Request丟給另一個controller，在這種狀況下使用者的瀏覽器並不知道。

`forward()`會回傳被丟的controller回傳的Response物件，所以我們需要再把它丟回給client。

``` php 
<?php
public function indexAction($name)
{
    $response = $this->forward('AcmeHelloBundle:Hello:fancy', array(
        'name'  => $name,
        'color' => 'green'
    ));

    // further modify the response or return it directly

    return $response;
}
```

請注意forward方法的參數:

*	第一個參數是被丟的Controller的名字。請參考[Controller命名規則](http://symfony.com/doc/current/book/routing.html#controller-string-syntax)
*	第二個參數是一個array，包含要丟給該controller的參數，這部分類似[傳遞參數](#pass_arguments)。類似的參數傳遞方式也可以在[嵌入Template的Controller](http://symfony.com/doc/current/book/templating.html#templating-embedding-controller)中看到。

被丟的Controller可能長這樣:

``` php
<?php
public function fancyAction($name, $color)
{
    // ... create and return a Response object
}
```

其他的注意事項都類似[傳遞參數](#pass_arguments)內提到的要點。

事實上`forward()`和`http_kernel`服務有關。以下是實際上`forward()`所回傳的Response物件:

``` php
<?php
$httpKernel = $this->container->get('http_kernel');
$response = $httpKernel->forward('AcmeHelloBundle:Hello:fancy', array(
    'name'  => $name,
    'color' => 'green',
));
```

<h3 id="base_controller_feature_template">使用Template</h3>

大部分的Controller會把產生HTML或其他文件格式的任務交付給一個或數個Template。`renderView()`方法會將任務移交給一個指定的Template，並且回傳產生後的內容。這個內容可以用來產生Response物件:

``` php
<?php
$content = $this->renderView('AcmeHelloBundle:Hello:index.html.twig', array('name' => $name));

return new Response($content);
```

或者也可以使用`render()`方法直接把Template的內容放到Response物件內:

``` php
<?php
return $this->render('AcmeHelloBundle:Hello:index.html.twig', array('name' => $name))
```

上面的例子均引用AcmeHelloBundle來產生`Resources/views/Hello/index.html.twig`。Template具體細節請參閱[Template](http://symfony.com/doc/current/book/templating.html)。

事實上這些方法是使用templating service:

``` php
<?php
$templating = $this->get('templating');
$content = $templating->render('AcmeHelloBundle:Hello:index.html.twig', array('name' => $name));
```

<h3 id="base_controller_feature_other_service">存取其他服務</h3>

開發者也可以透過下列定義於base Controller物件的`get()`方法存取其它的資源:

``` php
<?php
$request = $this->getRequest();

$templating = $this->get('templating');

$router = $this->get('router');

$mailer = $this->get('mailer');
```

既有的服務有很多，開發者甚至可以自己定義自己的服務。如果要列出所有的服務，可以使用以下指令:

``` sh
php app/console container:debug
```

關於服務請讀[Service Container](http://symfony.com/doc/current/book/service_container.html)。

<h3 id="base_controller_feature_error_404">處理錯誤和404</h3>

當Url無法被解析或是存取的資源不存在，伺服器應該回傳HTTP 404給Client。在Symfony2中，開發者可以透過丟出一個特定的Exception物件來達到目的，或是使用`createNotFoundException()`方法。

``` php
<?php
public function indexAction()
{
    $product = // retrieve the object from database
    if (!$product) {
        throw $this->createNotFoundException('The product does not exist');
    }

    return $this->render(...);
}
```

該方法會丟出NotFoundHttpException物件。其他的Exception物件會導致HTTP 500錯誤。

通常Symfony2會傳一個錯誤頁面給使用者，或是傳詳細的debug資訊給開發者。想要客製化錯誤頁面，請參考Cook Book內的[客製化錯誤頁面](http://symfony.com/doc/current/cookbook/controller/error_pages.html) 。



<h3 id="base_controller_feature_session">Session管理</h3>

Symfony2中使用一個物件來管理Session。底層的實作預設是使用PHP原生Sessions。

存取Session可以透過:

``` php
<?php
$session = $this->getRequest()->getSession();

// store an attribute for reuse during a later user request
$session->set('foo', 'bar');

// in another controller for another request
$foo = $session->get('foo');

// set the user locale
$session->setLocale('fr');
```

<h3 id="base_controller_feature_flash">提示訊息</h3>

開發者可以儲存一次性的提示訊息到使用者的Session內:

``` php
<?php
public function updateAction()
{
    $form = $this->createForm(...);

    $form->bindRequest($this->getRequest());
    if ($form->isValid()) {
        // do some sort of processing

        $this->get('session')->setFlash('notice', 'Your changes were saved!');

        return $this->redirect($this->generateUrl(...));
    }

    return $this->render(...);
}
```

第10行的程式碼儲存了一個等級為`notice`的訊息到使用者的session中。

當執行到以下為例的Template時:

``` css+django
{% if app.session.hasFlash('notice') %}
    <div class="flash-notice">
        {{ app.session.flash('notice') }}
    </div>
{% endif %}
```

使用者就會看到該訊息，而該訊息也將消失(一次性)。

<h2 id="base_controller_response_obj">Response物件</h2>

Controller必須遵循的條件之一，就是要回傳Response物件。Response物件是代表一個帶著HTTP header的純文字訊息，並且將被送回至Client端:

``` php
<?php
// create a simple Response with a 200 status code (the default)
$response = new Response('Hello '.$name, 200);

// create a JSON-response with a 200 status code
$response = new Response(json_encode(array('name' => $name)));
$response->headers->set('Content-Type', 'application/json');
```

Symfony2中，http header的屬性是透過HeaderBag物件來控制。

<h2 id="base_controller_request_obj">Request物件</h2>

Controller可以透過base Controller物件的方法來存取Request物件:

``` php
<?php
$request = $this->getRequest();

$request->isXmlHttpRequest(); // is it an Ajax request?

$request->getPreferredLanguage(array('en', 'fr'));

$request->query->get('page'); // get a $_GET parameter

$request->request->get('page'); // get a $_POST parameter
```

http header的屬性也是可透過HeaderBag物件來存取。

<h1 id="final">結尾</h1>

Controller包含的邏輯是「接到Request並回傳Response」。

接下來開發者還可以學到如何在Controller中使用database、處理form或是Cache...等等更多技術。

<h1 id="reference">參考網頁</h1>

*	[Symfony2 Book Controller](http://symfony.com/doc/current/book/controller.html)