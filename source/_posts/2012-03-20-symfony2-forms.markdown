---
layout: post
title: "symfony2-forms"
date: 2012-03-20 10:45
comments: true
categories: 
---


<h1 id="introduction">簡介</h1>

處理HTML表單(form)一直是Web應用中最重要的一部分。因此Symfony2將表單的邏輯抽出來獨立包成一個套件。這個套件並不需要和Symfony2，如果想要在其他專案使用Symfony2的表單套件，請參考[Symfony2 Form Component](https://github.com/symfony/Form)。


<h1 id="example">建立簡單的表單</h1>

ps. 如果想要跟著範例走的話，請先執行:

``` sh
php app/console generate:bundle --namespace=Acme/TaskBundle
```

在Symfony2中的表單系統，其實就是把每個表單背後的資料都抽象化為一個PHP物件。直接看範例:

``` php src/Acme/TaskBundle/Entity/Task.php
<?php
namespace Acme\TaskBundle\Entity;

class Task
{
    protected $task;

    protected $dueDate;

    public function getTask()
    {
        return $this->task;
    }
    public function setTask($task)
    {
        $this->task = $task;
    }

    public function getDueDate()
    {
        return $this->dueDate;
    }
    public function setDueDate(\DateTime $dueDate = null)
    {
        $this->dueDate = $dueDate;
    }
}
```

這是一個很簡單的物件，只有兩個屬性:`$task`和`$dueDate`，並且建立了相對應的getter、setter。

<h2 id="example_build_form">建立表單</h2>

若要依據上述建立的Task物件來產生表單，只要在Controller中透過FormBuilder就可以了:

``` php src/Acme/TaskBundle/Controller/DefaultController.php
<?php
// src/Acme/TaskBundle/Controller/DefaultController.php
namespace Acme\TaskBundle\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\Controller;
use Acme\TaskBundle\Entity\Task;
use Symfony\Component\HttpFoundation\Request;

class DefaultController extends Controller
{
    public function newAction(Request $request)
    {
        // create a task and give it some dummy data for this example
        $task = new Task();
        $task->setTask('Write a blog post');
        $task->setDueDate(new \DateTime('tomorrow'));

        $form = $this->createFormBuilder($task)
            ->add('task', 'text')
            ->add('dueDate', 'date')
            ->getForm();

        return $this->render('AcmeTaskBundle:Default:new.html.twig', array(
            'form' => $form->createView(),
        ));
    }
}
```

仔細看一下Controller內部做的動作:

1.	建立了一個Task物件的實體`$task`並且透過setter設定該`$task`的屬性。
2.	呼叫`createFormBuilder()`，把`$task`丟進去，並且設定兩個欄位後最後用`getForm()`取得對應的表單物件`$form`。
3.	把`$form->createView()`丟給View去產生瀏覽器看到的表單元件。

<h2 id="example_render_form">顯示表單</h2>

接下來故事就轉移到了View的部分:

``` html+django
{# src/Acme/TaskBundle/Resources/views/Default/new.html.twig #}

<form action="{{ path('task_new', {} ) }}" method="post" {{ form_enctype(form) }}>
    {{ form_widget(form) }}

    <input type="submit" />
</form>
```

預設的顯示指令是`form_widget()`。

<h2 id="example_handle_form_submission">處理表單</h2>

直接看例子:

``` php
<?php
// ...

public function newAction(Request $request)
{
    // just setup a fresh $task object (remove the dummy data)
    $task = new Task();

    $form = $this->createFormBuilder($task)
        ->add('task', 'text')
        ->add('dueDate', 'date')
        ->getForm();

    if ($request->getMethod() == 'POST') {
        $form->bindRequest($request);

        if ($form->isValid()) {
            // perform some action, such as saving the task to the database

            return $this->redirect($this->generateUrl('task_success'));
        }
    }

    // ...
}
```

處理的指令是`$form->bindRequest($request)`。後來的`$form->isValid()`則是檢驗表單的資料。

上述的這個例子內，Controller包含了以下三種功能:

1.	如果只是讀取頁面(http GET)，會顯示表單供使用者填寫。
2.	如果使用者是傳送錯誤的表單資料(http POST)，會打回到1.並且提示錯誤內容。
3.	如果是有效的資料，則伺服器可以針對`$task`物件去做接下來的功能...

當表單是有效的時候，`redirect()`是一個可以預防使用者因為點選_重新整理_而導致重複提交資料的好方法。

<h1 id="form_validation">表單檢驗</h1>

Symfony2中，檢驗的規則是定義於表單背後的物件(Task物件)的。所以開發者要想的不是表單是否有效，而是表單背後的物件是否有效。語法`$form->isValid()`只是檢驗`$task`是否有效的功能。

ps. 好吧，我覺得如果Symfony2的設計理念是如此的話，那這個語法是應該要改掉。很不直覺。

直接看對物件定義規則(constraint)的例子:

``` php
<?php
// Acme/TaskBundle/Entity/Task.php
use Symfony\Component\Validator\Constraints as Assert;

class Task
{
    /**
     * @Assert\NotBlank()
     */
    public $task;

    /**
     * @Assert\NotBlank()
     * @Assert\Type("\DateTime")
     */
    protected $dueDate;
}
```

除了伺服器端的驗證，Symfony2也會自動於客戶端的瀏覽器上利用HTML5的機制進行檢驗。如果要關掉客戶端的檢驗功能，就在`form`標籤上增加`novalidate`屬性，或是在`submit`標籤上增加`formnovalidate`屬性。

Symfony2中的檢驗功能很強大，有自己的解說章節。

<h2 id="form_validation_group">檢驗群組</h2>

可以指示表單遵循某個檢驗群組的規範:

``` php
<?php
$form = $this->createFormBuilder($users, array(
    'validation_groups' => array('registration'),
))->add(...)
;
```

或是在Form物件中加上`getDefaultOptions()`方法:

``` php
<?php
public function getDefaultOptions(array $options)
{
    return array(
        'validation_groups' => array('registration')
    );
}
```

<h1 id="form_field_type">表單欄位型態</h1>

在[建立表單](#example_build_form)的範例中使用了:

``` php
<?php
        $form = $this->createFormBuilder($task)
            ->add('task', 'text')
            ->add('dueDate', 'date')
            ->getForm();
```

的語法，其中`text`和`date`都是表單欄位的型態。請參閱[內建的表單欄位型態](http://symfony.com/doc/current/book/forms.html#built-in-field-types)或[自訂欄位型態](http://symfony.com/doc/current/cookbook/form/create_custom_field_type.html)。

<h2 id="form_field_type_options">表單欄位選項</h2>

`add()`方法的第三個參數是用於設定表單欄位的選項。細節請參閱[內建的表單欄位型態](http://symfony.com/doc/current/book/forms.html#built-in-field-types)中各個欄位屬性的說明。

需要特別注意的是`required`選項，只和客戶端的檢驗有關。這不影響伺服器端的檢驗。伺服器端的檢驗是針對物件使用`NotBlank`或`NotNull`規則。

請記得: 客戶端的檢驗很好，但是不能取代伺服器端的檢驗。_惡意使用者總是有辦法繞過客戶端的檢驗。_

每個表單欄位呈現給使用者的文字提式可以透過`label`選項來調整:

``` php
<?php
->add('dueDate', 'date', array(
    'widget' => 'single_text',
    'label'  => 'Due Date',
))
```

<h1 id="field_guessing">自動判斷</h1>

<h2 id="field_guessing_type">自動判斷欄位型態</h2>

Symfony2會根據Task物件的規則來猜欄位的型態:

``` php
<?php
public function newAction()
{
    $task = new Task();

    $form = $this->createFormBuilder($task)
        ->add('task')
        ->add('dueDate', null, array('widget' => 'single_text'))
        ->getForm();
}
```

*	`add('task')`中沒有提供第二個參數，所以Symfony2會自動判斷對應欄位的型態。
*	`add('dueDate', null, ...)`中第二個參數是`NULL`，所以Symfony2也會自動判斷欄位型態。

使用檢驗群組的時候，Symfony2會一併考慮所有的規則。

<h2 id="field_guession_options">自動判斷欄位選項</h2>

Symfony2也能自動判斷以下的欄位選項:

*	`required`
*	`min_length`
*	`max_length`

這類型的自動判斷只有在啟用[自動判斷欄位型態](#field_guessing_type)的時候才會啟用。

如果不想使用自動判斷的值，可以手動設定:

``` php
<?php
->add('task', null, array('min_length' => 4))
```

<h1 id="form_template">表單和Template</h1>

在[顯示表單](#example_render_form)中，雖然可以很方便的透過`form_widget(form)`來呈現表單給使用者，但是若是要美化使用者介面時，就需要更有彈性的寫法:

``` html+django
{# src/Acme/TaskBundle/Resources/views/Default/new.html.twig #}

<form action="{{ path('task_new') }}" method="post" {{ form_enctype(form) }}>
    {{ form_errors(form) }}

    {{ form_row(form.task) }}
    {{ form_row(form.dueDate) }}

    {{ form_rest(form) }}

    <input type="submit" />
</form>
```

*	`form_enctype(form)`: 當至少有一個欄位是用於上傳檔案時，會套用`enctype="multipart/form-data"`屬性。
*	`form_errors(form)`: 顯示整體的表單錯誤訊息。(個別欄位的錯誤訊息會呈現於該欄位旁邊)
*	`form_row(form.dueData): 呈現一個表單欄位，通常會...TODO

<h2 id="form_template_hand">手工刻表單</h2>

``` html+django
{{ form_errors(form) }}

<div>
    {{ form_label(form.task) }}
    {{ form_errors(form.task) }}
    {{ form_widget(form.task) }}
</div>

<div>
    {{ form_label(form.dueDate) }}
    {{ form_errors(form.dueDate) }}
    {{ form_widget(form.dueDate) }}
</div>

{{ form_rest(form) }}
```

調整顯示文字:

``` html+django
{{ form_label(form.task, 'Task Description') }}
```

調整HTML標籤屬性:

``` html+django
{{ form_widget(form.task, { 'attr': {'class': 'task_field'} }) }}
```

完全手工 - 直接抓取物件屬性:

``` html+django
{{ form.task.vars.id }}
{{ form.task.vars.full_name }}
```

<h2 id="form_template_function_reference">Twig表單相關函數索引</h2>

如果還需要更細微的調整，請參考[reference manual](http://symfony.com/doc/current/reference/forms/twig_reference.html)。

<h1 id="create_form_class">建立表單物件</h1>

表單的邏輯很複雜，故較建議將表單的邏輯自Controller抽出來，以方便重複使用和測試。

``` php src/Acme/TaskBundle/Form/Type/TaskType.php
<?php
// src/Acme/TaskBundle/Form/Type/TaskType.php

namespace Acme\TaskBundle\Form\Type;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilder;

class TaskType extends AbstractType
{
    public function buildForm(FormBuilder $builder, array $options)
    {
        $builder->add('task');
        $builder->add('dueDate', null, array('widget' => 'single_text'));
    }

    public function getName()
    {
        return 'task';
    }
}
```

*	`getName()`回傳一個唯一的用於辨識表單物件的名稱。

以下的例子將上述TaskType物件用於Controller中:

``` php
<?php src/Acme/TaskBundle/Controller/DefaultController.php
// src/Acme/TaskBundle/Controller/DefaultController.php

// add this new use statement at the top of the class
use Acme\TaskBundle\Form\Type\TaskType;

public function newAction()
{
    $task = // ...
    $form = $this->createForm(new TaskType(), $task);

    // ...
}
```

每一個表單物件的背後都有一個對應的物件來代表表單處理的資料(例如Task物件)，而在Controller中是透過`$this->createForm()`的第二個參數來表示。但是當表單經過合成或嵌入後，就需要設定`data_class`。以下的表單物件方法設定`data_class`:

``` php 設定data_class
<?php
public function getDefaultOptions(array $options)
{
    return array(
        'data_class' => 'Acme\TaskBundle\Entity\Task',
    );
}
```

表單物件的每個欄位都會對應到背後資料物件的每個屬性。若兩者不一致Symfony2會丟例外出來。

除非該欄位的`property_path`選項被設置為`false`:

``` php 設定property_path
<?php
public function buildForm(FormBuilder $builder, array $options)
{
    $builder->add('task');
    $builder->add('dueDate', null, array('property_path' => false));
}
```

若遞交的資料內不包含某些表單欄位，它們會被設定為`NULL`。

<h1 id="form_doctrine">表單和Doctrine</h1>

一個HTML表單透過Symfony的表單系統可以和一個PHP物件互相轉換；而後者又可以透過Doctrine和資料庫內的資料互相轉換。因此只要透過適當的設定，HTML表單可以在驗證後直接存入資料庫:

``` php 將表單存入資料庫
<?php
if ($form->isValid()) {
    $em = $this->getDoctrine()->getEntityManager();
    $em->persist($task);
    $em->flush();

    return $this->redirect($this->generateUrl('task_success'));
}
```

在無法取得Task物件的狀況下，也可以用`$task = $form->getData();`。

Doctrine相關細節請讀[Doctrine ORM章節](http://symfony.com/doc/current/book/doctrine.html)
