---
title: windows解除iis占用80端口
copyright: true
top: 95
date: 2018-10-26 14:28:11
categories: [IIS]
tags: [80,IIS]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/13101.jpg?x-oss-process=style/ys30
description:
---

<span></span>

<!--more-->


## 方法一 卸载iis

我的电脑-添加或删除组件-添加或删除Windows组件-IIS信息服务
去掉 IIS前面的勾然后“下一步”就可以了。

## 方法二 改iis的端口

我的电脑-右击-管理-iis管理-Default Web Site右击-编辑绑定


## 方法三 停止iis服务

- 在管理员命令行运行`iisreset/stop`  开启使用`iisreset/stop`即可
- 服务里关闭World Wide Web Publishing Service

## 方法四 

修改使用的软件的端口

## 方法五

在管理员命令行运行`netstat -aon|findstr 80`，然后tskill 占用的端口