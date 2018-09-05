---
title: Hexo-Next搭建个人博客（集成DaoVoice在线联系功能）
date: 2018-08-08 08:56:39
tags: [Hexo,Next]
categories: Hexo
top: 95
image: http://pic1.win4000.com/wallpaper/2018-05-07/5aefff87ef7b9.jpg
description: 之前有访问过一些大佬的个人博客，里面有个在线联系功能，看着不错，所以也试着在自己的站点上接入了此功能。 
---
<span>
<!--more-->

[](#注册 "注册")注册
==============

首先在[DaoVoice](http://www.daovoice.io/)注册个账号，点击->[邀请码](http://dashboard.daovoice.io/get-started?invite_code=b3c7d22e)是`b3c7d22e`。  
[![pW5DRP.png](https://s1.ax1x.com/2018/01/21/pW5DRP.png)](https://s1.ax1x.com/2018/01/21/pW5DRP.png)

完成后，会得到一个`app_id`，后面会用到：  
[![appid](https://s1.ax1x.com/2018/01/21/pW5yM8.png)](https://s1.ax1x.com/2018/01/21/pW5yM8.png)

[](#修改head-swig "修改head.swig")修改head.swig
=========================================

修改`/themes/next/layout/_partials/head.swig`文件，添加内容如下：  

```
{% if theme.daovoice %}
  <script>
  (function(i,s,o,g,r,a,m){i["DaoVoiceObject"]=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;a.charset="utf-8";m.parentNode.insertBefore(a,m)})(window,document,"script",('https:' == document.location.protocol ? 'https:' : 'http:') + "//widget.daovoice.io/widget/0f81ff2f.js","daovoice")
  daovoice('init', {
      app_id: "{{theme.daovoice_app_id}}"
    });
  daovoice('update');
  </script>
{% endif %}
```
位置贴图：  
[![pWIwmF.md.png](https://s1.ax1x.com/2018/01/21/pWIwmF.md.png)](https://imgchr.com/i/pWIwmF)

[](#主题配置文件 "主题配置文件")主题配置文件
==========================

在`_config.yml`文件中添加内容：  

```
# Online contact 
daovoice: true
daovoice_app_id: 这里输入前面获取的app_id
```

[](#聊天窗口配置 "聊天窗口配置")聊天窗口配置
==========================

附上我的聊天窗口的颜色、位置等设置信息：  
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/daovoice01.png)

至此，网页的在线联系功能已经完成，重新`hexo d -g`上传GitHub后，页面上就能看到效果了。


效果图：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/daovoice02.png?x-oss-process=style/w200)

可以关注小程序接收回复消息，很方便

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/daovoice03.png?x-oss-process=style/w200)
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/daovoice04.png?x-oss-process=style/w200)

现在往右下角看看(～￣▽￣)～ ，欢迎撩我（滑稽）。

