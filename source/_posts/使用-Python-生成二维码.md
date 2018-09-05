---
title: 使用 Python 生成二维码
copyright: true
top: 95
date: 2018-08-27 10:22:03
categories: [Python]
tags: [Python]
image: http://f1.topitme.com/1/a3/76/110721683974776a31o.jpg
---

&nbsp;&nbsp;&nbsp;&nbsp;新时代，人们有人信新的追求，自然而然会有新发明的诞生。去年，在“一带一路”国际合作高峰论坛举行期间，20国青年投票选出中国的“新四大发明”：高铁、扫码支付、共享单车和网购。其中扫码支付指手机通过扫描二维码跳转到支付页面，再进行付款。这种新的支付方式，造就二维码满天飞的现象。那么让我们来扒一扒如何使用 Python 来生成二维码图片。

<!--more-->

### 1 二维码

二维码（2-dimensional bar code），是用某种特定的几何图形按一定规律在平面（二维方向上）分布的黑白相间的图形记录数据符号信息的。它能将数字、英文字母、汉字、日文字母、特殊符号(如空格，%，/ 等)、二进制等信息记录到一个正方形的图片中。

因此，在转换的过程中，离不开编码压缩方式。在许多种类的二维条码中，常用的码制有：Data Matrix, Maxi Code, Aztec, QR Code, Vericode, PDF417, Ultracode, Code 49, Code 16K等。

二维码在现实生活中的应用越来与普遍，归于功于 QR code 码制的流行。我们常说的二维码就是它。所以，二维码又被称为 QR code。

QR code 是一种矩阵式二维条码（又称棋盘式二维条码）。它是在一个矩形空间通过黑、白像素在矩阵中的不同分布进行编码。在矩阵相应元素位置上，<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">用点（方点、圆点或其他形状）的出现表示二进制“1”，点的不出现表示二进制的“0”，点的排列组合确定了矩阵式二维条码所代表的意义</strong>。

### 2 二维码结构

我们的目的是要使用 Python 生成 QR 码，那我们需要先了解二维码(QR 码)的结构。根据标准（ISO/IEC 18004），我们可以了解到 QR 码结构如下：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20180827141504.png)

图片来源网络

<p style="margin-top: 1.5em;margin-bottom: 1.5em;max-width: 100%;min-height: 1em;color: rgb(89, 89, 89);"><strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">1) 功能图形</strong><br style="max-width: 100%;box-sizing: border-box !important;overflow-wrap: break-word !important;"><strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">功能图形</strong>是不参与编码数据的区域。它包含<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">空白区</strong>、<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">位置探测图形</strong>、<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">位置探测图形分隔符</strong>、<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">定位图形</strong>、<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">校正图形</strong>五大模块。</p>

*   空白区
    

空白区顾名思义就是要留空白。因此，这里不能有任何图样或标记。这样才能保证 QR 能被识别。

*   位置探测图形
    

这个有点类似中文的“回”字。在 QR 码中有个这样的标识，它分别的左上、右上和左下角。作用是协助扫描软件定位 QR 码并转换坐标系。我们在扫描二维码的时候，不管是竖着扫、横着扫、斜着扫都能识别出内容，主要是它的功劳。

*   位置探测图形分隔符
    

主要作用是区分功能图形和编码区域。

*   定位图形
    

它由黑白间隔的各自各自组成的线条。主要用于指示标识密度和确定坐标系。原因是 QR 码一种有 40 个版本，也就是说有 40 种尺寸。每种二维码的尺寸越大，扫描的距离就越远。

*   校正图形
    

只有 Version 2 及以上的QR码有校正标识。校正标识用于进一步校正坐标系。

<p style="margin-top: 1.5em;margin-bottom: 1.5em;max-width: 100%;min-height: 1em;color: rgb(89, 89, 89);"><strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">2) 编码区域</strong><br style="max-width: 100%;box-sizing: border-box !important;overflow-wrap: break-word !important;">编码区域是数据进行编码存储的区域。它由<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">格式信息</strong>、<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">版本信息</strong>、<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">数据和纠错码字</strong>三部分构成。</p>

*   格式信息
    

所有尺寸的二维码都有该信息。它存放一些格式化数据的信息，例如容错级别、数据掩码，和额外的自身 BCH 容错码。

*   版本信息
    

版本信息是规定二维码的规格。前面讲到 QR 码一共有 40 种规格的矩阵（一般为黑白色），从21x21（版本1），到177x177（版本40），每一版本符号比前一版本 每边增加4个模块。

*   数据和纠错码
    

主要是存储实际数据以及用于纠错码字。

### 3 二维码的绘制过程

二维码已经是有一套国际标准，绘制二维码过程的严格按照标准来执行。这个过程是比较复杂，我自己也是看了大概，然后总结出大致绘制过程。如果你想深入了解绘制细节，可以阅读标准。

<p style="margin-top: 1.5em;margin-bottom: 1.5em;max-width: 100%;min-height: 1em;color: rgb(89, 89, 89);">二维码的绘制大概过程如下：<br style="max-width: 100%;box-sizing: border-box !important;overflow-wrap: break-word !important;">1）在二维码的左上角、左下角、右上角绘制<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">位置探测图形</strong>。位置探测图形一定是一个 7x7 的矩阵。<br style="max-width: 100%;box-sizing: border-box !important;overflow-wrap: break-word !important;">2）绘制<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">校正图形</strong>。校正图形一定是一个 5x5 的矩阵。<br style="max-width: 100%;box-sizing: border-box !important;overflow-wrap: break-word !important;">3）绘制两条连接三个<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">位置探测图形</strong>的<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">定位图形</strong>。<br style="max-width: 100%;box-sizing: border-box !important;overflow-wrap: break-word !important;">4）在上述图片的基础上，继续绘制<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">格式信息</strong>。<br style="max-width: 100%;box-sizing: border-box !important;overflow-wrap: break-word !important;">5）接着绘制<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">版本信息</strong>。<br style="max-width: 100%;box-sizing: border-box !important;overflow-wrap: break-word !important;">6）填充<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">数据码</strong>和<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">纠错码</strong>到二维码图中。<br style="max-width: 100%;box-sizing: border-box !important;overflow-wrap: break-word !important;">7）最后是绘制<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">蒙版图案</strong>。因为按照上述方式填充内容，可能会出现大面积的空白或黑块的情况，导致扫描识别会十分困难。所以需要对整个图像与蒙版进行蒙版操作(Masking)，蒙版操作即为异或 XOR 操作。在这一步，我们可以将数据排列成各种图片。</p>

### 4 二维码的生成

我们既然已经了解二维码原理，那么可以利用 Python 生成二维码。然而网络上高人比比皆是。已经有大神编写了 Python 生成二维码的第三方库，所以我们不需要重复造轮子, 使用现成的库即可。

<p style="margin-top: 1.5em;margin-bottom: 1.5em;max-width: 100%;min-height: 1em;color: rgb(89, 89, 89);">我就推荐两个库：<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">qrcode</strong>&nbsp;和&nbsp;<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">python-qrcode</strong>。</p>

*   <strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">qrcode</strong>
    

<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">qrcode</strong> 运行在 Python 3 版本上，它可以玩出很多花样。例如能生成以下三种二维码图片：普通二维码、带图片的艺术二维码（黑白与彩色）、动态二维码（黑白与彩色）。它比较适合直接用于生成二维码图片的场景。

<p style="margin-top: 1.5em;margin-bottom: 1.5em;max-width: 100%;min-height: 1em;color: rgb(89, 89, 89);">安装 qrcode 库可以使用 pip 方式。但是该库依赖&nbsp;<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">pillow</strong>、<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">numpy</strong>&nbsp;和&nbsp;<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">imageio</strong>。因此，我们需要先安装依赖库，再安装 qrcode。最后的安装命令如下：</p>

```
# 逐一安装
pip install pillow
pip install numpy
pip install imageio
pip install myqr
```

该库生成带图片的艺术二维码算是一大亮点，具体用法如下:

```
myqr https://github.com -p github.jpg -c
```

上述命令作用是将 github 主页写到彩色二维码中。  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/642.webp)

该库还支持生成 gif 的彩色二维码图片，具体用法如下：
```
myqr https://github.com -p github.gif -c -con 1.5 -bri 1.6
```

效果图如下：  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/640.gif)

最后补上该库的 Github 地址：https://github.com/sylnsfar/qrcode

*   <strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">python-qrcode</strong>
    

<p style="margin-top: 1.5em;margin-bottom: 1.5em;max-width: 100%;min-height: 1em;color: rgb(89, 89, 89);"><strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">python-qrcode</strong>&nbsp;相比&nbsp;<strong style="max-width: 100%;color: rgb(255, 107, 123);box-sizing: border-box !important;overflow-wrap: break-word !important;">qrcode</strong>&nbsp;要稍微逊色一点。不过它也有自己的特色。它支持生成矢量图，而且比较适合在代码中生成二维码的场景。</p>

安装 python-qrcode 同样建议使用 pip 方式，安装命令如下：
```
pip install qrcode
```
在 Python 代码中，最简单的用法是这样。
```
import qrcodeimg = qrcode.make('https://github.com')
```

它也支持自定义二维码的信息，具体用法如下：
```
import qrcode
qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_L,
    box_size=10,
    border=4,
)
qr.add_data('https://github.com')
qr.make(fit=True)

img = qr.make_image(fill_color="black", back_color="white")
```
如果你想深入了解该库，可以到 Github 仓库阅读相关的文档。  
Github 地址是：https://github.com/lincolnloop/python-qrcode

<br/>

<center>
此文摘自微信公众号【Python中文社区】
微信扫一扫
关注该公众号
</center>
![Python中文社区](https://mp.weixin.qq.com/mp/qrcode?scene=10000005&size=102&__biz=MzAxMjUyNDQ5OA==&mid=2653557161&idx=1&sn=e6b0e7656e7e700e41a33a7142cf38b6&send_time=)