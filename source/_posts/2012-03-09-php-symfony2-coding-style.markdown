---
layout: post
title: "php-symfony2 coding-style"
date: 2012-03-09 13:55
comments: true
categories: 
---

建議開發者遵循Symfony的[Coding Standards](http://symfony.com/doc/2.0/contributing/code/standards.html)

第一個範例：
``` php example of symfony coding standard
<?php

/*
 * This file is part of the Symfony package.
 *
 * (c) Fabien Potencier <fabien@symfony.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Acme;

class Foo
{
    const SOME_CONST = 42;

    private $foo;

    /**
     * @param string $dummy Some argument description
     */
    public function __construct($dummy)
    {
        $this->foo = $this->transform($dummy);
    }

    /**
     * @param string $dummy Some argument description
     * @return string|null Transformed input
     */
    private function transform($dummy)
    {
        if (true === $dummy) {
            return;
        }
        if ('string' === $dummy) {
            $dummy = substr($dummy, 0, 5);
        }

        return $dummy;
    }
}
```

架構：
*	永遠不用*<?*
*	class file不以*?>*結尾
*	縮排是使用4個空格，而不是tab
	在Eclipse-PDT內的設定方式為:
	Windows -> Preference -> PHP -> Code Style -> Formatter
*	