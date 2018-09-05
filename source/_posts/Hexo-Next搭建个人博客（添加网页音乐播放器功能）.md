---
title: Hexo-Next搭建个人博客（添加网页音乐播放器功能）
copyright: true
top: 95
date: 2018-08-08 16:38:02
categories: Hexo
tags: [Hexo,Next]
image: http://pic1.win4000.com/wallpaper/2018-07-13/5b4852cdc81a0.jpg
description: 为博客添加网页音乐播放器功能  
---

<span>
<!--more-->
效果图：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/music01.png)



[](#download "download")download
================================

点击访问Aplayer源码：[GitHub Aplayer](https://github.com/MoePlayer/APlayer)。下载到本地，解压后将`dist`文件夹复制到`themes\next\source`文件夹下。

[](#music-js "music.js")music.js
================================

新建`themes\next\source\dist\music.js`文件，添加内容：  

```
const ap = new APlayer({
    container: document.getElementById('aplayer'),
    fixed: true,
    autoplay: false,
    audio: [
	{
        name: "canon in d",
        artist: 'Brian Crain',
        url: 'http://pd2tflnys.bkt.clouddn.com/Brian%20Crain%20-%20canon%20in%20d.mp3',
        cover: 'http://p1.music.126.net/QGb9Vtyw7qHS00uEvPfM6g==/843325418547559.jpg?param=130y130',
      },
	  {
        name: "Apologize",
        artist: 'Martin Ermen',
        url: 'http://pd2tflnys.bkt.clouddn.com/Martin%20Ermen%20-%20Apologize.mp3',
        cover: 'http://p1.music.126.net/-_6mcI4VV5IKaiwhUAytbg==/1791104441647901.jpg?param=130y130',
      },
	  {
        name: "River Flows in You",
        artist: 'Yiruma',
        url: 'http://pd2tflnys.bkt.clouddn.com/Yiruma%20-%20River%20Flows%20in%20You.flac',
        cover: 'http://p1.music.126.net/8ZRSyI0ZN_4ah8uzsNd1mA==/2324367581169008.jpg?param=130y130',
      },
      {
        name: '惊蛰',
        artist: '音阙诗听/王梓钰',
        url: 'http://www.ytmp3.cn/down/48755.mp3',
        cover: 'http://p1.music.126.net/5MmXpaP9r88tNzExPGMI8Q==/109951163370350985.jpg?param=130y130',
      }
    ]
});
```
源码中对应的参数解释，这边都有： [Aplayer 中文文档](https://aplayer.js.org/#/zh-Hans/)

`audio`对应的便是音频文件，所以音乐播放器需要播放的音乐是需要自己进行相关信息（如歌曲链接、歌词、封面等）的配置。这里放一个mp3音乐外链网站：[http://up.mcyt.net/](http://up.mcyt.net/) ，搜索对应的音乐，然后复制`url`和右击封面图片链接粘贴到对应的位置上就行了。

注：由于该外链网站没有歌词链接，我这边没有进行配置，所以播放器在播放音乐时点击歌词是没有显示的。

[](#layout-swig "_layout.swig")_layout.swig
===========================================

打开`themes\next\layout\_layout.swig`文件，将  
```
<link rel="stylesheet" href="/dist/APlayer.min.css">
<div id="aplayer"></div>
<script type="text/javascript" src="/dist/APlayer.min.js"></script>
<script type="text/javascript" src="/dist/music.js"></script>
```
添加到`<body itemscope ...>`后面就行，即在`<body></body>`里面。

重新生成，访问页面，就能看到左下角的音乐播放器了。


