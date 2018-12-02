---
layout: post
title: "php開發建置"
date: 2012-03-09 11:23
comments: true
categories: PHP eclipse svn
---

*	[環境](#env)
*	[開發工具](#dev-tool)
*	[建置步驟](#build-env)
	*	[安裝IIS7 + php-fastcgi](#IIS-php-fastcgi)
	*	[安裝eclipse-PDT和svn](#eclipse-svn)
	*	[匯入既有的SVN Repository](#import-svn)
	*	[安裝Xdebug](#xdebug)
	*	[設定遠端除錯環境](#remote-debug)
	*	[設定php和MSSQL的連線](#database)
*	[參考網頁](#reference)

	
<h1 id="env">環境</h1>
*	server: windows 2008 R2
*	client: windows 7
*	database: MSSQL 2008 R2 Express

<h1 id="dev-tool">開發工具</h1>
*	[eclipse-PDT](http://www.eclipse.org/projects/project.php?id=tools.pdt)
*	svn
	*	[tortoise-svn](http://tortoisesvn.net/downloads.html)
	*	[subclipse](http://subclipse.tigris.org/)

ps. 本文件僅測試於IIS7, php5.3.10, eclipse-PDT 3.0.2, subclipse 1.8.x, XDebug 2.1.3

<h1 id="build-env">建置步驟</h1>

<h2 id="IIS-php-fastcgi">安裝IIS7 + php-fastcgi</h2>


1.	安裝IIS7
	*	需安裝cgi
2.	安裝[php5.3](http://windows.php.net/download/)
	*	下載VC9 x86 Non Thread Safe ZIP
	*	解壓縮到*c:\php*
3.	安裝[Microsoft Visual C++ 2008 Redistributable Package (x86)](http://www.microsoft.com/download/en/details.aspx?id=29)
4.	測試以下的命令碼：
		c:\php\php.exe -i
	ps. 如出現*side-by-side effect*的錯誤訊息表示步驟3有問題
5.	設定*php.ini*：
	*	複製php.ini-development至php.ini
	*	修改以下內容：
		fastcgi.impersonate = 1
		cgi.fix_pathinfo = 1
		date.timezone = "Asia/Taipei"
6.	設定fast-cgi Mapping Handler
7.	至*c:\inetpub\wwwroot*建立*phpinfo.php*並修改內容為:
		<?php phpinfo() ?>
8.	打開*http://<server的ip>/phpinfo.php須出現phpinfo畫面
	*	如出現500可能是步驟5的*date.timezone*未設定成功

<h2 id="eclipse-svn">安裝eclipse-PDT和svn</h2>
1.	安裝jre, 雖然我不喜歡Oracle, 但這只是為了方便... [Sun Java](http://java.com/en/download/manual.jsp)
2.	下載eclipse-PDT並解壓縮至*c:\eclipse-php*
ps.	jre和eclipse-PDT必須同時為x86或x64
3.	執行*c:\eclipse-php\eclipse.exe*
4.	安裝subclipse
	*	Help -> Install New Software
	*	在Work with:欄位輸入`http://subclipse.tigris.org/update_1.8.x`
	*	勾選Subclipse, SVNKit; 不勾選Subclipse底下的Subclipse Integration for Mylyn 3.x (Optional)

<h2 id="import-svn">匯入既有的SVN Repository</h2>
1.	於eclipse內打開`SVN repository Exploring` Perspective
2.	於SVN Repositories內點右鍵, 選New
3.	輸入svn repository的URL

<h2 id="xdebug">安裝XDebug</h2>
1.	下載Xdebug Windows Binary(VC9 32bit)
2.	將下載的.dll複製至*c:\php\ext*
3.	修改php.ini，新增以下內容
		[xdebug]
		zend_extension=c:\php\ext\php_xdebug-2.1.3-5.3-vc9-nts.dll
4.	於命令列輸入`c:\php\php.exe -m`檢查輸出內有無xdebug

<h2 id="remote-debug">設定遠端除錯環境</h2>
1.	修改要進行除錯的eclipse設定如下:
	*	開啟PHP專案
	*	Windows -> Preferences -> PHP -> Debug
		將PHP Debugger從Zend Debugger改成Xdebug後，點選右邊的Configure...
	*	於Installed Debuggers內選Xdebug後點右邊的Configure
	*	Accept remote seesion (JIT) 從 off 改成 any 後點OK
	*	點Apply
2.	設定要開網頁的瀏覽器(僅以Firefox為例)
	*	安裝[easy Xdebug for FireFox](https://addons.mozilla.org/en-US/firefox/addon/58688/)
3.	設定php.ini:
		[xdebug]
		zend_extension=c:\php\ext\php_xdebug-2.1.3-5.3-vc9-nts.dll
		xdebug.remote_enable=On
		xdebug.remote_handler="dbgp"
		xdebug.remote_mode="req"
		xdebug.remote_port=9000
		xdebug.remote_host="YOUR.IP.GOES.HERE"
		xdebug.remote_log=/path/to/xdebug_remote_log

<h2 id="database">設定php和MSSQL的連線</h2>

*	下載並安裝[VC++ 2008 Redistributable Package(x86)](http://www.microsoft.com/download/en/details.aspx?id=29)
*	下載[MS Driver 3.0 for SQL Server for PHP](http://www.microsoft.com/download/en/details.aspx?id=20098#system-requirements)
*	修改php.ini，新增:

``` ini php.ini
;...
extension=c:\php\ext\php_pdo_sqlsrv_53_nts_vc9.dll
;...
```

*	檢查能否讀取

``` sh
c:\php\php -m
```

看看有無`pdo_sqlsrv`

*	還要安裝其他相依套件，請參考[`http://go.microsoft.com/fwlink/?LinkId=163712`](http://go.microsoft.com/fwlink/?LinkId=163712)。

ps. 由於我本來就已經有VC9版本的ODBC Client、pdo_sqlsrv VC9版本，所以我安裝這些版本沒問題，但是在安裝新下載的3.0版本卻問題一堆。等到之後我有和它奮鬥後再把心得Po上來吧。

<h1 id="reference">參考網頁</h1>
*	[設定FastCGI以裝載PHP應用程式(IIS7)]("http://technet.microsoft.com/zh-tw/library/dd239230(v=ws.10).aspx")
*	[Eclipse PDT](http://www.eclipse.org/projects/project.php?id=tools.pdt)
*	[Subclipse](http://subclipse.tigris.org/)
*	[Xdebug Installation](http://xdebug.org/docs/install)
*	[Xdebug Remote Debugging](http://xdebug.org/docs/remote)