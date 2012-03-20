---
layout: post
title: "symfony2-templates"
date: 2012-03-14 14:05
comments: true
categories: 
---

*	[Template](#template)
	*	[PHP Template](#template_php)
	*	[Twig](#template_twig)
	*	[Twig Template快取](#twig_cache)
*	[Template繼承和Layout](#template_inheritance)
*	[命名和位置](#naming)
*	[副檔名](#suffix)
*	[Tags和Helpers](#tags_helpers)
	*	[匯入其他的Template](#include)
	*	[嵌入Controller](#include_controller)
	*	[連結頁面](#link)
	*	[其他資源的連結](#asset)
*	[嵌入CSS和Javascript](#css_js)
*	[Template的全域變數](#global)
*	[設定和使用Templating服務](#config)
*	[客製化第三方Bundle Template](#bundle_template)
*	[三層繼承](#3-inheritance)
*	[跳脫輸出](#escaping)
*	[除錯](#debug)
*	[不同的Format](#diff_format)
*	[參考資料](#reference)


<h1 id="template">Template</h1>

<h2 id="template_php">PHP Template</h2>

Template是一個用於產生某種文字格示(HTML、XML、CSV、LaTeX...)的檔案。在Symfony1.4中主要是使用PHP template，例如:


	<!DOCTYPE html>
	<html>
	    <head>
	        <title>Welcome to Symfony!</title>
	    </head>
	    <body>
	        <h1><?php echo $page_title ?></h1>
	
	        <ul id="navigation">
	            <?php foreach ($navigation as $item): ?>
	                <li>
	                    <a href="<?php echo $item->getHref() ?>">
	                        <?php echo $item->getCaption() ?>
	                    </a>
	                </li>
	            <?php endforeach; ?>
	        </ul>
	    </body>
	</html>



Symfony2中還多了另一種選項:

<h2 id="template_twig">Twig</h2>

而Symfony2中額外引進Twig引擎來處理Template。同樣的寫法改成Twig後變成:


	<!DOCTYPE html>
	<html>
	    <head>
	        <title>Welcome to Symfony!</title>
	    </head>
	    <body>
	        <h1>{{ page_title }}</h1>
	
	        <ul id="navigation">
	            {% for item in navigation %}
	                <li><a href="{{ item.href }}">{{ item.caption }}</a></li>
	            {% endfor %}
	        </ul>
	    </body>
	</html>



以下簡略的介紹Twig。有興趣的開發者可以自行前往[Twig的官方網站](http://twig.sensiolabs.org/)。

*	`{{ ... }}`: 這符號代表「說」，功能是輸出一個變數或一段expressions的結果。
*	`{% ... %}`: 這符號代表「做」，通常是用於流程控制標籤，如for迴圈。
*	`{# ... #}`: 這是可跨行的註解。

Twig內建filter，例如:


	{{ title|upper }}



如此在輸出之前，Twig會過濾掉特殊符號。

這些是Twig內建的[tag](http://twig.sensiolabs.org/doc/tags/index.html)和[filter](http://twig.sensiolabs.org/doc/filters/index.html)。開發者也可以自行擴充。(請參考此[連結](http://twig.sensiolabs.org/doc/extensions.html))

Twig也支援function語法:


	{% for i in 0..10 %}
	    <div class="{{ cycle(['odd', 'even'], i) }}">
	      <!-- some HTML here -->
	    </div>
	{% endfor %}



Symfony的作者[Fabien Potencier](http://fabien.potencier.org/)捨棄既有的php template轉而開發Twig的理由是:

*	簡單
*	專門為Template設計的語法
*	完整的功能
	*	多重繼承
	*	段落
	*	自動的過濾跳脫字元
*	易學
*	擴充性
*	單元測試
*	文件
*	安全
*	乾淨的錯誤訊息
*	效能

詳細的解說請參閱[Twig的官方網站](http://twig.sensiolabs.org/)。

<h2 id="twig_cache">Twig Template快取</h2>

Twig template會被編譯為原生的php物件。這些物件會被放置於`app/cache/{environment}/twig`底下。

若環境是除錯模式，則twig會自動去更新生成的物件;反之，開發者就需要去清除快取的資料夾。

<h1 id="template_inheritance">Template繼承和Layout</h1>

除了在罕見的情況之外，template都會共用一些元素，如:

*	header
*	footer
*	sidebar

在Symfony2中，我們是從另一個觀點來看待Template:

_有些Template裝飾其他的Template_

這是一個 base layout file 的例子:


	{# app/Resources/views/base.html.twig #}
	<!DOCTYPE html>
	<html>
	    <head>
	        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	        <title>{% block title %}Test Application{% endblock %}</title>
	    </head>
	    <body>
	        <div id="sidebar">
	            {% block sidebar %}
	            <ul>
	                <li><a href="/">Home</a></li>
	                <li><a href="/blog">Blog</a></li>
	            </ul>
	            {% endblock %}
	        </div>
	
	        <div id="content">
	            {% block body %}{% endblock %}
	        </div>
	    </body>
	</html>



上述twig內有3個block:

*	title
*	sidebar
*	body

child template的例子為:


	{# src/Acme/BlogBundle/Resources/views/Blog/index.html.twig #}
	{% extends '::base.html.twig' %}
	
	{% block title %}My cool blog posts{% endblock %}
	
	{% block body %}
	    {% for entry in blog_entries %}
	        <h2>{{ entry.title }}</h2>
	        <p>{{ entry.body }}</p>
	    {% endfor %}
	{% endblock %}



如果去render child template，可能(結果和`blog_entries`有關)會得到以下的結果:


	<!DOCTYPE html>
	<html>
	    <head>
	        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	        <title>My cool blog posts</title>
	    </head>
	    <body>
	        <div id="sidebar">
	            <ul>
	                <li><a href="/">Home</a></li>
	                <li><a href="/blog">Blog</a></li>
	            </ul>
	        </div>
	
	        <div id="content">
	            <h2>My first post</h2>
	            <p>The body of the first post.</p>
	
	            <h2>Another post</h2>
	            <p>The body of the second post.</p>
	        </div>
	    </body>
	</html>



觀察上述的三個例子可以發現:

1.	`{% extends '::base.html.twig' %}` 是twig 繼承的關鍵字。
2.	在child中定義的`{% block title %}` 以及 `{% block body %}`取代了base template內的這兩個區塊。
3.	在child中未定義的`{% block sidebar %}`沿用base template的定義。

官方文件給的twig使用心法如下:

*	`{% extends ... %}`要是第一個tag。
*	在base template中用越多`{% block %}`越有彈性。
*	如果你自認為在複製template的內容，你可能可以:
	*	把相關的內容移到parent template的一個`{% block %}`
	*	開一個新的template並做[include]
*	如果需要使用parent template的內容，使用語法`{{ parent() }}`

<h1 id="naming">命名和位置</h1>

Template預設會出現在以下兩種地方:

*	`app/Resources/views` 這裡應該放的是整個專案用的base template。
*	`path/to/bundle/Resources/views/` 這裡放的是bundle內用的template。

Symfony2中使用_bundle:controller:template_的字串來表命名template檔案:

*	`AcmeBlogBundle:Blog:index.html.twig`表示一個在AcmeBlogBundle內的Blog controller物件的indexAction所引用的用於產生html文件的template。它的檔案位置可能(視Bundle位置而定)在`src/Acme/BlogBundle/Resources/views/Blog/index.html.twig`。
*	`AcmeBlogBundle::layout.html.twig`表示一個在AcmeBlogBundle內的template。因為缺少Controller物件，所以這個檔案可能位於`src/Acme/BlogBundle/Resources/views/layout.html.twig`。通常這是整個Bundle共用的部分。
*	`::base.html.twig`由於缺乏Bundle和Controller物件，這個檔案會位於`app/Resources/views/layout.html.twig`，這通常是整個專案所共用的部分。

這樣的命名準則和Controller的類似。

<h2 id="suffix">副檔名</h2>

*	`AcmeBlogBundle:Blog:index.html.twig`表示用twig語法產生HTML文件的template。
*	`AcmeBlogBundle:Blog:index.html.php`表示用PHP語法產生HTML文件的template。
*	`AcmeBlogBundle:Blog:index.css.twig`表示用twig語法產生CSS文件的template。

開發者也可以使用其他語法，請參考[設定Template](http://symfony.com/doc/current/book/templating.html#template-configuration)。

<h1 id="tags_helpers">Tags和Helpers</h1>

Symfony2中使用了一些特製化的tag:

<h2 id="include">匯入其他的Template</h2>

有時候開發者需要在一個template內匯入其他template的內容。例如要展示的最新的部落格文章。

直接看例子。

以下是一個準備要被重複使用的template:


	{# src/Acme/ArticleBundle/Resources/views/Article/articleDetails.html.twig #}
	<h2>{{ article.title }}</h2>
	<h3 class="byline">by {{ article.authorName }}</h3>
	
	<p>
	    {{ article.body }}
	</p>



以下式匯入它的例子:


	{# src/Acme/ArticleBundle/Resources/Article/list.html.twig #}
	{% extends 'AcmeArticleBundle::layout.html.twig' %}
	
	{% block body %}
	    <h1>Recent Articles<h1>
	
	    {% for article in articles %}
	        {% include 'AcmeArticleBundle:Article:articleDetails.html.twig' with {'article': article} %}
	    {% endfor %}
	{% endblock %}



說明:

*	Symfony2中可以使用`{% include ... with ... %}`語法來匯入其它的template。
*	`{'article': article}` 語法是twig中的array，等同PHP中的`array("article" => $article)`。如果要放多個元素，使用:`{'foo': foo, 'bar': bar}`。

<h2 id="include_controller">嵌入Controller</h2>

有時候要引入哪個template也牽涉到較為複雜的邏輯，這時候可以嵌入Controller來做。例如你要展示的不是固定一篇文章或是所有文章，而是是最新的文章。

一樣先看例子。以下是要被嵌入的Controller:


	<?php
	// src/Acme/ArticleBundle/Controller/ArticleController.php
	
	class ArticleController extends Controller
	{
	    public function recentArticlesAction($max = 3)
	    {
	        // make a database call or other logic to get the "$max" most recent articles
	        $articles = ...;
	
	        return $this->render('AcmeArticleBundle:Article:recentList.html.twig', array('articles' => $articles));
	    }
	}



Controller所呼叫的Template:


	{# src/Acme/ArticleBundle/Resources/views/Article/recentList.html.twig #}
	{% for article in articles %}
	    <a href="/article/{{ article.slug }}">
	        {{ article.title }}
	    </a>
	{% endfor %}



要嵌入Controller的Template:


	{# app/Resources/views/base.html.twig #}
	...
	<div id="sidebar">
	    {% render "AcmeArticleBundle:Article:recentArticles" with {'max': 3} %}
	</div>



這個例子較為複雜，解說如下:

1.	`base.html.twig`先呼叫`ArticleController.php`並同時傳遞一個參數`max = 3`。
2.	`ArticleController.php`整理`$articles`變數(可能是找出最新的`max`篇)後呼叫`recentList.html.twig`產生對應的HTML。
3.	`recentList.html.twig`產生的HTML最後會被放到`base.html.twig`中`<div id="sidebar">`內。

<h2 id="link">連結頁面</h2>

產生連結可以使用twig function: `path`。

沒有參數的例子:

如果有一個routing.yml:


	_welcome:
	    pattern:  /
	    defaults: { _controller: AcmeDemoBundle:Welcome:index }



要連結到這個頁面，可以使用:


	<a href="{{ path('_welcome') }}">Home</a>



有參數的例子:


	article_show:
	    pattern:  /article/{slug}
	    defaults: { _controller: AcmeArticleBundle:Article:show }



連結:


	{# src/Acme/ArticleBundle/Resources/views/Article/recentList.html.twig #}
	{% for article in articles %}
	    <a href="{{ path('article_show', { 'slug': article.slug }) }}">
	        {{ article.title }}
	    </a>
	{% endfor %}



所以可以歸納出:

語法: `{{ path( route名稱, 參數陣列 ) }}`

同時也可以使用另一個twig function: `url`。用法一樣，但是回傳的是絕對路徑，而非`path`回傳的相對路徑。

<h2 id="asset">其他資源的連結</h2>

使用twig function:`asset`可以產生連結到圖片、CSS或javascript等外部資源。


	<img src="{{ asset('images/logo.png') }}" alt="Symfony!" />
	
	<link href="{{ asset('css/blog.css') }}" rel="stylesheet" type="text/css" />



使用的好處有:

1.	讓整個專案的移動更方便
2.	防止瀏覽器快取

<h1 id="css_js">嵌入CSS和Javascript</h1>

看起來簡單的例子:


	{# 'app/Resources/views/base.html.twig' #}
	<html>
	    <head>
	        {# ... #}
	
	        {% block stylesheets %}
	            <link href="{{ asset('/css/main.css') }}" type="text/css" rel="stylesheet" />
	        {% endblock %}
	    </head>
	    <body>
	        {# ... #}
	
	        {% block javascripts %}
	            <script src="{{ asset('/js/main.js') }}" type="text/javascript"></script>
	        {% endblock %}
	    </body>
	</html>



但是如果child template還要新增額外的CSS或javascript呢?

可以使用:


	{# src/Acme/DemoBundle/Resources/views/Contact/contact.html.twig #}
	{% extends '::base.html.twig' %}
	
	{% block stylesheets %}
	    {{ parent() }}
	
	    <link href="{{ asset('/css/contact.css') }}" type="text/css" rel="stylesheet" />
	{% endblock %}
	
	{# ... #}



嵌入Bundle內的`Resources/public`的assets也可以，記得要使用

	php app/console assets:install target [--symlink]


來把Bundle內部的assets資源放到對的資料夾(預設是`web`)

<h1 id="global">Template的全域變數</h1>

如果在Template內想要使用和整個專案設定相關的變數，可以直接使用:

*	app.security 安全相關設定
*	app.user 目前的使用者物件
*	app.request	目前的request物件
*	app.session	目前的session物件
*	app.environment	目前的環境(prod或dev)
*	app.debug 是否有開啟debug(boolean)

例子:


	<p>Username: {{ app.user.username }}</p>
	{% if app.debug %}
	    <p>Request method: {{ app.request.method }}</p>
	    <p>Application Environment: {{ app.environment }}</p>
	{% endif %}



自訂全域變數請參考[全域變數](http://symfony.com/doc/current/cookbook/templating/global_variables.html)

<h1 id="config">設定和使用Templating服務</h1>

Symfony2中的Template底層核心是這些分析templte的引擎。它們負責把開發者寫的twig語法最終轉換成目標HTML或其他格式的文件。只要是使用template，事實上就是在呼叫這些引擎服務。

例如


	<?php
	return $this->render('AcmeArticleBundle:Article:index.html.twig');



其實就是


	<?php
	$engine = $this->container->get('templating');
	$content = $engine->render('AcmeArticleBundle:Article:index.html.twig');
	
	return $response = new Response($content);



Symfony2中預設自動使用這些引擎，而這當然是可以更改的:


	# app/config/config.yml
	framework:
	    # ...
	    templating: { engines: ['twig'] }



要更改設定的話，請閱讀[Configuration Appendix](http://symfony.com/doc/current/reference/configuration/framework.html)

<h1 id="bundle_template">客製化第三方Bundle Template</h1>

Symfony2社群已經有許多Bundle供開發者取用。([knpbundles.com](http://knpbundles.com/))。有時候開發者在使用時會想要替換這些Bundle所使用著Template。

假設開發者想要改寫部落格中的`list`頁面:


	<?php
	public function indexAction()
	{
	    $blogs = // some logic to retrieve the blogs
	
	    $this->render('AcmeBlogBundle:Blog:index.html.twig', array('blogs' => $blogs));
	}



Symfony2在看到`AcmeBlogBundle:Blog:index.html.twig`後會依序搜尋:

1.	`app/Resources/AcmeBlogBundle/views/Blog/index.html.twig`
2.	`src/Acme/BlogBundle/Resources/views/Blog/index.html.twig`

要Override這些Bundle Template，只要把`src/`內的twig檔案複製到`app/`內的對應位置(當然要自己創造資料夾)後修改即可。

如果要修改Bundle Layout則是同樣的邏輯:

1.	`app/Resources/AcmeBlogBundle/views/layout.html.twig`
2.	`src/Acme/BlogBundle/Resources/views/layout.html.twig`

<h2>Core Template</h2>

Symfony2本身也是一個Bundle，所以所有Symfony2預設的Template都可以被override。

例如把TwigBundle中的`Resources/views/Exception`頁面複製到`app/Resources/TwigBundle/views/Exception`。

<h1 id="3-inheritance">三層繼承</h1>

1.	整個專案共用的部分: `app/Resources/views/base.html.twig`
2.	Bundle內共用的部分: `src/Acme/BlogBundle/Resources/views/layout.html.twig`繼承1.
3.	其他: `src/Acme/BlogBundle/Resources/views/Blog/index.html.twig`繼承2.

<h1 id="escaping">跳脫輸出</h1>

要避免輸出特殊字元在twig非常簡單。除非開發者額外使用`raw` filter，否則twig自動會將諸如`<script>`改成`&lt;script&gt;`以避免被注入奇怪的程式碼而造成安全性問題。

<h1 id="debug">除錯</h1>

只用在`config`中打開除錯服務:


	# app/config/config.yml
	services:
	    acme_hello.twig.extension.debug:
	        class:        Twig_Extension_Debug
	        tags:
	             - { name: 'twig.extension' }



則Twig中的變數就會被倒出來。

<h1 id="diff_format">不同的Format</h1>

Controller:


	<?php
	public function indexAction()
	{
	    $format = $this->getRequest()->getRequestFormat();
	
	    return $this->render('AcmeBlogBundle:Blog:index.'.$format.'.twig');
	}



link:


	<a href="{{ path('article_show', {'id': 123, '_format': 'pdf'}) }}">
	    PDF Version
	</a>



<h1 id="reference">參考資料</h1>

*	本篇文章大部分來自官方文件[Creating and using Templates](http://symfony.com/doc/current/book/templating.html)