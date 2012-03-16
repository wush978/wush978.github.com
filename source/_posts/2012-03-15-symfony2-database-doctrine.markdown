---
layout: post
title: "symfony2-database-doctrine"
date: 2012-03-15 15:48
comments: true
categories: 
---

*	[簡介](#introduction)
*	[請你跟我這樣做](#simple_example)
	*	[設定資料庫](#simple_example_configure_db)
	*	[建立Entity物件](#simple_example_entity)
	*	[產生Getter/Setter](#simple_example_getter_setter)
	*	[資料庫Schema](#simple_example_database_schema)
	*	[在資料庫內保存物件](#simple_example_save)
	*	[自資料庫匯出資料](#simple_example_load)
	*	[更新物件](#simple_example_update)
	*	[刪除物件](#simple_example_delete)
	*	[查詢物件](#simple_example_query)
		*	[用DQO做查詢](#simple_example_query_DQL)
		*	[Doctrine Query Builder](#simple_example_query_doctrine_query_builder)
	*	[客製化Repository物件](#simple_example_custom_repository)
*	[Entity間的關聯](#entity_relationship)
	*	[建立Entity間的關聯](#entity_relationship_mapping)
	*	[儲存關聯Entity](#entity_relationship_save)
	*	[讀取關聯Entity](#entity_relationship_load)
	*	[合併關聯Entity](#entity_relationship_join)
	*	[其他關聯](#entity_relationship_more)
*	[設定](#configuration)
*	[Lifecycle Callbacks](#lifecycle_callback)
*	[擴充Doctrine](#doctrine_extension)
*	[索引:Doctrine欄位型態](#doctrine_field_type_reference)
*	[參考網頁](#reference)


<h1 id="introduction">簡介</h1>

Symfony2預設處理資料庫的套件庫是Doctrine。就我所知，Propel目前也可以在Symfony2上使用，詳情請參考[Propel官網](http://www.propelorm.org/cookbook/symfony2/working-with-symfony2.html)。

之前我在Symfony1.4時有測過Propel至少可以使用MySQL, PostgreSQL, MSSQL和Oracle。所以根據現在的狀況來看，我認為Symfony2也至少可以支援這些資料庫。

至於近期很夯的MongoDB也可以在[DoctrineMongoDBBundle](http://symfony.com/doc/current/bundles/DoctrineMongoDBBundle/index.html)內找到說明。

<h1 id="simple_example">請你跟我這樣做</h1>

官網在此是使用實例來講解，所以大家就開個Symfony專案、架好database後跟著照做吧。

首先先開個Bundle:

``` sh
php app/console generate:bundle --namespace=Acme/StoreBundle
```

<h2 id="simple_example_configure_db">設定資料庫</h2>

如果已經建立好web介面，可以直接打開`http://<ip>/app_dev.php`後點選CONFIGURE做設定;或是於`app/config/parameters.ini`內設定資料庫的連線設定:

``` ini 設定範例
;app/config/parameters.ini
[parameters]
    database_driver   = pdo_mysql
    database_host     = localhost
    database_name     = test_project
    database_user     = root
    database_password = password
```

Doctrine預設是參照parameters.ini，當然也可以設定成參照其他地方的設定。詳情請看[如何參考外部設定](http://symfony.com/doc/current/cookbook/configuration/external_parameters.html)

上述設定的資料庫帳號必須是擁有能建立資料庫的權限，接著就能使用Doctrine來建立資料庫:

``` sh
php app/console doctrine:database:create
```

為了練習，就開一個練習用的Bundle吧:

``` sh
php app/console generate:bundle --namespace=Acme/StoreBundle
```

<h2 id="simple_example_entity">建立Entity物件</h2>

Entity的意思是代表一種控制資料的基礎物件。

假設你需要一個Product物件來代表產品。在`src/Acme/StoreBundle`底下開一個`Entity`資料夾並建立`Product.php`:

``` php src/Acme/StoreBundle/Entity/Product.php
<?php
// src/Acme/StoreBundle/Entity/Product.php
namespace Acme\StoreBundle\Entity;

class Product
{
    protected $name;

    protected $price;

    protected $description;
}
```

這目前只是一個單純的PHP物件 --- 無法將資料永久的保存於資料庫中。

你也可以讓Doctrine幫你產生這樣的物件。

``` sh 
php app/console doctrine:generate:entity --entity="AcmeStoreBundle:Product" --fields="name:string(255) price:float description:text"
```

Doctrine是一個ORM。ORM是一種保持PHP物件和資料庫欄位互相對應的套件庫。目前已知能和Symfony2整合的ORM有Doctrine和Propel兩種。

Doctrine接受設定對應關係的格式有:

*	YAML
*	XML
*	註解(annotation)

但是一個Bundle內只能使用一種。

用Doctrine產生出來的Product物件應該長得像:

``` php src/Acme/StoreBundle/Entity/Product.php
<?php
// src/Acme/StoreBundle/Entity/Product.php
namespace Acme\StoreBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity
 * @ORM\Table(name="product")
 */
class Product
{
    /**
     * @ORM\Id
     * @ORM\Column(type="integer")
     * @ORM\GeneratedValue(strategy="AUTO")
     */
    protected $id;

    /**
     * @ORM\Column(type="string", length=100)
     */
    protected $name;

    /**
     * @ORM\Column(type="decimal", scale=2)
     */
    protected $price;

    /**
     * @ORM\Column(type="text")
     */
    protected $description;
}
```

*	Table名稱可以省略，預設是物件名稱。
*	Doctrine可以設定多種欄位以及相關設定，詳情請看[索引:Doctrine欄位型態](#doctrine_field_type_reference)
*	開發者也可以參考Doctrine官網的[基礎對應文件](http://docs.doctrine-project.org/projects/doctrine-orm/en/2.1/reference/basic-mapping.html)，但是在Symfony2中要額外做:
	*	如果用註解格示，記得要在每個註解前加上`ORM\`，例如:`ORM\Column(...)`。
	*	需要加上`use Doctrine\ORM\Mapping as ORM;`
*	小心避開SQL的關鍵字。可參考Doctrine文件[SQL保留字](http://docs.doctrine-project.org/projects/doctrine-orm/en/2.1/reference/basic-mapping.html#quoting-reserved-words)
*	如果同時使用多種會解析註解的套件庫(例如Doxygen)，那需要在物件的註解裡加註`@IgnoreAnnotation`，例如在防止`@fn`丟出Exception的時候，可以:

		/**
		 * @IgnoreAnnotation("fn")
		 */
		class Product

<h2 id="simple_example_getter_setter">產生Getter/Setter</h2>

Doctrine也會幫開發者產生物件欄位的getter/setter:

``` sh
php app/console doctrine:generate:entities Acme/StoreBundle/Entity/Product
```

*	這個指令會產生getter/setter給該物件
*	只會產生不存在的getter/setter，不會動到已經存在的class
*	可以產生repository物件設定，如`@ORM\Entity(repositoryClass="...")`
*	產生適當的建構子
*	不需要依賴這個指令

<h2 id="simple_example_database_schema">資料庫Schema</h2>

在建立好資料庫和物件之間的對應後，我們需要在真正的資料庫內建立對應的Table以及欄位。

``` sh
php app/console doctrine:schema:update --force
```

之後只要有對物件和資料庫間的關係做更動時，執行這個指令就可以更新資料庫內的Table。

更好的更新方式是使用[Migration Bundle](http://symfony.com/doc/current/bundles/DoctrineMigrationsBundle/index.html)。

現在你的物件透過Doctrine擁有資料庫的支援了。

<h2 id="simple_example_save">在資料庫內保存物件</h2>

現在我們可以建立一個Controller來儲存Product物件:

``` php create Product
<?php
// src/Acme/StoreBundle/Controller/DefaultController.php
use Acme\StoreBundle\Entity\Product;
use Symfony\Component\HttpFoundation\Response;
// ...
    /**
     * @Route("/product")
     */
    public function createAction()
    {
        $product = new Product();
        $product->setName("A Foo Bar");
        $product->setPrice('19.99');
        $product->setDescription("Lorem ipsum dolor");
        
        $em = $this->getDoctrine()->getEntityManager();
        $em->persist($product);
        $em->flush();
        
        return new Response("Create product id " . $product->getId());
    }
// ...
```

馬上試試看: 打開`http://<ip>/app_dev.php/product`

*	$product用起來像是一般的PHP物件
*	`EntityManager`物件負責管理將物件匯入或匯出資料庫的工作
*	`persist()`要求Doctrine將`$product`物件放入資料庫。然而整個動作並不會馬上執行。
*	`flush()`執行後，Doctrine才會有動作

Doctrine透過累積待執行的SQL Query，並且等程式呼叫`flush()`的時候才會對這些SQL Query做最佳化並執行。這種模式叫做_Unit of Work_。

Doctrine另外提供一個Bundle讓開發者能夠輕鬆的匯入測試用資料:[DoctrineFixturesBundle](http://symfony.com/doc/current/bundles/DoctrineFixturesBundle/index.html)

<h2 id="simple_example_load">自資料庫匯出資料</h2>

一個呈現資料的頁面:

``` php show Product
<?php
// ...
    /**
     * @Route("/show/{id}")
     * @param integer $id
     */
    public function showAction($id)
    {
        $product = $this->getDoctrine()
            ->getRepository("AcmeStoreBundle:Product")
            ->find($id);
        if (!$product) {
            throw $this->createNotFoundException("No product found for id " . $id);
        }
        
        return new Response("Product id $id is: " . serialize($product));
    }
// ...
```

馬上試試看: 打開`http://<ip>/app_dev.php/show/1`

*	Repository物件是用來從資料庫內匯出資料到物件的。
*	`AcmeStoreBundle:Product`是可在Doctrine內使用的簡稱。完整的名稱是`Acme\StoreBundle\Entity\Product`。
*	Repository物件有以下好用的方法:

		// query by the primary key (usually "id")
		$product = $repository->find($id);
		
		// dynamic method names to find based on a column value
		$product = $repository->findOneById($id);
		$product = $repository->findOneByName('foo');
		
		// find *all* products
		$products = $repository->findAll();
		
		// find a group of products based on an arbitrary column value
		$products = $repository->findByPrice(19.99);

*	`findBy()`和`findOneBy()`方法可以使用多重條件:

		// query for one product matching be name and price
		$product = $repository->findOneBy(array('name' => 'foo', 'price' => 19.99));
		
		// query for all products matching the name, ordered by price
		$product = $repository->findBy(
    		array('name' => 'foo'),
    		array('price' => 'ASC')
		);

*	右下角可以檢視Query數量。  ![Check_Query](http://project.tw.f2ware.com/img/doctrine_web_debug_toolbar.png)

<h2 id="simple_example_update">更新物件</h2>

範例:

``` php update
<?php
//...
    /**
     * @Route("/update/{id}")
     */
    public function updateAction($id) 
    {
        $em = $this->getDoctrine()->getEntityManager();
        $product = $em->getRepository("AcmeStoreBundle:Product")->find($id);
        
        if (!$product) {
            throw $this->createNotFoundException("No product found for id " . $id);
        }
        
        $product->setName("New product name!");
        $em->flush();
        
        return new Response("Product id $id is: " . serialize($product));
    }
//...
```

<h2 id="simple_example_delete">刪除物件</h2>

``` php delete
<?php
$em->remove($product);
$em->flush();
```

<h2 id="simple_example_query">查詢物件</h2>

除了剛剛看到用Repository物件的方法查詢物件外

	$repository->find($id);
	$repository->findOneByName('Foo');

開發者還可以使用Doctrine Query Language(DQL)來寫更複雜的查詢語法。DQL和SQL類似，差異在於開發者必須轉換為想像自己是在查詢物件(如Product)而非一個表格內的列。

Doctrine中做查詢有兩種選擇:

<h3 id="simple_example_query_DQL">用DQO做查詢</h3>

``` php DQL
<?php
$em = $this->getDoctrine()->getEntityManager();
$query = $em->createQuery(
    'SELECT p FROM AcmeStoreBundle:Product p WHERE p.price > :price ORDER BY p.price ASC'
)->setParameter('price', '19.99');

$products = $query->getResult();
```

*	`:price`是留一個空位待後來的`setParameter()`來填。這種方式可以避免_SQL injection攻擊_。所以無論如何都應該這樣做。

基本上和標準SQL非常類似。




`getResult()`會回傳一個物件陣列，而`getSingleResult()`只回傳單一物件。

*	當找不到東西的時候，`getSingleResult()`會丟出`Doctrine\ORM\NoResultException`。
*	當找到超過一個東西時，`getSingleResult()`會丟出`Doctrine\ORM\NonUniqueResultException`。

DQL很強大，細節請參閱[Doctrine Query Language](http://docs.doctrine-project.org/projects/doctrine-orm/en/2.1/reference/dql-doctrine-query-language.html)

<h3 id="simple_example_query_doctrine_query_builder">Doctrine Query Builder</h3>

這種方式會更貼近物件導向的介面，而且還可以獲得IDE的支援。

``` php Doctrine Query Builder
<?php
$repository = $this->getDoctrine()
    ->getRepository('AcmeStoreBundle:Product');

$query = $repository->createQueryBuilder('p')
    ->where('p.price > :price')
    ->setParameter('price', '19.99')
    ->orderBy('p.price', 'ASC')
    ->getQuery();

$products = $query->getResult();
```

細節請參閱Doctrine的官方文件[Query Builder](http://docs.doctrine-project.org/projects/doctrine-orm/en/2.1/reference/query-builder.html)

<h2 id="simple_example_custom_repository">客製化Repository物件</h2>

開發者若想提高程式碼的可重複性和測試性，應該把一些資料庫相關的邏輯自Controller抽出，放置於客製化的Repository物件中。

首先在Product的註解中增加一個ProductRepository的項目

``` php Customize Repository
<?php
// src/Acme/StoreBundle/Entity/Product.php
namespace Acme\StoreBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * @ORM\Entity(repositoryClass="Acme\StoreBundle\Repository\ProductRepository")
 */
class Product
{
    //...
}
```

接著執行

``` sh generate repository class
php app/console doctrine:generate:entities Acme
```

*	這個指令和產生getter/setter的一樣

新增`findAllOrderedByName()`方法到產生的ProductRepository物件:

``` php findAllOrderByName
<?php
//...
    public function findAllOrderByName()
    {
        return $this->getEntityManager()
            ->createQuery("SELECT p FROM AcmeStoreBundle:Product p ORDER BY p.name ASC")
            ->getResult();
    }
//...
```

*	在EntityRepository物件中可以直接透過`getEntityManager()`方法獲得EntityManager

接著就可以在Controller或是其他地方直接使用這個方法:

	$em = $this->getDoctrine()->getEntityManager();
	$products = $em->getRepository('AcmeStoreBundle:Product')
            ->findAllOrderedByName();

<h1 id="entity_relationship">Entity間的關聯</h1>

為了說明Entity間的關聯，我們考慮以下的Schema: ![demo_schema](http://project.tw.f2ware.com/img/symfony2_doctrine_demo_schema.jpeg)

建立Category 物件:

``` sh 
php app/console doctrine:generate:entity --entity="AcmeStoreBundle:Category" --fields="name:string(255)"
```

<h2 id="entity_relationship_mapping">建立Entity間的關聯</h2>

在`Category.php`內新增註解:

``` php src/Acme/StoreBundle/Entity/Category.php
<?php
// src/Acme/StoreBundle/Entity/Category.php
// ...
use Doctrine\Common\Collections\ArrayCollection;

class Category
{
    // ...

    /**
     * @ORM\OneToMany(targetEntity="Product", mappedBy="category")
     */
    protected $products;

    public function __construct()
    {
        $this->products = new ArrayCollection();
    }
}
```

*	建立了新的`$products`field。
*	`@ORM\OneToMany`表示這是一(Category)對多(Product)的關係。
*	`__construct()`表示`$this->products`是一個ArrayCollection物件。這種物件和Array非常非常類似。
*	`targetEntity`內部只寫"Product"表示是和Category在相同的namespace。要跨越不同的namespace的話要寫完整的namespace。

同樣的Product也要修改:

``` php src/Acme/StoreBundle/Entity/Product.php
<?php
// src/Acme/StoreBundle/Entity/Product.php
// ...

class Product
{
    // ...

    /**
     * @ORM\ManyToOne(targetEntity="Category", inversedBy="products")
     * @ORM\JoinColumn(name="category_id", referencedColumnName="id")
     */
    protected $category;
}
```

接著執行:

``` sh
php app/console doctrine:generate:entities Acme
```

來產生所需要的getter/setter。

上述的設定足夠讓Doctrine了解Product和Category間的關係，也因此它會在Product內建立一個ForeignKey: category_id。

``` sh
php app/console doctrine:schema:update --force
```

*	這個指令只適用於Dev環境。要在Prod環境修改資料庫Schema請參考[Doctrine migrations](http://symfony.com/doc/current/bundles/DoctrineMigrationsBundle/index.html)

<h2 id="entity_relationship_save">儲存關聯Entity</h2>

考慮以下的Controller:

``` php
<?php
// ...
use Acme\StoreBundle\Entity\Category;
use Acme\StoreBundle\Entity\Product;
use Symfony\Component\HttpFoundation\Response;
// ...

class DefaultController extends Controller
{
    public function createProductAction()
    {
        $category = new Category();
        $category->setName('Main Products');

        $product = new Product();
        $product->setName('Foo');
        $product->setPrice(19.99);
        // relate this product to the category
        $product->setCategory($category);

        $em = $this->getDoctrine()->getEntityManager();
        $em->persist($category);
        $em->persist($product);
        $em->flush();

        return new Response(
            'Created product id: '.$product->getId().' and category id: '.$category->getId()
        );
    }
}
```

該Controller會建立一個Category，然後建立一個Product並將剛剛的Category.id指派給Product.category_id。

<h2 id="entity_relationship_load">讀取關聯Entity</h2>

從Product到Category:

``` php
<?php
public function showAction($id)
{
    $product = $this->getDoctrine()
        ->getRepository('AcmeStoreBundle:Product')
        ->find($id);

    $categoryName = $product->getCategory()->getName();

    // ...
}
```

這部分的程式碼會執行兩次SQL Query:

1.	`find()`執行第一次SQL Query回傳一個Product物件。
2.	`getName()`會執行第二次SQL Query。

從Category到Product:

``` php
<?php
public function showProductAction($id)
{
    $category = $this->getDoctrine()
        ->getRepository('AcmeStoreBundle:Category')
        ->find($id);

    $products = $category->getProducts();

    // ...
}
```

這一樣也是兩次SQL Query，而且得到一個Product物件的陣列。

事實上在`$product->getCategory()`裡Doctrine會回傳的是Category的Proxy物件，並等到真的要跟Proxy物件要資料的時候才做SQL Query。

<h2 id="entity_relationship_join">合併關聯Entity</h2>

如果想要只用一次SQL Query得到類似的結果，那就需要用到合併。由於合併的邏輯比較複雜，我們將它放在Repository物件中:

``` php src/Acme/StoreBundle/Repository/ProductRepository.php
<?php
// src/Acme/StoreBundle/Repository/ProductRepository.php

public function findOneByIdJoinedToCategory($id)
{
    $query = $this->getEntityManager()
        ->createQuery('
            SELECT p, c FROM AcmeStoreBundle:Product p
            JOIN p.category c
            WHERE p.id = :id'
        )->setParameter('id', $id);

    try {
        return $query->getSingleResult();
    } catch (\Doctrine\ORM\NoResultException $e) {
        return null;
    }
}
```

Controller:

``` php under Controller
<?php
public function showAction($id)
{
    $product = $this->getDoctrine()
        ->getRepository('AcmeStoreBundle:Product')
        ->findOneByIdJoinedToCategory($id);

    $category = $product->getCategory();

    // ...
}
```

在此Doctrine就會回傳真正的Category物件，而非Proxy物件。

<h2 id="entity_relationship_more">其他關聯</h2>

請參閱Doctrine的文件: [Association Mapping Documentation](http://docs.doctrine-project.org/projects/doctrine-orm/en/2.1/reference/association-mapping.html)

<h1 id="configuration">設定</h1>

Doctrine的設定非常的有彈性，以下簡單列出可設定的項目。如果需要詳細的內容，請參閱[reference manual](http://symfony.com/doc/current/reference/configuration/doctrine.html)

*	Cache引擎(array, apc, memcache, xcache)
*	Entity和資料庫的對應關係
	*	type(annotation, xml, yml, php, staticphp)
	*	路徑
	*	前置裝飾(prefix)
	*	別名(alias)
*	資料庫連線設定(可連線多資料庫)

<h1 id="lifecycle_callback">Lifecycle Callbacks</h1>

當某些entity做完某些SQL動作後，開發者可能會想執行某些行為，而這類動作被稱為Lifecycle Callbacks。

如果使用註解格式，在使用Lifecycle Callbacks之前須要:

``` php
<?php
/**
 * @ORM\Entity()
 * @ORM\HasLifecycleCallbacks()
 */
class Product
{
    // ...
}
```

其他格式(Yaml、XML不需要)。

以下語法讓每次在insert(不包含update)動作後會紀錄建立時間:

``` php
<?php
/**
 * @ORM\prePersist
 */
public function setCreatedValue()
{
    $this->created = new \DateTime();
}
```

*	這段程式碼有假設開發者已經為entity物件建立created屬性。

類似的callbacks時間點包含:

*	preRemove
*	postRemove
*	prePersist
*	postPersist
*	preUpdate
*	postUpdate
*	postLoad
*	loadClassMetadata

細節請參閱Doctrine文件: [Lifecycle Events documentation](http://docs.doctrine-project.org/projects/doctrine-orm/en/2.1/reference/events.html#lifecycle-events)

Lifecycle Callback內的程式碼應該單純到只設及Entity的內部資料。如果邏輯更複雜，牽涉到外部的資源(例如要寫log)，那應該使用event listener機制。請注意，`setCreatedValue()`是沒有引數的。

<h1 id="doctrine_extension">擴充Doctrine</h1>

Doctrine包含許多第三方套件讓開發者可以簡單的完成某些常用功能:

*	Sluggable
*	Timestampable
*	Loggable
*	Translatable
*	Tree

請參閱[Using Common Doctrine Extensions](http://symfony.com/doc/current/cookbook/doctrine/common_extensions.html)

<h1 id="doctrine_field_type_reference">索引:Doctrine欄位型態</h1>

*	字串
	*	string 固定長度字串
	*	text 長字串
*	數字
	*	integer
	*	smallint
	*	bigint
	*	decimal
	*	float
*	日期時間 (PHP的[DateTime](http://php.net/manual/en/class.datetime.php)物件)
	*	date
	*	time
	*	datetime
*	其他
	*	boolean
	*	object	(CLOB)
	*	array	(CLOB)
詳細內容請參閱Doctrine的官方文件[Mapping Types documentation](http://docs.doctrine-project.org/projects/doctrine-orm/en/2.1/reference/basic-mapping.html#doctrine-mapping-types)

<h1 id="reference">參考網頁</h1>

本文為我閱讀[Symfony2 - Doctrine](http://symfony.com/doc/current/book/doctrine.html)的心得。