---
title: Hexo-Next搭建个人博客（集成Algolia站内搜索引擎）
date: 2018-08-08 08:53:22
tags: [Hexo,Next]
categories: Hexo
top: 95
image: http://pic1.win4000.com/wallpaper/2018-07-13/5b4852cedba44.jpg
description: 起因Swiftype现在收费了，也没有免费版本。Local Search搜索体验不好，微搜索Next官网上描述太少！所以选择Algolia。 注：Algolia搜索在版本5.1.0中引入，要使用此功能请确保所使用的 NexT 版本在此之后
---
<span>
<!--more-->
起因Swiftype现在收费了，也没有免费版本。Local Search搜索体验不好，微搜索Next官网上描述太少！所以选择Algolia。 注：Algolia搜索在版本** 5.1.0 **中引入，要使用此功能请确保所使用的 NexT 版本在此之后


首先注册Algolia账户
-------------

[Algolia 登陆页面https://www.algolia.com/users/sign_in](https://link.juejin.im?target=https%3A%2F%2Fwww.algolia.com%2Fusers%2Fsign_in) ，可以使用 GitHub 或者 Google 账户直接登录，也可以注册一个新账户。我直接用谷歌账户登陆了，注册后的 14 天内拥有所有功能（包括收费类别的）。之后若未续费会自动降级为免费账户，免费账户 总共有 10,000 条记录，每月有 100,000 的可以操作数。

注册完成后，创建一个新的 Index，这个 index name 之后会用到
![](https://upload-images.jianshu.io/upload_images/3899681-c00f0825ef763c9e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

Index 创建完成后，此时这个 Index 里未包含任何数据。 接下来需要安装 Hexo Algolia 扩展， 这个扩展的功能是搜集站点的内容并通过 API 发送给 Algolia。前往站点根目录，执行命令安装：
```
npm install hexo-algolia --save  # 目前最新版本是1.2.5，下面的操作都是基于这个版本的文档
```

获取 Key，更新站点根目录配置
----------------

![](http://www.qingpingshan.com/uploads/allimg/180511/1440043942-0.png)

前往站点根目录打开_config.yml添加以下代码
```
# Algolia Search API Key
algolia:
  applicationID: '你的Application ID'
  apiKey: '你的Search-Only API Key'
  adminApiKey: '你的Admin API Key'
  indexName: '输入刚才创建index name'
  chunkSize: 5000
```
修改Algolia搜索ACL（访问控制列表）
----------------------

![](http://www.qingpingshan.com/uploads/allimg/180511/1440041313-1.png)

选中后保存。

操作完成后去你的博客跟路径执行命令
---------

```
set HEXO_ALGOLIA_INDEXING_KEY=你的Search-Only API Key
```

查看是否设置成功如果没有值就设置失败
```
hexo clean
hexo algolia
```
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/algolia02.png)

成功后修改Next主题配置文件
---------------

更改Next主题配置文件，找到 Algolia Search 配置部分：
```
# Algolia Search
algolia_search:
  enable: true
  hits:
    per_page: 10
  labels:
    input_placeholder: 输入关键字
    hits_empty: "没有找到与 ${query} 相关的内容"
    hits_stats: "${hits}条相关记录，共耗时${time} ms"
```
将 enable 改为 true 即可，根据需要你可以调整 labels 中的文本。这个是我修改的文本。

最终效果

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/algolia01.png)

总结一下集成遇到的BUG
------------

###### Please set an `HEXO_ALGOLIA_INDEXING_KEY` environment variable to enable content indexing.


![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/algolia04.png)

原因：Algolia Search API Key indexName 错了

解决方案：看下之前新建index的名字


###### Not enough rights to update an object near line:1 column:1635


![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/algolia03.png)

原因：没有修改Algolia搜索ACL（访问控制列表）

解决方案： 按步骤3勾选上就可以


### 参考
*   [《hexo+next添加algolia搜索》](https://www.jianshu.com/p/fa2354d61e37 "hexo+next添加algolia搜索")



### 帮助文档
*   [《hexo-algolia》](https://www.npmjs.com/package/hexo-algolia "《hexo-algolia》")

更多教程可以来我[yufeng.Zhou](http://yfzhou.coding.me/)独立博客里面看到
---------------------------------------------------

**转载请注明出处[http://yfzhou.coding.me/](http://yfzhou.coding.me/)**


