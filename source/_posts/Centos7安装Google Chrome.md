---
title: Centos7安装Google Chrome
copyright: true
top: 95
date: 2018-10-21 14:19:13
categories: [Linux]
tags: [Linux,Centos,Google Chrome]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1540192948086_0.png
description:
---

<span></span>

<!--more-->

## 1.首先进入根目录，然后进入etc/yum.repos.d目录下，创建google-chrome.repo文件

```
cd /
cd etc/yum.repos.d
vi google-chrome.repo
```

## 2.在文件中添加：

```
[google-chrome] 
name=google-chrome 
baseurl=http://dl.google.com/linux/chrome/rpm/stable/$basearch 
enabled=1
gpgcheck=1 
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
```
`ESC 退出到命令模式，shift+q ， x保存退出`

## 3.加入谷歌的源之后键入：

```
yum -y install google-chrome-stable --nogpgcheck
```

## 4.安装完成。

在应用程序的互联网中就可以找到谷歌浏览器了。