---
title: Hexo-Next搭建个人博客（托管到Github和Coding）
date: 2018-08-07 22:55:27
tags: [Hexo,Next]
categories: Hexo
top: 95
image: http://pic1.win4000.com/wallpaper/2018-05-03/5aeabbe179a97.jpg
description: 这是一篇很详细的独立博客搭建教程，意在帮助小白们能快速入门，拥有自己的独立博客
---

<span>
<!-- more-->
前言
--

这是一篇很详细的独立博客搭建教程，意在帮助小白们能快速入门，拥有自己的独立博客。作者已在window平台已搭建成功，博客效果请点[链接](https://yfzhou.coding.me/)查看。  

### 为什么用Hexo搭建独立博客？

Hexo 是一个快速、简洁且高效的博客框架。Hexo 使用 Markdown（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页。



### Github和Coding又是什么？

*   Github是国外免费的Git代码托管平台。利用Github Page服务可以免费创建一个静态网站。
*   Coding则是国内Git代码托管平台。国内首个Git代码托管平台GitCafe已被Coding收购。也提供page服务。

![GitCafe](http://7xs5l8.com1.z0.glb.clouddn.com/02.png)

### 为什么用两个代码托管平台？

很多人都把hexo托管到github上，因为github大家都用的比较久了。但是，你的博客主要访问者肯定还是国内的用户，国内的用户访问coding比github是要快不少的。还可以利用域名解析实现国内的走coding，海外的走github，分流网站的访问。

步骤
--

### 安装Git

<div class="note info"><p>Git是什么？  
Git是目前世界上最先进的分布式版本控制系统（没有之一）。  
了解更多，参考[git教程](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)</p></span>

*   [点击下载](https://git-for-windows.github.io/)，然后按默认选项安装即可。![Bash](http://7xs5l8.com1.z0.glb.clouddn.com/00.png)
*   安装完成后，在开始菜单里找到“Git”->“Git Bash”，蹦出一个类似命令行窗口的东西，就说明Git安装成功！

![命令窗口](http://7xs5l8.com1.z0.glb.clouddn.com/0.jpg)

*   安装完成后，还需要最后一步设置，在命令行输入
```
    $ git config --global user.name "Your Name"
    $ git config --global user.email "email@example.com"
```
因为Git是分布式版本控制系统，所以，每个机器都必须自报家门：你的名字和Email地址。

**注意**`git config`命令的`--global`参数，用了这个参数，表示你这台机器上所有的Git仓库都会使用这个配置，当然也可以对某个仓库指定不同的用户名和Email地址。


### 将博客托管到Github和Coding上

#### 托管到github

*   注册github帐号  
    访问[官网](https://github.com/)注册,你的username和邮箱十分重要，GitHub上很多通知都是通过邮箱的。比如你的主页上传并构建成功会通过邮箱通知，更重要的是，如果构建失败的话也会在邮件中说明原因。
*   创建项目仓库  
    注册并登陆Github官网成功后，点击页面右上角的+，选择New repository。  
    ![+](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan20163281.png)  
    在Repository name中填写Github账号名.github.io  
    ![创建仓库](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE02.png)  
    点击Create repository，完成创建。

#### 托管到coding

*   注册coding帐号  
    访问[官网](https://coding.net/)注册并登录
*   创建仓库  
    点+创建项目  
    ![+](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE04.png)  
    填写项目名称描述创建即可,  
    ![创建](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan1637925-3cbdade49c4ed7ba.png)

#### 配置SHH

配置shh key是让本地git项目与远程的github建立联系  
* 检查是否已经有SSH Key，打开Git Bash，输入
```
    cd ~/.ssh
```
*   如果没有.ssh这个目录，则生成一个新的SSH，输入
```
    ssh-keygen -t rsa -C "your e-mail"
```
注意1: 此处的邮箱地址，你可以输入自己的邮箱地址；注意2: 此处的「-C」的是大写的「C」  
* 接下来几步都直接按回车键,然后系统会要你输入密码
```
    Enter passphrase (empty for no passphrase):<输入加密串>
    Enter same passphrase again:<再次输入加密串>
```
这个密码会在你提交项目时使用，如果为空的话提交项目时则不用输入。这个设置是防止别人往你的项目里提交内容。  
注意：输入密码的时候没有*字样的，你直接输入就可以了。  
* 最后看到这样的界面，就成功设置ssh key了  
![ssh key](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhanssh%20key.jpg)

#### 添加 SSH Key 到 GitHub和Coding

*   打开Git Bash，然后输入
```
    cd ~/.ssh
```
*   进入到.shh文件夹中再输入ls，查看是否有id_rsa.pub文件  
    ![](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE05.png)
*   输入cat命令，打开id_rsa.pub文件
```
    cat id_rsa.pub
```
![](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE06.png)  
* 再鼠标全选中右击复制  
* 再配置到GitHub和Coding的SSH中  
进入Github官网，点击+旁边的头像，再按settings进入设置  
![](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE07.png)  
在点击New SSH key创建  
![](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE08.png)  
title输入邮箱，key里面粘贴刚才右击复制的内容,再点Add SSH key  
![](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE10.png)  
同样进入coding,点击账户，在点SSH公钥设置即可  
![](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE11.png)

#### 测试SSH是否配置成功

*   打开Git Bash，然后输入
```
    ssh -T git@github.com
```
*   如配置了密码则要输入密码,输完按回车  
    如果显示以下内容，则说明Github中的ssh配置成功。
```
    Hi username! You've successfully authenticated, but GitHub does not
    provide shell access.
```
*   再输入
```
    ssh -T git@git.coding.net
```
如果显示以下则说明coding中的ssh配置成功
```
    Hello username You've connected to Coding.net by SSH successfully!
```
#### 创建Github Pages和Coding Pages 服务

*   GitHub Pages分两种，一种是你的GitHub用户名建立的username.github.io这样的用户&组织页（站），另一种是依附项目的pages。想建立个人博客是用的第一种，形如cnfeat.github.io这样的可访问的站，每个用户名下面只能建立一个。[更多](https://help.github.com/articles/user-organization-and-project-pages/)
*   官网点击代码再点击Coding Pages 服务开启。分支和github分支写一样，填写master  
    ![](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE13.png)

#### 将博客网站上传到GitHub和Coding中

*   打开D:\\blog文件夹中的_config.yml文件，找到如下位置，填写

```
    # Deployment
    ## Docs: https://hexo.io/docs/deployment.html
    deploy:
      type: git
      repo:
          github: git@github.com:yourname/yourname.github.io.git,master
          coding: git@git.coding.net:yourname/yourname.git,master
```

**注：** (1) 其中yourname替换成你的Github账户名;(2)注意在yml文件中，:后面都是要带空格的。  
![](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan%E6%88%AA%E5%9B%BE14.png)  
* 在**blog文件夹**中空白处右击打开Git Bash输入
```
    npm install hexo-deployer-git --save
    hexo g #生成静态网页
    hexo d #开始部署
```
此时，通过访问[http://yourname.github.io](http://yourname.github.io)和http://yourname.coding.me可以看到默认的Hexo首页面（与之前本地测试时一样）。

#### 更换Hexo主题

本网站使用的是Next主题。该主题简洁易用，在移动端也表现不错。  
* 下载主题  
在**blog文件夹**中空白处右击打开Git Bash输入
```
    git clone https://github.com/iissnan/hexo-theme-next themes/next
```
*   修改网站的主题为Next  
    打开D:\\blog下的_config.yml文件，找到theme字段，将其修改为next
```
    # Extensions
    ## Plugins: http://hexo.io/plugins/
    ## Themes: http://hexo.io/themes/
    theme: next
```
*   验证主题是否可用  
    输入
```
    hexo s #启动服务，调试用
```
再在浏览器输入[http://localhost:4000/](http://localhost:4000/)确认网站主题是否切换为Next.  
* 博客blog根目录下的_config.yml配置网站信息  
_config.yml配置请点[参考](https://github.com/xirong/hexo-theme-next/blob/master/_config_root.yml)

### 注册及绑定自己的域名地址

#### 域名注册

推荐选择国内的万网或者国外的Goddady进行域名的注册，注册完还需改下绑定DNS服务商

#### 域名解析

如果你选择的是万网注册的域名，可以使用其自带的域名解析服务。  
也可以选择免费的[DNSPod](https://www.dnspod.cn/)  
* 域名解析填写如下图  
![](http://7xs5l8.com1.z0.glb.clouddn.com/wangzhan1637925-bc9fbfb9af5e3b77.png)  
* 打开blog文件夹下的source文件夹，新建CNAME文件,内容填写自己的域名  
CNAME文件设置的目的是，通过访问 yourname.github.io 可以跳转到你所注册的域名上。  
github是直接项目里面加CNAME文件。coding是直接在项目主页设置的，去coding项目主页添加CNAME，绑定域名。

总结
--

只要按照上面步骤一步步设置，相信你也可以拥有自己的独立博客。希望此文对还在搭建hexo独立博客的小伙伴有所帮助。主题相关配置查看下面的，hexo和next帮助文档。

### 参考

*   [《Hexo+Github: 搭建属于自己的静态博客》](http://www.jeyzhang.com/hexo-github-blog-building.html)
*   [《hexo你的博客》](http://ibruce.info/2013/11/22/hexo-your-blog/?utm_source=tuicool)
*   [《如何使用10个小时搭建出个人域名而又Geek的独立博客？》](http://blog.shijinrong.cn/2016/01/03/2016-01-03-how-to-build-blog/)
*   [《将hexo博客同时托管到github和coding》](http://tengj.top/2016/03/06/hexo%E5%B9%B2%E8%B4%A7%E7%B3%BB%E5%88%97%EF%BC%9A%EF%BC%88%E5%9B%9B%EF%BC%89%E5%B0%86hexo%E5%8D%9A%E5%AE%A2%E5%90%8C%E6%97%B6%E6%89%98%E7%AE%A1%E5%88%B0github%E5%92%8Ccoding/)
*   [《个人域名如何同时绑定 github 和 coding 上的博客》](https://segmentfault.com/q/1010000004557073?_ea=651524)
*   [《如何搭建一个独立博客——简明Github Pages与Hexo教程》](http://blog.csdn.net/poem_of_sunshine/article/details/29369785/)
*   [《「搭建Hexo博客」简明教程》](http://mousycoder.com/2015/10/19/classic-tutorial-of-hexo-blog/)
*   [《使用 github Pages 服务建立 ixirong.com 独立博客全过程》](http://www.ixirong.com/2015/05/17/how-to-build-ixirong-blog/)
*   [深山老猿](http://shenshanlaoyuan.com/)

### 帮助文档

*   [《Hexo文档》](https://hexo.io/zh-cn/docs/)
*   [《Next使用文档》](http://theme-next.iissnan.com/getting-started.html)
*   [《Git教程》](http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000)
*   [《Github帮助文档》](https://help.github.com/)
*   [《Coding帮助文档》](https://coding.net/help/)
*   [《Markdown 语法说明》](http://wowubuntu.com/markdown/)

更多教程可以来我[yufeng.Zhou](http://yfzhou.coding.me/)独立博客里面看到
---------------------------------------------------

**转载请注明出处[http://yfzhou.coding.me/](http://yfzhou.coding.me/)**
