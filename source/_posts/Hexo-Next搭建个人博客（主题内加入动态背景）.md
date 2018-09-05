---
title: Hexo-Next搭建个人博客（主题内加入动态背景）
copyright: true
top: 95
date: 2018-08-08 16:48:48
categories: Hexo
tags: [Hexo,Next]
image: http://pic1.win4000.com/wallpaper/2018-08-16/5b74e3576bcc4.jpg
description: 本文介绍如何给Blog主题添加静态背景和动态背景特效
---
<span>
<!--more-->

#### 添加静态背景

1. 打开博客根目录/themes/next/source/css/_custom/custom.styl文件，编辑如下：

```
// Custom styles.
body { 
	background-image: url(/images/background.png);
	background-attachment: fixed; // 不随屏幕滚动而滚动
	background-repeat: no-repeat; // 如果背景图不够屏幕大小则重复铺，改为no-repeat则表示不重复铺
	//background-size: contain; // 等比例铺满屏幕
}
```
2. 将背景图命名为background.png并放入主题根目录/images下


#### 添加动态背景

[](#layout-swig "_layout.swig")_layout.swig
===========================================

找到`themes\next\layout\_layout.swig`文件，添加内容：  
在`<body>`里添加：  

```
<div class="bg_content">
  <canvas id="canvas"></canvas>
</div>
```

仍是该文件，在末尾添加：  

```
<script type="text/javascript" src="/js/src/dynamic_bg.js"></script>
```
[](#dynamic-bg-js "dynamic_bg.js")dynamic_bg.js
===============================================

在`themes\next\source\js\src`中新建文件`dynamic_bg.js`，代码链接中可见：[dynamic_bg.js](https://github.com/asdfv1929/asdfv1929.github.io/blob/master/js/src/dynamic_bg.js)

[](#custom-styl "custom.styl")custom.styl
=========================================

在`themes\next\source\css\_custom\custom.styl`文件末尾添加内容：  
```
.bg_content {
  position: fixed;
  top: 0;
  z-index: -1;
  width: 100%;
  height: 100%;
}
```