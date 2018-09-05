---
title: Hexo-Next搭建个人博客（SEO优化）
copyright: true
top: 95
date: 2018-08-29 14:51:27
categories: Hexo
tags: [Hexo,Next]
image: http://img.zcool.cn/community/0117e2571b8b246ac72538120dd8a4.jpg@1280w_1l_2o_100sh.jpg
---


&nbsp;&nbsp;&nbsp;&nbsp;推广是一个烦人的事情啊喂，特别是对于我们搞技术的来说，可能就不擅长推广，那么怎么才能让别人知道我们呢，我们就要想办法让别人通过搜索就可以搜索到你博客的内容，给我们带来自然流量，这就需要seo优化,让我们的站点变得对搜索引擎友好。

<!--more-->

<br/>

<div class="note default"><p>SEO是由英文Search Engine Optimization缩写而来， 中文意译为“搜索引擎优化”。SEO是指通过站内优化比如网站结构调整、网站内容建设、网站代码优化等以及站外优化。</p></div>


## 让百度收录你的站点

我们首先要做的就是让各大搜索引擎收录你的站点，我们在刚建站的时候各个搜索引擎是没有收录我们网站的，在搜索引擎中输入`site:<域名>`,如果如下图所示就是说明我们的网站并没有被百度收录。我们可以直接点击下面的“网址提交”来提交我们的网站  
![查看站点是否被百度收录](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20180829151511.png)

### 验证网站所有权

登录百度站长平台：[http://zhanzhang.baidu.com](http://zhanzhang.baidu.com),只要有百度旗下的账号就可以登录，登录成功之后在站点管理中点击[添加网站](http://zhanzhang.baidu.com/site/siteadd)然后输入你的站点地址，建议输入的网站为www开头的，不要输入github.io的，因为github是不允许百度的spider爬取github上的内容的，所以如果想让你的站点被百度收录，只能使用自己购买的域名  
![百度站长添加网站](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20180829151735.png)  
在选择完网站的类型之后需要验证网站的所有权，验证网站所有权的方式有三种：文件验证。html标签验证和cname解析验证，使用哪一种方式都可以，都是比较简单的，**但是一定要注意，使用文件验证文件存放的位置需要放在source文件夹下，如果是html文件那么hexo就会将其编译，所以必须要加上的`layout:false`，这样就不会被hexo编译。（如果验证文件是txt格式的就不需要）**，其他两种方式也是很简单的，我个人推荐文件验证和cname验证，cname验证最为简单，只需加一条解析就好~  
![验证网站所有权](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20180829151710.png)

### 生成网站地图

我们需要使用npm自动生成网站的sitemap，然后将生成的sitemap提交到百度和其他搜索引擎

#### 安装sitemap插件
```
    npm install hexo-generator-sitemap --save     
    npm install hexo-generator-baidu-sitemap --save
```
#### 修改博客配置文件

在根目录配置文件中修改url为你的站点地址
```
    # URL
    ## If your site is put in a subdirectory, set url as 'http://yoursite.com/child' and root as '/child/'
    url: https://yfzhou.coding.me
    root: /
    permalink: :title.html
    permalink_defaults:
```
**执行完之后就会在网站根目录生成sitemap.xml文件和baidusitemap.xml文件**，可以通过[https://yfzhou.coding.me/baidusitemap.xml](https://yfzhou.coding.me/baidusitemap.xml),查看该文件是否生成，其中sitemap.xml文件是搜索引擎通用的文件，baidusitemap.xml是百度专用的sitemap文件。

### 向百度提交链接

然后我们就可以将我们生成的sitemap文件提交给百度，还是在百度站长平台，找到链接提交，这里我们可以看到有两种提交方式，自动提交和手动提交，自动提交又分为主动推送、自动推送和sitemap

<div class="note info"><p>如何选择链接提交方式  
1、主动推送：最为快速的提交方式，推荐您将站点当天新产出链接立即通过此方式推送给百度，以保证新链接可以及时被百度收录。  
2、自动推送：最为便捷的提交方式，请将自动推送的JS代码部署在站点的每一个页面源代码中，部署代码的页面在每次被浏览时，链接会被自动推送给百度。可以与主动推送配合使用。  
3、sitemap：您可以定期将网站链接放到sitemap中，然后将sitemap提交给百度。百度会周期性的抓取检查您提交的sitemap，对其中的链接进行处理，但收录速度慢于主动推送。  
4、手动提交：一次性提交链接给百度，可以使用此种方式。</p></div>

一般主动提交比手动提交效果好，这里介绍主动提交的三种方法  
从效率上来说：

<div class="note default"><p>**主动推送>自动推送>sitemap**</p></div>

![连接提交](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20180829152039.png)

#### 主动推送

安装插件`npm install hexo-baidu-url-submit --save`  
然后再根目录的配置文件中新增字段
```
    baidu_url_submit:
      count: 100 # 提交最新的一个链接
      host: https://yfzhou.coding.me # 在百度站长平台中注册的域名
      token: 8OGYpxowYnhgVsUM # 请注意这是您的秘钥， 所以请不要把博客源代码发布在公众仓库里!
      path: baidu_urls.txt # 文本文档的地址， 新链接会保存在此文本文档里
```
在加入新的deploye
```
deploy:
- type:baidu_url_submitter
```
这样执行`hexo deploy`的时候，新的链接就会被推送了

#### 设置自动推送

在主题配置文件下设置,将baidu_push设置为true：
```
    # Enable baidu push so that the blog will push the url to baidu automatically which is very helpful for SEO
    baidu_push: true
```
然后就会将一下代码自动推送到百度，位置是themes\\next\\layout\_scripts\\baidu\_push.swig,这样每次访问博客中的页面就会自动向百度提交sitemap
```
    {% if theme.baidu_push %}
    <script>
    (function(){
        var bp = document.createElement('script');
        var curProtocol = window.location.protocol.split(':')[0];
        if (curProtocol === 'https') {
            bp.src = 'https://zz.bdstatic.com/linksubmit/push.js';        
        }
        else {
            bp.src = 'http://push.zhanzhang.baidu.com/push.js';
        }
        var s = document.getElementsByTagName("script")[0];
        s.parentNode.insertBefore(bp, s);
    })();
    </script>
    {% endif %}
```
#### sitemap

将我们上一步生成的sitemap文件提交到百度就可以了~  
![将sitemap提交到百度](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20180829152228.png)  
我记得被百度收录过程还是蛮久的，一度让我以为我的方法有问题，提交链接在站长工具中有显示大概是有两天的时候，站点被百度收录大概花了半个月= =，让大家看一下现在的成果  
在百度搜索`site:cherryblog.site`已经可以搜索到结果  
![站点已被百度收录](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20180829152319.png)  
在搜索框输入域名也可以找到站点 
输入关键字第一条就是
![站点已被百度收录](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20180829152439.png)

## 其他seo优化
-------

seo优化应该说是一个收益延迟的行为，可能你做的优化短期内看不到什么效果，但是一定要坚持，seo优化也是有很深的可以研究的东西，从我们最初的网站设计，和最基础的标签的选择都有很大的关系，网站设计就如我们刚刚说的，要让用户点击三次可以到达网站的任何一个页面，要增加高质量的外链，增加相关推荐（比如说我们经常见到右侧本站的最高阅读的排名列表），然后就是给每一个页面加上keyword和描述  
在代码中，我们应该写出能让浏览器识别的语义化HTML，这样有助于爬虫抓取更多的有效信息：爬虫依赖于标签来确定上下文和各个关键字的权重；并且对外链设置nofollow标签，避免spider爬着爬着就爬出去了（减少网站的跳出率），并且我们要尽量在一些比较大的网站增加我们站点的曝光率，因为spider会经常访问大站，比如我们在掘金等技术社区发表文章中带有我们的站点，这样spider是很有可能爬到我们中的站点的，so….  

<div class="note primary no-icon">网站**外链**的推广度、数量和质量  
网站的**内链**足够强大  
网站的**原创**质量  
网站的**年龄**时间  
网站的**更新频率**（更新次数越多越好）  
网站的**服务器**  
网站的**流量**：流量越高网站的权重越高  
网站的**关键词排名**：关键词排名越靠前，网站的权重越高  
网站的**收录**数量：网站百度收录数量越多，网站百度权重越高  
网站的浏览量及深度：**用户体验**越好，网站的百度权重越高</div>