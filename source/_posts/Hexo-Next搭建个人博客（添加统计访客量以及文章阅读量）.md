---
title: Hexo-Next搭建个人博客（添加统计访客量以及文章阅读量）
date: 2018-08-08 09:04:37
tags: [Hexo,Next]
categories: Hexo
top: 95
image: http://pic1.win4000.com/wallpaper/2018-05-03/5aeabbdfa04be.jpg
description: 使用不蒜子和Lean Cloud给文章添加阅读量和统计访客功能
---



<span>
<!--more-->

## 不蒜子统计功能

NexT主题集成了不蒜子统计功能,以下为我的配置
```
# Show PV/UV of the website/page with busuanzi.
# Get more information on http://ibruce.info/2015/04/04/busuanzi/
busuanzi_count:
  # count values only if the other configs are false
  enable: true
  # custom uv span for the whole site
  site_uv: true
  site_uv_header: <i class="fa fa-user"></i>
  site_uv_footer: 人次
  # custom pv span for the whole site
  site_pv: true
  site_pv_header: <i class="fa fa-eye"></i>
  site_pv_footer: 次
  # custom pv span for one page only
  page_pv: true
  page_pv_header: <i class="fa fa-file-o"></i>
  page_pv_footer: 次
```
当`enable: true`时，代表开启全局开关。若s`ite_uv、site_pv、page_pv`的值均为`false`时，不蒜子仅作记录而不会在页面上显示。 
当`site_uv: true`时，代表在页面底部显示站点的UV值。 
当`site_pv: true`时，代表在页面底部显示站点的PV值。 
当`page_pv: true`时，代表在文章页面的标题下显示该页面的PV值（阅读数）。 
`site_uv_header`和`site_uv_footer`这几个为自定义样式配置，相关的值留空时将不显示，可以使用（带特效的）font-awesome。 

<div class="note success"><p>[2018/9/19] 更新</p></div>

Next主题已经更新至6.X版本,不蒜子统计插件配置有变化



```yml 文件：主题配置文件_config.yml
# Show Views/Visitors of the website/page with busuanzi.
# Get more information on http://ibruce.info/2015/04/04/busuanzi/
busuanzi_count:
  enable: true
  total_visitors: true
  total_visitors_icon: user
  total_views: true
  total_views_icon: eye
  post_views: false
  post_views_icon: eye
```
<hr/>

效果图：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/read02.png)
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/read01.png)


## LeanCloud阅读次数统计

<div class="note success"><p>[2018/9/19] 更新</p></div>

```cmd 安装
$ npm install hexo-symbols-count-time --save
```

```yml 文件：站点配置文件_config.yml
symbols_count_time:
  symbols: true
  time: true
  total_symbols: true
  total_time: true
```

```yml 文件：主题配置文件_config.yml
symbols_count_time:
  separated_meta: true
  item_text_post: true
  item_text_total: true
  awl: 4 # 平均单词长度（单词的计数）。默认值:4。CN≈2 EN≈5 俄文≈6
  wpm: 275 # 每分钟的单词。默认值:275。缓慢≈200 正常≈275 快≈350
```
更多请[点击这里](http://theme-next.iissnan.com/third-party-services.html#share-system)
next升级6.X后，页面LeanCloud访问统计提示`Counter not initialized! See more at console err msg.`的问题，请查看[《Leancloud访客统计插件重大安全漏洞修复指南》](https://leaferx.online/2018/02/11/lc-security/#5acc7b329f54542bb2384a7e)

<hr/>

首先一句话介绍Lean Cloud:

> [LeanCloud](https://leancloud.cn/)（aka. AVOS Cloud）提供一站式后端云服务，从数据存储、实时聊天、消息推送到移动统计，涵盖应用开发的多方面后端需求。

相比不蒜子的统计，LeanCloud的文章阅读量统计更加稳定靠谱，所以本人也把网站的文章内统计改为LeanCloud的了。

### [](#配置LeanCloud "配置LeanCloud")配置[LeanCloud](https://leancloud.cn)

在注册完成LeanCloud帐号并验证邮箱之后，我们就可以登录我们的LeanCloud帐号，进行一番配置之后拿到`AppID`以及`AppKey`这两个参数即可正常使用文章阅读量统计的功能了。

#### [](#创建应用 "创建应用")创建应用

*   我们新建一个应用来专门进行博客的访问统计的数据操作。首先，打开控制台，如下图所示：

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/open_consoloe.png "打开控制台")

*   在出现的界面点击`创建应用`：

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/create_app.png "创建应用")

*   在接下来的页面，新建的应用名称我们可以随意输入，即便是输入的不满意我们后续也是可以更改的:

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/creating_app.png "创建的新应用名称")

*   这里为了演示的方便，我新创建一个取名为test的应用。创建完成之后我们点击新创建的应用的名字来进行该应用的参数配置：

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/create_class.png "打开应用参数配置界面")

*   在应用的数据配置界面，左侧下划线开头的都是系统预定义好的表，为了便于区分我们新建一张表来保存我们的数据。点击左侧右上角的齿轮图标，新建Class：  
    在弹出的选项中选择`创建Class`来新建Class用来专门保存我们博客的文章访问量等数据:  
    点击`创建Class`之后，理论上来说名字可以随意取名，只要你交互代码做相应的更改即可，但是为了保证我们前面对NexT主题的修改兼容，此处的**新建Class名字必须为`Counter`**:

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/creating_class.png "权限配置")

*   由于LeanCloud升级了默认的ACL权限，如果你想避免后续因为权限的问题导致次数统计显示不正常，建议在此处选择`无限制`。

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/open_app_key.png "打开应用设置")

创建完成之后，左侧数据栏应该会多出一栏名为`Counter`的栏目，这个时候我们点击顶部的设置，切换到test应用的操作界面:  
在弹出的界面中，选择左侧的`应用Key`选项，即可发现我们创建应用的`AppID`以及`AppKey`，有了它，我们就有权限能够通过主题中配置好的Javascript代码与这个应用的Counter表进行数据存取操作了:

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/opened_app_key.png "获取Appid、Appkey")

复制`AppID`以及`AppKey`并在NexT主题的`_config.yml`文件中我们相应的位置填入即可，正确配置之后文件内容像这个样子:

```
leancloud_visitors:  
 enable: true  
 app_id: joaeuuc4hsqudUUwx4gIvGF6-gzGzoHsz  
 app_key: E9UJsJpw1omCHuS22PdSpKoh  
```
这个时候重新生成部署Hexo博客，应该就可以正常使用文章阅读量统计的功能了。需要特别说明的是：记录文章访问量的唯一标识符是文章的`发布日期`以及`文章的标题`，因此请确保这两个数值组合的唯一性，如果你更改了这两个数值，会造成文章阅读数值的清零重计。

### [](#后台管理 "后台管理")后台管理

当你配置部分完成之后，初始的文章统计量显示为0，但是这个时候我们LeanCloud对应的应用的`Counter`表中并没有相应的记录，只是单纯的显示为0而已，当博客文章在配置好阅读量统计服务之后第一次打开时，便会自动向服务器发送数据来创建一条数据，该数据会被记录在对应的应用的`Counter`表中。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/read03.png "后台管理")

我们可以修改其中的`time`字段的数值来达到修改某一篇文章的访问量的目的（博客文章访问量快递提升人气的装逼利器）。双击具体的数值，修改之后回车即可保存。

*   `url`字段被当作唯一`ID`来使用，因此如果你不知道带来的后果的话请不要修改。
*   `title`字段显示的是博客文章的标题，用于后台管理的时候区分文章之用，没有什么实际作用。
*   其他字段皆为自动生成，具体作用请查阅LeanCloud官方文档，如果你不知道有什么作用请不要随意修改。

### [](#Web安全 "Web安全")Web安全

因为AppID以及AppKey是暴露在外的，因此如果一些别用用心之人知道了之后用于其它目的是得不偿失的，为了确保只用于我们自己的博客，建议开启Web安全选项，这样就只能通过我们自己的域名才有权访问后台的数据了，可以进一步提升安全性。

选择应用的设置的`安全中心`选项卡:

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/open_safe_center.png "进入安全中心")

在`Web 安全域名`中填入我们自己的博客域名，来确保数据调用的安全:

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/bind_domain.png "锁定域名")

如果你不知道怎么填写安全域名而或者填写完成之后发现博客文章访问量显示不正常，打开浏览器调试模式，发现如下图的输出:

![](http://7xkj6q.com1.z0.glb.clouddn.com/static/images/leancloud-page-anlysis/broswer_403.png "Web安全域名填写错误")

这说明你的安全域名填写错误，导致服务器拒绝了数据交互的请求，你可以更改为正确的安全域名或者你不知道如何修改请在本博文中留言或者放弃设置Web安全域名。



