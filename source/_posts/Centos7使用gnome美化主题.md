---
title: Centos7使用gnome美化主题
copyright: true
top: 95
date: 2018-10-21 14:26:10
categories: [Linux]
tags: [Linux,Centos,gnome]
image: http://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/2_20181021144228.png?x-oss-process=style/ys30
description: 
---

<span></span>

<!--more-->

先上效果图
![](http://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1_20181021143906.png)


## 1.安装必要工具、依赖
-------------

主题配置工具
```
sudo apt install gnome-tweak-tool
```
依赖
```
sudo apt install chrome-gnome-shell
```

## 2.浏览器安装扩展
-----------

浏览器打开[https://extensions.gnome.org/](https://extensions.gnome.org/)

![这里写图片描述](http://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/3_20181021145247.png)

## 3.安装User Themes
-----------------

![这里写图片描述](http://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/4_20181021145438.png)

更多请[点击这里](https://wiki.gnome.org/Projects/GnomeShellIntegrationForChrome/Installation)

## 4.创建主题和图标文件夹
--------------
```
mkdir ~/.themes
mkdir ~/.icons
```
## 5.下载[Github资源地址](https://github.com/wangxiaoleiAI/CSDN-CODE/tree/master/Ubuntu18.04-tutorials-themes)
-------------------------------------------------------------------------------------------------------

只需关注thmes和icons两个文件中的压缩包即可 [资源下载](https://github.com/wangxiaoleiAI/CSDN-CODE/tree/master/Ubuntu18.04-tutorials-themes)。
也可以在gnome-look.org 自行提取[原始资源地址](https://www.gnome-look.org/p/1013714/)

## 6.开始美化，放置资源
---------------

*   配置应用主题
*   配置gnome桌面效果

themes文件夹中的压缩包Sierra-light-solid.tar.xz打开后包含gnome-shell和gtk3，即gnome桌面效果与应用效果。

```
tar -xf Sierra-light-solid.tar.xz
mv Sierra-light-solid ~/.themes
```
MacOSX-icon-theme.tar.xz

*   配置图标效果
*   配置光标（鼠标）效果

icons文件夹中的MacOSX-cursors.tar.xz和MacOSX-icon-theme.tar.xz解压，放置在~/.icons中

```
tar -xf MacOSX-icon-theme.tar.xz
mv MacOSX ~/.icons
mv MacOSX-dark ~/.icons
    
tar -xf MacOSX-cursors.tar.xz.xz
mv capitaine-cursors ~/.icons
```

> 另外也可以配置字体，字体文件解压放置在~/.local/share/fonts/　字体不建议配置，配置不好影响正常内容显示

## 7.放置好资源后，配置tweaks如下图。
-----------------------

![这里写图片描述](http://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/5_20181021150507.png)

## 8.安装其余扩展插件
![这里写图片描述](http://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/6_20181021150814.png)
![这里写图片描述](http://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/7_20181021150855.png)

我推荐几款我用的
Dash to Dock：底部任务栏
GPaste：记录历史复制黏贴记录
OpenWeather：天气插件
...
更多就去插件中心自己找去吧。
