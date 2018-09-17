---
title: Hexo-Next搭建个人博客（Hexo博客备份）
copyright: true
top: 95
date: 2018-09-17 08:39:51
tags: [Hexo,Next]
categories: Hexo
image: http://pic1.win4000.com/wallpaper/2018-04-23/5add3e078e29e.jpg
description: 解决下多终端下怎么同步写作备份的问题。
---

<span></span>

<!--more-->

### 一、需求：

在Windows和Mac下需要对Hexo进行管理和更新，或者进行重新部署环境。

### 二、思路

创建分支，一个分支用来存放Hexo生成的网站原始的文件，另一个分支用来存放生成的静态网页。

### 三、搭建的流程

博客搭建请看我之前的文章

1. 将themes/next/(我用的是NexT主题)中的.git/删除，否则无法将主题文件夹push；
2. 在本地blog文件夹下创建文件.gitignore(一般都自带一个)，打开后写入

```
.DS_Store
Thumbs.db
db.json
*.log
node_modules/
public/
.deploy*/
```
<div class="note info"><p>备注：  
刚开始好多备份的教程都没有说明.gitignore文件，在恢复之后，进行hexo d之后老是报错，发在邮箱里的错误内容</p></div>


![20160929001](http://oe53dpmqz.bkt.clouddn.com/20160929001.png)  
github给邮箱发送的内容，说：{% label danger@有模块没有初始化，在这里所指的就是.deploy_git这个模块 %}


3. 在本地blog文件夹下执行命令
```
    #git初始化
    git init
    #创建hexo分支，用来存放源码
    git checkout -b hexo
    #git 文件添加
    git add .
    #git 提交
    git commit -m "init"
    #添加远程仓库
    git remote add origin git@github.com:542869246/542869246.github.io.git
    #push到hexo分支
    git push origin hexo
```
4. 执行hexo d -g生成网站并部署到GitHub上

这样一来，在GitHub上的git@github.com:542869246/542869246.github.io.git仓库就有两个分支，一个hexo分支用来存放网站的原始文件，一个master分支用来存放生成的静态网页。

### 四、恢复

当重装电脑之后，或者想在其他电脑上修改博客，可以使用下列步骤：

*   1、先安装hexo  
    $ npm install -g hexo-cli
*   2、存在github上的git clone下来  
    git clone git@github.com:542869246/542869246.github.io.git
*   3、项目文件夹下npm  
    cd项目名/ npm install –no-bin-links  
    $ npm install hexo-deployer-git
*   4、重新配置github和coding的公钥

### 五、更新

每次写作之后,可以使用下列步骤：
```
hexo d#生成网站并部署到GitHub上
git add .
git commit -m 'update'
git push origin hexo
```
