---
layout: post
title: "eclipse-svn-symfony"
date: 2012-03-09 18:36
comments: true
categories: 
---

<h1>Subclipse功能簡介</h1>

<h2>建立本機端的repository</h2>

*	於eclipse內打開SVN Repository的perspective
*	於SVN Repositories視窗內右邊的倒三角形 -> New repository...
*	選擇要建立repository的位置 -> OK

<h2>建立資料夾</h2>

*	右鍵點選repository -> New -> New remote folder
*	輸入資料夾名稱

<h2>匯入資料</h2>

*	右鍵點選資料夾 -> Import...
*	於Import directory內選擇要被匯入的資料
*	於Comment:內輸入註解
*	OK

<h2>Checkout並建立專案</h2>

*	右鍵點選要被Checkout的資料夾 -> Checkout...
*	選擇Check out as a project configured using the New Project Wizard
*	選擇Check out HEAD revision
*	選擇Depth:為Fully recursive
*	選擇Allow unversioned obstructions
*	Finish
*	選擇專案的種類為PHP Project
*	剩下的步驟同Eclipse建立新專案的步驟

<h2 id="commit">送交至Repository(Commit)</h2>

*	右鍵點選已經被修改的檔案 -> Team -> Commit...
*	視窗上方輸入要commit的message
*	視窗下方確認要送交的檔案/目錄
*	OK
*	請不要在送交的message內使用中文

<h2>自專案中新增檔案/目錄</h2>
*	右鍵點選要新增至repository的檔案/目錄 -> Team -> Add to Version Control
*	如果要取消, 請在右鍵點選要取消的檔案/目錄 -> Team -> Revert...
*	[送交](#commit)要新增的檔案/目錄

<h2>更新Repository</h2>
*	右鍵點選要更新的檔案/目錄 -> Team -> Update to HEAD

<h2>刪除Repository內的檔案/目錄</h2>
*	刪除檔案/目錄
*	送交

<h2>移動Repository內的檔案/目錄</h2>
*	移動檔案/目錄
*	送交

<h2>解決衝突</h2>
*	送交時發生out of date錯誤
*	更新時發現File conflicts
*	Edit Conflict
*	Mark Resolved...
*	送交

<h2>清除暫存的登入帳號密碼</h2>
*	Windows -> Preference -> Team -> SVN 檢查Client Adapter
*	依照[Subclipse Wiki FAQ](http://subclipse.tigris.org/wiki/PluginFAQ#head-d507c29676491f4419997a76735feb6ef0aa8cf8)的指示清除對應的資料夾

<h1>Symfony和svn</h1>
*	於Repository內建立三個資料夾:
		myproject/
		  branches/
		  tags/
		  trunk/
*	複製Symfony資料夾至myproject內
*	更改Symfony資料夾的名稱為專案名稱(以下仍繼續使用Symfony)
*	右鍵點選Symfony/src -> Team -> Add to Version Control
*	忽略下列檔案:
		vendor
		app/內的bootstrap*
		app/config/內的 parameters.ini
		app/cache/內的 *
		app/logs/內的 *
		web/內的 bundles

<h1>參考資料</h1>

*	[How to Create and store a Symfony2 Project in Subversion](http://symfony.com/doc/current/cookbook/workflow/new_project_svn.html)
