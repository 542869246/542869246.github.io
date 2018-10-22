---
title: Idea开发环境中搭建Maven并且使用Maven打包部署程序
date: 2018-10-16 17:27:10
copyright: true
top: 95
categories: [java]
tags: [Idea,maven,java]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684049139_15.png
description: 
---
<span></span>

<!--more-->
<div class="note info no-icon"><p>作者：怪才
来源：www.cnblogs.com/hanyinglong
</p></div>

### 1.配置Maven的环境变量

a.首先我们去maven官网下载Maven程序，解压到安装目录，如图所示:

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684037598_0.png)

b.配置M2_HOME的环境变量，然后将该变量添加到Path中  

> 备注：必须要有JAVA\_HOME的M2\_HOME环境变量，不然Maven会提示错误。配置环境变量如图所示：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684038281_1.png)

c.如果想要修改Maven的本地仓库位置，则可以直接在Maven的安装目录下找到conf文件下的setting配置文件中，设置localRepository为本地仓库位置`<localRepository>E:\java\repo</localRepository>`

d.重新打开命令提示符cmd(管理员)，输入mvn --version ，如图所示，则说明安装成功  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684038925_2.png)

### 2.Idea开发环境中搭建Maven

a.当配置完Maven之后，我们需要给Idea配置Maven，那么首先必须先要安装Idea，Idea的安装在这里就不累赘了，请自行百度，非常简单，下一步下一步即可，安装完成之后打开Idea设置Maven，如图所示：  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684039612_3.png)

b.单击Setting之后，设置Maven节点下的Maven home directory和user settings file和local repository  

如图所示：  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684040330_4.png)

到这里我们整个Idea配置Maven就完成了，下面来说使用Maven开发JavaWeb项目以及使用Maven打包。  

### 3.使用Maven开发JavaWeb项目(Idea14)

a.通过上面的步骤我们便给Idea配置好了Maven环境，那么这时候我们更愿意创建Maven管理的Java Web项目，如何创建呢？

b.单击File->New Project->选择Maven,如图所示：  
选中Createfrom archetype，选择maven-archetype-webapp  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684041208_5.png)

c.单击Next，如图所示：填写GroupId和ArtifactId和Version  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684042087_6.png)

d.单击Next，如图所示：此页面获取的是maven的安装信息  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684042784_7.png)

e.单击Next，如图所示：填写项目名称和项目存放的路劲  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684043486_8.png)

f.单击 Finish完成，即创建Maven项目成功，如图所示：  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684044109_9.png)

g.如果单击完成在下面的提示中报错，出现问题的可能性是Maven和Idea的兼容性问题，建议将Maven换成低版本的即可。报错如图所示：  

> 备注：当改变Maven版本的时候，必须改变环境变量和Idea中的设置才可以。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684044787_10.png)

### 4.使用Maven打包JavaWeb项目

a.通过以上步骤即安装了Maven和开发了一个Maven的JavaWeb项目，那么接下来就需要将JavaWeb打包(war文件)发布到Tomcat下，如何打包呢？

b.在Idea中的最右边的导航栏中可以看到一个Maven Projects，单击打开，如图所示：  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684045521_11.png)

  

图一

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684046164_12.png)

图二

c.接下来我们就能够利用这个简单的工具对Maven进行打包(war)。  

d.如图2所示，当单击Run Maven Build的时候，出现错误，如图所示：  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684046875_13.png)

e.出现以上错误之后，按照下面的步骤解决，单击File->Setting->在搜索框中输入Maven回车直接定位到Maven节点->Runner,打开之后将这段内容  

> -Dmaven.multiModuleProjectDirectory=$M2_HOME）

复制到VM Options的文本框中，单击OK即可。

f.按照图2所示，我们再次运行，发现不会报错，并且输入了一些内容，证明已可以打包程序。

g.选择install右键选择Run运行即可，运行完成之后则会提示你打包的war包在哪里，如图所示　　  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1539684047718_14.png)

h.然后找到war包,复制到Tomcat的WebApps文件夹下面，然后直接访问网站即可访问。  