---
title: HTML5 file API加canvas实现图片前端JS压缩并上传
copyright: true
top: 95
date: 2018-08-10 19:26:16
categories: [前端]
tags: [HTML,file,canvas]
image: http://pic1.win4000.com/wallpaper/2017-12-08/5a29fbe8a39b8.jpg
description: 
---
<span>
<!--more-->
by [zhangxinxu](http://www.zhangxinxu.com/) from [http://www.zhangxinxu.com/wordpress/?p=6308](http://www.zhangxinxu.com/wordpress/?p=6308)  
本文可全文转载，但需得到原作者书面许可，同时保留原作者和出处，摘要引流则随意。



### 一、图片上传前端压缩的现实意义

对于大尺寸图片的上传，在前端进行压缩除了省流量外，最大的意义是极大的提高了用户体验。

这种体验包括两方面：

1.  由于上传图片尺寸比较小，因此上传速度会比较快，交互会更加流畅，同时大大降低了网络异常导致上传失败风险。
2.  最最重要的体验改进点：省略了图片的再加工成本。很多网站的图片上传功能都会对图片的大小进行限制，尤其是头像上传，限制5M或者2M以内是非常常见的。然后现在的数码设备拍摄功能都非常出众，一张原始图片超过2M几乎是标配，此时如果用户想把手机或相机中的某个得意图片上传作为自己的头像，就会遇到因为图片大小限制而不能上传的窘境，不得不对图片进行再处理，而这种体验其实非常不好的。如果可以在前端进行压缩，则理论上对图片尺寸的限制是没有必要的。

### 二、图片前端JS压缩并上传功能体验

特意制作了一个图片前端压缩并上传的完整demo，您可以狠狠的点击这里：[使用canvas在前端压缩图片并上传demo](http://www.zhangxinxu.com/study/201707/js-compress-image-before-upload.html)

进入demo会看到一个相貌平平的文件输入框：

![相貌平平](//image.zhangxinxu.com/image/blog/201707/gutianlle.jpg)

啊，不对，应该是这张图：

![相貌平平文件选择框](//image.zhangxinxu.com/image/blog/201707/2017-07-30_221637.png)

点击文件选择框，我们不妨选一张尺寸比较大的图片，例如下面这种2M多的钓鱼收获照：

![上传演示使用的图片](//image.zhangxinxu.com/image/blog/201707/2017-07-30_221955.png)

于是图片歘歘歘地传上去了：  
![上传相关信息截图](//image.zhangxinxu.com/image/blog/201707/2017-07-30_222424.png)

此时我们点击最终上传完毕的图片地址，会发现原来2M多3000多像素宽的图片被限制为400像素宽了：  
![图片缩小后在浏览器中的预览效果图](//image.zhangxinxu.com/image/blog/201707/2017-07-30_222714s.jpg)

保存到本地会发现图片尺寸已经变成只有70K了：  
![保存到本地显示的图片尺寸](//image.zhangxinxu.com/image/blog/201707/2017-07-30_223016.jpg)

以上就是图片前端压缩并上传demo的完整演示。

### 三、HTML5 file API加canvas实现图片前端JS压缩

要想使用JS实现图片的压缩效果，原理其实很简单，核心API就是使用`canvas`的`drawImage()`方法。

`canvas`的`drawImage()`方法API如下：

```
context.drawImage(img, dx, dy);
context.drawImage(img, dx, dy, dWidth, dHeight);
context.drawImage(img, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight);
```
后面最复杂的语法虽然看上去有9大参数，但不用慌，实际上可以看出就3个参数：

**img**

就是图片对象，可以是页面上获取的DOM对象，也可以是虚拟DOM中的图片对象。

**dx, dy, dWidth, dHeight**

表示在`canvas`画布上规划处一片区域用来放置图片，`dx, dy`为canvas元素的左上角坐标，`dWidth, dHeight`指canvas元素上用在显示图片的区域大小。如果没有指定`sx,sy,sWidth,sHeight`这4个参数，则图片会被拉伸或缩放在这片区域内。

**sx,sy,swidth,sheight**

这4个坐标是针对图片元素的，表示图片在`canvas`画布上显示的大小和位置。`sx,sy`表示图片上`sx,sy`这个坐标作为左上角，然后往右下角的`swidth,sheight`尺寸范围图片作为最终在canvas上显示的图片内容。

`drawImage()`方法有一个非常怪异的地方，大家一定要注意，那就是5参数和9参数里面参数位置是不一样的，这个和一般的API有所不同。一般API可选参数是放在后面。但是，这里的`drawImage()`9个参数时候，可选参数`sx,sy,swidth,sheight`是在前面的。如果不注意这一点，有些表现会让你无法理解。

下图为[MDN](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/drawImage)上原理示意：  
![Canvas drawimage()原理示意](//image.zhangxinxu.com/image/blog/201711/Canvas_drawimage.jpg)

对于本文的图片压缩，需要用的是是5个参数语法。举个例子，一张图片（假设图片对象是`img`）的原始尺寸是4000\*3000，现在需要把尺寸限制为400\*300大小，很简单，原理如下代码示意：
```
var canvas = document.createElement('canvas');
var context = canvas.getContext('2d');
canvas.width = 400;
canvas.height = 300;
// 核心JS就这个
context.drawImage(img,0,0,400,300);
```
把一张大的图片，直接画在一张小小的画布上。此时大图片就天然变成了小图片，压缩就这么实现了，是不是简单的有点超乎想象。

当然，若要落地于实际开发，我们还需要做些其他的工作，就是要解决图片来源和图片去向的问题。

#### 1\. 如何把系统中图片呈现在浏览器中？

HTML5 file API可以让图片在上传之前直接在浏览器中显示，通常使用`FileReader`方法，代码示意如下：
```
var reader = new FileReader(), img = new Image();
// 读文件成功的回调
reader.onload = function(e) {
  // e.target.result就是图片的base64地址信息
  img.src = e.target.result;
};
eleFile.addEventListener('change', function (event) {
    reader.readAsDataURL(event.target.files\[0\]);
});
```
于是，包含图片信息的`context.drawImage()`方法中的`img`图片就有了。

**2\. 如果把canvas画布转换成img图像**  
`canvas`天然提供了2个转图片的方法，一个是：

**canvas.toDataURL()方法**

语法如下：
```
canvas.toDataURL(mimeType, qualityArgument)
```
可以把图片转换成base64格式信息，纯字符的图片表示法。

其中：  
`mimeType`表示`canvas`导出来的`base64`图片的类型，默认是png格式，也即是默认值是`'image/png'`，我们也可以指定为jpg格式`'image/jpeg'`或者webp等格式。`file`对象中的`file.type`就是文件的mimeType类型，在转换时候正好可以直接拿来用（如果有file对象）。  
`qualityArgument`表示导出的图片质量，只要导出为`jpg`和`webp`格式的时候此参数才有效果，默认值是`0.92`，是一个比较合理的图片质量输出参数，通常情况下，我们无需再设定。

**canvas.toBlob()方法**

[语法](https://developer.mozilla.org/en-US/docs/Web/API/HTMLCanvasElement/toBlob)如下：

canvas.toBlob(callback, mimeType, qualityArgument)

可以把canvas转换成[Blob文件](http://www.zhangxinxu.com/wordpress/2013/10/understand-domstring-document-formdata-blob-file-arraybuffer/)，通常用在文件上传中，因为是二进制的，对后端更加友好。

和`toDataURL()`方法相比，`toBlob()`方法是异步的，因此多了个`callback`参数，这个`callback`回调方法默认的第一个参数就是转换好的`blob`文件信息，本文demo的文件上传就是将`canvas`图片转换成二进制的`blob`文件，然后再`ajax`上传的，代码如下：
```
// canvas转为blob并上传
canvas.toBlob(function (blob) {
  // 图片ajax上传
  var xhr = new XMLHttpRequest();
  // 开始上传
  xhr.open("POST", 'upload.php', true);
  xhr.send(blob);    
});
```
于是，经过“图片→canvas压缩→图片”三步曲，我们完成了图片前端压缩并上传的功能。

更加完整的核心代码请参见[demo页面](http://www.zhangxinxu.com/study/201707/js-compress-image-before-upload.html)的左侧，如果对其他交互代码也敢兴趣，请参考页面源代码。

下面贴出完整代码：

**HTML代码：**
```
<input id="file" type="file">
```
**JS代码：**
```
var eleFile = document.querySelector('#file');

// 压缩图片需要的一些元素和对象
var reader = new FileReader(), img = new Image();

// 选择的文件对象
var file = null;

// 缩放图片需要的canvas
var canvas = document.createElement('canvas');
var context = canvas.getContext('2d');

// base64地址图片加载完毕后
img.onload = function () {
    // 图片原始尺寸
    var originWidth = this.width;
    var originHeight = this.height;
    // 最大尺寸限制
    var maxWidth = 400, maxHeight = 400;
    // 目标尺寸
    var targetWidth = originWidth, targetHeight = originHeight;
    // 图片尺寸超过400x400的限制
    if (originWidth > maxWidth || originHeight > maxHeight) {
        if (originWidth / originHeight > maxWidth / maxHeight) {
            // 更宽，按照宽度限定尺寸
            targetWidth = maxWidth;
            targetHeight = Math.round(maxWidth * (originHeight / originWidth));
        } else {
            targetHeight = maxHeight;
            targetWidth = Math.round(maxHeight * (originWidth / originHeight));
        }
    }
        
    // canvas对图片进行缩放
    canvas.width = targetWidth;
    canvas.height = targetHeight;
    // 清除画布
    context.clearRect(0, 0, targetWidth, targetHeight);
    // 图片压缩
    context.drawImage(img, 0, 0, targetWidth, targetHeight);
    // canvas转为blob并上传
    canvas.toBlob(function (blob) {
        // 图片ajax上传
        var xhr = new XMLHttpRequest();
        // 文件上传成功
        xhr.onreadystatechange = function() {
            if (xhr.status == 200) {
                // xhr.responseText就是返回的数据
            }
        };
        // 开始上传
        xhr.open("POST", 'upload.php', true);
        xhr.send(blob);    
    }, file.type || 'image/png');
};

// 文件base64化，以便获知图片原始尺寸
reader.onload = function(e) {
    img.src = e.target.result;
};
eleFile.addEventListener('change', function (event) {
    file = event.target.files[0];
    // 选择的文件是图片
    if (file.type.indexOf("image") == 0) {
        reader.readAsDataURL(file);    
    }
});
```

### 四、结束语

就在几个月前刚写过一篇文章“[使用canvas在前端实现图片水印合成](http://www.zhangxinxu.com/wordpress/?p=6165)”，实际上所使用的技术和套路和本文是如出一辙的，也是“图片→canvas水印→图片”三步曲，区别在于水印合成是连续执行两次`context.drawImage()`方法，一次是原图一次水印图片，以及最后转换成图片的时候什么是`toDataURL()`方法，其他代码逻辑和原理都是一样的。

由此及彼，利用同样的原理和代码逻辑，我们还可以实现其它很多以前前端不太好实现的功能，比方说图片的真剪裁效果，所谓“真剪裁”指不是使用个`overflow:hidden`或者`clip`这些CSS属性的“伪剪裁”，而是真正意义上就这么大区域图片信息。甚至配合一些前端算法，我们可以直接在前端进行人脸识别，图片自动美化等一系列功能再上传等等。

原理都是一样的，都是利用`canvas`作为中间媒介进行处理。

好，以上就是本文的全部内容，感谢阅读，欢迎纠错，欢迎交流！

![](//image.zhangxinxu.com/image/blog/201611/14.png)

本文为原创文章，会经常更新知识点以及修正一些错误，因此转载请保留原出处，方便溯源，避免陈旧错误知识的误导，同时有更好的阅读体验。  
本文地址：[http://www.zhangxinxu.com/wordpress/?p=6308](http://www.zhangxinxu.com/wordpress/?p=6308)


相关文章

*   [XMLHttpRequest实现HTTP协议下文件上传断点续传](https://www.zhangxinxu.com/wordpress/2013/11/xmlhttprequest-ajax-localstorage-%e6%96%87%e4%bb%b6%e6%96%ad%e7%82%b9%e7%bb%ad%e4%bc%a0/)
*   [HTML input type=file文件选择表单元素二三事](https://www.zhangxinxu.com/wordpress/2015/11/html-input-type-file/)
*   [纯前端实现可传图可字幕台词定制的GIF表情生成器](https://www.zhangxinxu.com/wordpress/2018/05/js-custom-gif-generate/)
*   [小tips: 纯前端JS读取与解析本地文本类文件](https://www.zhangxinxu.com/wordpress/2018/03/js-parse-text-file/)
*   [Ajax Upload多文件上传插件翻译及中文演示](https://www.zhangxinxu.com/wordpress/2009/11/ajax-upload%e5%a4%9a%e6%96%87%e4%bb%b6%e4%b8%8a%e4%bc%a0%e6%8f%92%e4%bb%b6%e7%bf%bb%e8%af%91%e5%8f%8a%e4%b8%ad%e6%96%87%e6%bc%94%e7%a4%ba/)
*   [理解DOMString、Document、FormData、Blob、File、ArrayBuffer数据类型](https://www.zhangxinxu.com/wordpress/2013/10/understand-domstring-document-formdata-blob-file-arraybuffer/)
*   [基于HTML5的可预览多图片Ajax上传](https://www.zhangxinxu.com/wordpress/2011/09/%e5%9f%ba%e4%ba%8ehtml5%e7%9a%84%e5%8f%af%e9%a2%84%e8%a7%88%e5%a4%9a%e5%9b%be%e7%89%87ajax%e4%b8%8a%e4%bc%a0/)
*   [小tips:使用canvas在前端实现图片水印合成](https://www.zhangxinxu.com/wordpress/2017/05/canvas-picture-watermark-synthesis/)
*   [原来浏览器原生支持JS Base64编码解码](https://www.zhangxinxu.com/wordpress/2018/08/js-base64-atob-btoa-encode-decode/)
*   [小tip:JS前端创建html或json文件并浏览器导出下载](https://www.zhangxinxu.com/wordpress/2017/07/js-text-string-download-as-html-json-file/)
*   [SVG <foreignObject>简介与截图等应用](https://www.zhangxinxu.com/wordpress/2017/08/svg-foreignobject/)

