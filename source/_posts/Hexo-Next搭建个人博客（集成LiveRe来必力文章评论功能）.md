---
title: Hexo-Next搭建个人博客（集成LiveRe来必力文章评论功能）
date: 2018-08-08 08:55:15
tags: [Hexo,Next]
categories: Hexo
top: 95
image: http://pic1.win4000.com/wallpaper/2018-08-16/5b74e359e6426.jpg
description: 由于众所周知的原因，多说评论和网易云跟帖先后都宣布关闭评论服务，一直没有找到好的替换方案。昨天无意看到韩国的Livere（来必力）评论，瞬间就喜欢上了~UI好看，加载时候的那个小幽灵也好可爱=w=而且是国外的，应该没那么容易关闭吧2333下面记录一下步骤~ 
---

<span>
<!--more-->

[](#准备 "准备")准备
--------------

1.  去[Livere官网](https://livere.com/)注册Livere账号。
2.  选择City版（免费），安装
3.  进入管理页面->代码管理->一般网站，复制data-uid

[](#在Hexo中添加Livere "在Hexo中添加Livere")在Hexo中添加Livere
--------------------------------------------------

以下基于主题Next，其他主题做法类似

1.  打开`博客根目录/themes/next/_config.yml`
2.  将# Third Party Services Settings 栏目下其他评论系统如duoshuo、gentie、youyan、disqus用#注释掉，加入以下内容
```    
# Livere评论系统
    livere_uid: 上一步中你获取的data-uid
```
3.  在博客根目录`/themes/layout/_scripts/third-party/comments/`目录中新建txt文件，重命名为livere.swig，编辑内容如下：
    
```
    {% if not (theme.duoshuo and theme.duoshuo.shortname) and not theme.duoshuo_shortname and not theme.disqus_shortname and not theme.hypercomments_id and not theme.gentie_productKey %}
      {% if theme.livere_uid %}
        <script type="text/javascript">
          (function(d, s) {
            var j, e = d.getElementsByTagName(s)[0];
            if (typeof LivereTower === 'function') { return; }
            j = d.createElement(s);
            j.src = 'https://cdn-city.livere.com/js/embed.dist.js';
            j.async = true;
            e.parentNode.insertBefore(j, e);
          })(document, 'script');
        </script>
      {% endif %}
    {% endif %}
```
    
4.  在`博客根目录/themes/layout/_scripts/third-party/comments.swig`文件中追加：
    ```
    {% include './comments/livere.swig' %}
    ```
5.  在博客根目录`/themes/layout/_partials/comments.swig`文件中条件最后追加 LiveRe 插件是否引用的判断逻辑：
    
    ```
    {% elseif theme.livere_uid %}
          <div id="lv-container" data-id="city" data-uid="{{ theme.livere_uid }}"></div>
    {% endif %}
    ```

重新`hexo clean、hexo d -g`，然后就可以看到来必力评论啦~ 

ps:因为是国外的，评论加载有点慢。 

###### 效果图
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/liveRe01.png)

