---
title: Hexo-Next搭建个人博客（添加网页标题崩溃欺骗搞怪特效）
copyright: true
top: 95
date: 2018-08-13 19:21:24
categories: Hexo
tags: [Hexo,Next]
description: 给网页title添加一些搞怪特效  
image: http://pic1.win4000.com/wallpaper/2017-12-26/5a41e3bb44b7b.jpg
---
<span></span>
<!--more-->

[](#crash-cheat-js "crash_cheat.js")crash_cheat.js
==================================================

在`next\source\js\src`文件夹下创建`crash_cheat.js`，添加代码：  

```
<!--崩溃欺骗-->
var OriginTitle = document.title;
var titleTime;
document.addEventListener('visibilitychange', function () {
    if (document.hidden) {
        $('[rel="icon"]').attr('href', "/img/TEP.ico");
        document.title = '╭(°A°`)╮ 页面崩溃啦 ~';
        clearTimeout(titleTime);
    }
    else {
        $('[rel="icon"]').attr('href', "/favicon.ico");
        document.title = '(ฅ>ω<*ฅ) 噫又好了~' + OriginTitle;
        titleTime = setTimeout(function () {
            document.title = OriginTitle;
        }, 2000);
    }
});
```
[](#引用 "引用")引用
==============

在`next\layout\_layout.swig`文件中，添加引用（注：在swig末尾添加）：  

```
<!--崩溃欺骗-->
<script type="text/javascript" src="/js/src/crash_cheat.js"></script>

```