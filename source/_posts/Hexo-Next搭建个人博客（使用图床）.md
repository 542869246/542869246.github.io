---
title: Hexo-Next搭建个人博客（使用图床）
copyright: true
top: 95
date: 2018-08-17 11:07:26
tags: [Hexo,Next]
categories: Hexo
image: http://pic1.win4000.com/wallpaper/2017-12-08/5a29fbea5d068.png
---


图片作为互联网服务中最基础的资源之一，随着互联网基础服务越来越专业化，图片的存储、处理、分发也发展成了一项独立的基础服务。试想一下，如果每家互联网公司都要花费大量人力物力去做图片相关的技术研发，哪还有时间去做自己的业务。专业的事情还是要交给专业的人来做。
<!--more-->

图床，也就是专门提供存储图片的地方，我们只要通过图床提供的 API 接口，把图片上传上去，就可以通过外链访问了，根本不用操心图片是怎么存的，硬盘空间不够了，硬盘坏了，访问速度比较慢等等问题，这些图床都会帮我们搞定，他们会用各种技术帮我们做图片相关的优化和服务，比如多机互备、CDN 加速、图片处理、图片鉴黄、文本识别等等。

当然，图床也是有缺点的，当所有人都把图片存在同一个图床上，万一有一天图床真挂了，那所有图片就都无法访问了，虽然这种情况的概率很低，但并不等于不会发生。我就经历过云服务商机房被雷劈，网站都挂掉的情况。支付宝光缆不也被挖断过吗？不过，对于我们个人用户来说，要求也没那么高，图床已经完全能满足我们的需求了。

* * *

目前图床可以分为两种，一种是公共图床，一种是自建图床。公共图床也就是利用公共服务的图片上传接口，来提供图片外链的服务，比如新浪微博。自建图床，也就是利用各大云服务商提供的存储空间或者自己在 VPS 上使用开源软件来搭建图床，存储图片，生成外链提供访问，比如七牛、Lychee 开源自建图床方案。  

公共图床
----

### 微博图床

由于微博本身就是面向公众提供服务，每个人发微博基本都得带上几张图片，以微博的体量，每天的新增图片数也不是个小数字。但是微博对于图片上传服务也没有接口说明文档，上传的接口还是在开发者们从微博产品里找出来的，可能微博只希望上传的图片仅仅用于微博产品本身吧。

微博图床的特点是免费，没有容量限制，全网 CDN 加速，支持 HTTPS，到哪里都很快。但是免费的服务也有不足的地方，上传的图片会被转成 jpg，图片中可能加上了肉眼难以识别的水印，另外微博的图片鉴别服务也可能会随时删除你的图片。

相关链接：

*   [微博图床上传地址](http://weibo.com/minipublish)：从这里直接上传图片比较麻烦，你可以使用下面介绍的一些图床工具，上传起来更方便。  
    
*   [微博图床 API](http://picupload.service.weibo.com/interface/)：用浏览器当然是不能访问的，只提供图片上传。  
    

### Imgur 图床

![Imgur API](https://cdn.sspai.com/2017/08/21/7d56369618ca55b7788a1f2b2469e274.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

Imgur API

[Imgur](https://imgur.com/) 是一家国外老牌的图片存储服务商，国外速度很快，口碑不错，支持 HTTPS。但是国内速度很不稳定，所以追求国内速度的同学慎用。

相关链接：

*   [Imgur API](https://apidocs.imgur.com/)  
    

### SM.MS 图床

![sm.ms 图床](https://cdn.sspai.com/2017/08/21/a78e40318ea02f94a0b9e2ea19d8b10e.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

sm.ms 图床

[SM.MS](https://sm.ms/) 是由 V2EX @[Showfom](https://www.v2ex.com/member/Showfom) 自建的，无外链限制，无流量限制的图床，支持 HTTPS，速度不错，已经运行两年多了。

相关链接：

*   [sm.ms API](https://sm.ms/doc/)  
    

其它公共图床还有很多，一搜一大把，不过大部分规模都比较小，要不就是国内访问速度不理想，使用前最好先了解一下。

* * *

目前自建图床方案有两种，一种是利用云服务商提供的存储服务来作为图床，通过 API 来管理图片，另一种是在 VPS 上安装开源的图片或文件管理程序，只要能提供外链，基本都可以作为图床来用。

自建图床：云服务
--------

### 七牛

![七牛云](https://cdn.sspai.com/2017/08/21/2242e610efb14f6d63261547f3e90609.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

七牛云

[七牛](https://portal.qiniu.com/signup?code=3lmd5t4axez4i) 作为国内领先的云服务商，全网 CDN 加速，全国访问速度都不错，API 很详细，对开发者比较友好。免费用户提供 10GB 存储空间，国内和海外分别提供 10 GB 的 HTTP 免费流量，七牛的 HTTPS 流量是收费的，没有免费额度。此外，七牛还提供了针对图片的各种服务，包括图片裁剪，压缩，鉴黄等等衍生服务。如果你觉得图片尺寸太大，可以在外链后面添加参数，访问的时候七牛会自动根据你的参数对图片进行处理。

目前我的图片都存在七牛上，使用 HTTPS 外链，每个月支出也就几块钱，就为了博客上那个小绿锁 😆。

相关链接：

*   [七牛云 API 文档](https://developer.qiniu.com/)  
    
*   [七牛价格](https://www.qiniu.com/prices)  
    

### 又拍云

![又拍云](https://cdn.sspai.com/2017/08/21/9f1b5842c3ab1b8bc29e5fdbce49a972.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

又拍云

[又拍云](https://www.upyun.com/) 也算是国内比较有名的云服务商了，国内拥有 200+ 的自建 CDN 节点，国内速度也不错，API 很详细，不过对于普通用户没有免费额度，目前实行的是「按照用户每日实际消耗的 CDN 流量，实行 1:1 的存储空间费免费使用」。

相关链接：

*   [又拍云 API 文档](http://docs.upyun.com/guide/#api)  
    
*   [又拍云价格](https://www.upyun.com/pricing)  
    

### 阿里云 OSS

![阿里云 OSS](https://cdn.sspai.com/2017/08/21/dea389e72df9a46289eaa24b3d88aee4.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

阿里云 OSS

[阿里云 OSS](https://www.aliyun.com/price/product#/oss/detail)（Object Storage Service），即阿里云对象存储服务，也可以作为图床，速度国内国外都不错，SDK 和 API 都很完善，收费也不算太贵，就是计费方案太复杂，目前费用包括：存储费用+流量费用+接口调用费用+数据处理，而且还分时段，地区，阶梯计费。可以选择包年包月和按量付费，具体价格和文档可以查看下面的官网介绍。

相关链接：

*   [阿里云 OSS 文档](https://promotion.aliyun.com/ntms/act/ossdoclist.html)  
    
*   [阿里云 OSS 价格](https://www.aliyun.com/price/product#/oss/detail)  
    

自建图床：开源方案
---------

如果你有 VPS，并且网络速度 OK 的话，自建图床也是一个不错的选择。

### Lychee

![Lychee](https://cdn.sspai.com/2017/08/21/5d4f0efa178487d54309f3da47d75e6e.jpeg?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

Lychee

[Lychee](https://github.com/electerious/Lychee) 是一个开源免费的基于 PHP 的图片管理系统，支持 Docker 部署，可以直接当做图床来用，Lychee 还支持很多扩展。

### 树洞外链

![树洞外链](https://cdn.sspai.com/2017/08/21/d916ed36a802e3e878e95d556bd64ef3.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

树洞外链

[树洞外链](https://yun.aoaoao.me/) 是一款免费开源的 PHP 外链网盘系统，界面简洁友好，支持七牛、本地、远程、阿里云OSS、又拍云五种储存方式，支持多用户系统，多上传方案策略。

相关链接：

*   [演示站点](https://file.aoaoao.me/)  
    

上传工具
----

对普通用户来说，直接使用图床 API 很麻烦，我们可以借助一些工具方便的上传图片，下面就根据 macOS、Windows、Web 分别推荐几款工具。

### iPic

![](https://cdn.sspai.com/attachment/origin/2016/07/04/336030.png)

#### iPic

Mac

[相关文章](https://sspai.com/app/iPic)

下载

*   [Mac](https://itunes.apple.com/cn/app/ipic-tu-chuang-shen-qi/id1101244278?mt=12&uo=4&at=10lJSw&ct=appcards)

  

[iPic](https://itunes.apple.com/cn/app/id1101244278?ls=1&mt=12) 是 macOS 上口碑最好的图床工具，支持 微博图床、七牛、阿里云 OSS、又拍云、Imgur、Flickr 等常见图床，支持拖拽、快捷键、剪贴板上传，支持上传前压缩，上传完毕自动生成 Markdown 并拷贝到剪贴板。如果你想迁移图床，开发者 [@jason](https://slarker.me/image-oss/toolinbox.net) 还做了一款 [图床迁移工具 iPic Mover](https://toolinbox.net/iPic/iPicMover.html) 来帮助你。此外，简洁优雅的 Markdown 工具 [Typora](https://typora.io/)也内嵌了 iPic 的上传服务，如果你也使用 Typora 的话，能感觉到这俩工具简直是绝配。

### MWeb

![](https://cdn.sspai.com/attachment/origin/2017/01/23/364951.png)

#### MWeb

iOS

[相关文章](https://sspai.com/app/MWeb)

下载

*   [iOS 通用](https://itunes.apple.com/cn/app/mweb-pro-markdown-writing/id1183407767?mt=8&uo=4&at=10lJSw&ct=appcards)
*   [Mac](https://itunes.apple.com/cn/app/mweb-zhuan-ye-demarkdown-xie/id954188948?mt=12&uo=4&at=10lJSw&ct=appcards)

  

![MWeb 中的图床支持](https://cdn.sspai.com/2017/08/21/a2229ac36e94260816e5423f5ceeba09.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

MWeb 中的图床支持

如果你只是码字的时候才用到图床，那可能 [MWeb](http://zh.mweb.im/) 也能满足你的需求，MWeb 支持七牛、imgur、Google Photos，还支持自定义图床，写作的时候只需要将图片拖进来，写作完成一键上传所有图片，也很方便。

### Dropzone 3

![](https://cdn.sspai.com/attachment/origin/2015/12/14/298954.png)

#### Dropzone 3

Mac

[相关文章](https://sspai.com/app/Dropzone 3)

下载

*   [Mac](https://itunes.apple.com/cn/app/dropzone-3/id695406827?mt=12&ign-mpt=uo%3D4&uo=4&at=10lJSw&ct=appcards)

  

[Dropzone 3](https://itunes.apple.com/us/app/dropzone-3/id695406827?mt=12) 也可以通过 [七牛插件](https://kyleduo.com/) 来支持上传图片，和 MWeb 类似，具体教程可以看 [这里](https://blog.kyleduo.com/2017/02/27/qiniu-upload-for-dropzone/#more)。

### MPic

![MPic](https://cdn.sspai.com/2017/08/21/ff144a6f126b6e608b93b5ba06013e14.png?imageView2/2/w/1120/q/90/interlace/1/ignore-error/1)

MPic

[MPic](http://mpic.lzhaofu.cn/) 目测是 Windows 上唯一的图床工具了，目前只支持七牛，把图片拖拽到软件窗口中就能上传。

### Web

使用 Web 技术开发的图床工具一抓一大把，大部分都基于七牛和微博图床 API，这里就介绍两个体验不错的吧：

*   [极简图床](http://yotuku.cn/)：默认公共图床使用 sm.ms、微博图床，可以自定义支持七牛，界面简洁美观，支持 [Chrome 插件](https://chrome.google.com/webstore/detail/heebflcbemenefckkgfnnklbhdbdkagg)，注册后还可以同步上传历史。  
    
*   [微博图床 Chroem 扩展](https://chrome.google.com/webstore/detail/%E6%96%B0%E6%B5%AA%E5%BE%AE%E5%8D%9A%E5%9B%BE%E5%BA%8A/fdfdnfpdplfbbnemmmoklbfjbhecpnhf/reviews)：开源的图床工具，只支持微博图床，使用起来也很方便，可以批量上传，管理上传历史。  
    

### 脚本

如果你对上面推荐的产品不满意，并且你会折腾的话，可以使用这个脚本来完成图片上传：[Markdown 图片实用工具](https://github.com/tiann/markdown-img-upload)

该脚本使用 Python 版的七牛 SDK 来实现上传功能，你可以按照相关介绍，搭配 Alfred 来快速完成图片上传。

* * *

图床服务最重要的是稳定性，大厂的云服务也都比较有保障，大家只要考虑下价格和易用性就可以了。就我个人而言，我首先推荐七牛，它的价格比较厚道，免费用户也有一定额度，数据可以自己掌控，另外各大平台的图床工具也基本都支持，易用性很高。其次推荐微博图床，对于不是很重要的图片，都可以存到微博图床，毕竟流量存储都免费，速度也不错。至于图床工具，就看自己的喜好了，只要顺手就行。但是不论选择哪一个服务或者工具，我觉得首先要自己可以掌控数据。

总之，适合自己的才是最好的。如果你还有其它好用的工具或者图床服务，欢迎留言给我，我会补充进来。

* * *

[《图床神器》](http://mpic.lzhaofu.cn/)

[《小贱贱图床》](https://pic.xiaojianjian.net/)

[《SM.SMb》](https://sm.ms/)

[《嗯，图片就交给它了》](https://sspai.com/post/40499)
  

* * *