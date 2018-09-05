---
title: Hexo-Next搭建个人博客（主题优化）
copyright: true
top: 95
date: 2018-08-27 16:33:30
tags: [Hexo,Next]
categories: Hexo
image: http://www.wallcoo.com/flower/Amazing_Color_Flowers_2560x1600_III/wallpapers/2560x1600/Flowers_Wallpapers_91.jpg
---
<span></span>
<!--more-->

*   Hexo版本是3.7.1
*   NexT.Pisces v5.1.4

#### 1\. 常用命令

*   Hexo的命令极简单，安装后只需要记住四个常用的即可。执行命令需要Git当前处于blog文件夹根目录下。
*   generate 生成静态文件。  
    `hexo g`
*   server 启动服务器。  
    `hexo s`
*   deploy 部署网站。部署网站前，需要预先生成静态文件。  
    `hexo d`
*   clean 清除缓存文件 (db.json) 和已生成的静态文件 (public)。  
    `hexo clean`
*   卸载Hexo  
    `npm uninstall hexo-cli -g`

#### 2.更换主题,以Next主题为例
```
$ cd your-hexo-site
$ git clone https://github.com/iissnan/hexo-theme-next themes/next
```

*   修改`Hexo 站点`目录下的`_config.yml`的主题

```
# Extensions
## Plugins: https://hexo.io/plugins/
## Themes: https://hexo.io/themes/
theme: next
```

#### 3.站点初始设置
```
# Site
title: Hexo #网站标题
subtitle: #网站副标题
description: #网站描述
author: author #您的名字
language: zh-Hans #网站使用的语言
timezone: Asia/Shanghai #网站时区。Hexo 默认使用您电脑的时区。
```

*   打开`Hexo 站点`目录下的`_config.yml`修改内容如下

#### 4.设置主题风格

*   打开`themes/next`下的`_config.yml`文件，搜索 `scheme`关键字，将你需用启用的`scheme` 前面注释 # 去除即可。

```
# ---------------------------------------------------------------
# Scheme Settings
# ---------------------------------------------------------------

# Schemes
#scheme: Muse # 默认 Scheme，这是 NexT 最初的版本，黑白主调，大量留白
#scheme: Mist # Muse 的紧凑版本，整洁有序的单栏外观
scheme: Pisces # 双栏 Scheme，小家碧玉似的清新
#scheme: Gemini # 类似 Pisces
```

#### 5.设置菜单项的显示文本和图标

*   更新说明：NexT.Pisces v5.1.3, 版本更换了修改菜单图标方式。[参看详细信息](https://link.jianshu.com?t=https://github.com/iissnan/hexo-theme-next/releases)

![](https://upload-images.jianshu.io/upload_images/1157148-aff23889b39e52b2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/244/format/webp)

*   NexT 使用的是 [Font Awesome](https://link.jianshu.com?t=http://fontawesome.io/icons/) 提供的图标， Font Awesome 提供了 600+ 的图标，可以满足绝大的多数的场景，同时无须担心在 Retina 屏幕下 图标模糊的问题。

###### **5.1设置菜单项的显示文本**：

*   打开`themes/next/languages`下的`zh-Hans.yml`文件,搜索 `menu`关键字，修改对应中文或者新增

```
    menu:
      home: 首页
      archives: 归档
      categories: 分类
      tags: 标签
      about: 关于
      search: 搜索
      schedule: 日程表
      sitemap: 站点地图
      commonweal: 公益404
      # 新增menu
      catalogue: 目录
```

###### **5.2设定菜单项的图标**

*   打开`themes/next`下的`_config.yml`文件，搜索 `menu_icons`关键字，修改对应`图标名称`或者新增对应`menu`的图标

```
    # Enable/Disable menu icons.
    # Icon Mapping:
    #   Map a menu item to a specific FontAwesome icon name.
    #   Key is the name of menu item and value is the name of FontAwesome icon. Key is case-senstive.
    #   When an question mask icon presenting up means that the item has no mapping icon.
    menu_icons:
      enable: true
      #KeyMapsToMenuItemKey: NameOfTheIconFromFontAwesome
      home: home
      about: user
      categories: th
      schedule: calendar
      tags: tags
      archives: archive
      sitemap: sitemap
      commonweal: heartbeat
      #新增menu_icon
      catalogue: th-list
```

###### **5.3设置菜单项对应的文件目录**

*   打开`themes/next`下的`_config.yml`文件，搜索 `menu`关键字，以`#`注释原有的菜单项，或者新增新的菜单项

```
    # ---------------------------------------------------------------
    # Menu Settings
    # ---------------------------------------------------------------
    
    # When running the site in a subdirectory (e.g. domain.tld/blog), remove the leading slash (/archives -> archives)
    menu:
      home: /
      categories: /categories/
      #about: /about/
      archives: /archives/
      #tags: /tags/
      #sitemap: /sitemap.xml
      #commonweal: /404/
      #新增menu
      catalogue: /catalogues/
```

*   除了`home`，`archives`,`/`后面都需要手动创建这个页面

###### **5.4创建菜单项对应文件目录,以`分类`为例**

*   在终端窗口下，定位到 `Hexo 站点`目录下。使用 `hexo new page` 新建一个页面，命名为 categories ：

```
    $ cd your-hexo-site
    $ hexo new page categories
```

###### **5.5编辑刚新建的页面,设置分类**
```
    title: 分类
    date: 2014-12-22 12:39:04
    categories: Testing #分类名
    type: "categories"
    ---
```
#### 6.头像设置

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20180827165555.png)

###### **6.1添加头像**

*   打开`themes/next`下的`_config.yml`文件，搜索 `Sidebar Avatar`关键字，去掉`avatar`前面的`#`

```
    # Sidebar Avatar
    # in theme directory(source/images): /images/avatar.jpg
    # in site  directory(source/uploads): /uploads/avatar.jpg
    avatar: http://example.com/avatar.png
```

*   或者使用本地图片,把图片放入`themes/next/source/images`下,修改`avatar`

```
    avatar: /images/blogLogo.png
```

###### **6.2设置头像边框为圆形框**

*   打开位于`themes/next/source/css/_common/components/sidebar/`下的`sidebar-author.syl`文件,修改如下

```javascript
    .site-author-image {
      display: block;
      margin: 0 auto;
      padding: $site-author-image-padding;
      max-width: $site-author-image-width;
      height: $site-author-image-height;
      border: $site-author-image-border-width solid $site-author-image-border-color;
     // 修改头像边框
      border-radius: 50%;
      -webkit-border-radius: 50%;
      -moz-border-radius: 50%;
    }
```

###### **6.3特效：鼠标放置头像上旋转**

![](https://upload-images.jianshu.io/upload_images/1157148-675a29f5238a55cf.gif?imageMogr2/auto-orient/strip%7CimageView2/2/w/240/format/webp)

```javascript
    .site-author-image {
      display: block;
      margin: 0 auto;
      padding: $site-author-image-padding;
      max-width: $site-author-image-width;
      height: $site-author-image-height;
      border: $site-author-image-border-width solid $site-author-image-border-color;
     // 修改头像边框
      border-radius: 50%;
      -webkit-border-radius: 50%;
      -moz-border-radius: 50%;
      // 设置旋转
      transition: 1.4s all;
    }
    // 可旋转的圆形头像,`hover`动作
    .site-author-image:hover {
        -webkit-transform: rotate(360deg);
        -moz-transform: rotate(360deg);
        -ms-transform: rotate(360deg);
        -transform: rotate(360deg);
    }
```

#### 7.浏览页面的时候显示当前浏览进度

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20180827170432.png)

*   打开`themes/next`下的`_config.yml`,搜索关键字`scrollpercent`,把`false`改为`true`

```
     # Scroll percent label in b2t button
      scrollpercent: true
```

*   如果想把`top`按钮放在`侧边栏`,打开`themes/next`下的`_config.yml`,搜索关键字`b2t`,把`false`改为`true`

```
     # Back to top in sidebar
      b2t: true
    
      # Scroll percent label in b2t button
      scrollpercent: true
```

效果如下图：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20180827170416.png)

#### 8.文章创建和删除

*   创建文章

```
    $ cd you-site
    $ hexo new post "you title"
	# 可以使用n代替new
```

*   文章目录  
    `you-site/source/_posts`
    
*   删除文章
    
```
    $ hexo clean
    在/source/_posts/中直接删除了相应的.md文件
    $ hexo g 
```

#### 9.标签设置

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20180827171116.png)

###### **9.1创建标签目录**

*   hexo初始是没有`标签`目录的需要自己创建

```
    $ cd you-site
    $ hexo new page tags
```

*   创建完成后,打开`you-site/source/tags`的`index.md`,修改如下

```
    ---
    title:  #页面主题
    date: 2017-08-18 15:00:55 #当前创建文件时间
    type: "tags" # 设置页面类型
    ---
```

*   得到如下界面
    
      

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20180827171000.png)
    

###### **9.2设置标签云**

*   标签云的生成:是根据你创建的文章，设定标签类型，自定生成的。某个标签下的 文章越多则，标签越高大
*   设置文章标签:打开`you-site/source/_posts`的`you title.md`,默认`tags:`为空,后面加上标签名即可

```
    ---
    layout: layout
    title: 标签1
    date: 2017-08-18 15:41:18
    tags: 标签1 #此文章在`标签1 `标签下
    #tags: [标签1,标签2] #此文章在`标签1,标签2`下
    ---
```

#### 10侧边栏设置

###### **10.1 设置侧边栏社交链接**

*   打开`themes/next`下的`_config.yml`文件,搜索关键字`social`,然后添加社交站点名称与地址即可。

```
    # Social links
    social:
      GitHub: https://github.com/your-user-name
      Twitter: https://twitter.com/your-user-name
      Weibo: https://weibo.com/your-user-name
      douban: https://douban.com/people/your-user-name
      zhihu: https://www.zhihu.com/people/your-user-name
      # 等等
```

###### **10.2 设置侧边栏社交图标**

*   打开`themes/next`下的`_config.yml`文件,搜索关键字`social_icons`，添加社交站点名称（注意大小写）图标，[Font Awesome图标地址](https://link.jianshu.com?t=http://fontawesome.io/icons/)

```
    social_icons:
      enable: true
      # Icon Mappings.
      # KeyMapsToSocalItemKey: NameOfTheIconFromFontAwesome
      GitHub: github
      Twitter: twitter
      Weibo: weibo
      Linkedin: linkedin
```

###### **10.3RSS**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20180827171615.png)

*   在你`Hexo 站点`目录下

```
    $ npm install hexo-generator-feed --save
```

*   打开`Hexo 站点`下的_config.yml,添加如下配置

```
    # feed
    # Dependencies: https://github.com/hexojs/hexo-generator-feed
    feed:
      type: atom
      path: atom.xml
      limit: 20
      hub:
      content:
```

###### **10.4友情链接**

*   打开`themes/next`下的`_config.yml`文件,搜索关键字`Blog rolls`

```
    # Blog rolls
    links_title: 友情链接 #标题
    links_layout: block #布局，一行一个连接
    #links_layout: inline
    links: #连接
      baidu: http://example.com/
      google: http://example.com/
```
