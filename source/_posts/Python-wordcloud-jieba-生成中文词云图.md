---
title: Python(wordcloud+jieba)生成中文词云图
copyright: true
top: 95
date: 2018-09-04 14:31:28
categories: [Python]
tags: [Python]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/render_09.png
description:
---

<span></span>

<!--more-->


基于Python的词云生成类库,很好用,而且功能强大.博主个人比较推荐

## 安装库
```
pip install wordcloud
pip install jieba
 
```

话不多说，直接上代码
## 实例
```py
# -*- coding: utf-8 -*-
# @Time    : 2018/9/4 13:52
# @Author  : yfzhou
# @Site    : 
# @File    : demo10.py
# @Software: PyCharm
# Life is short, I use python.

# 词云生成工具
from wordcloud import WordCloud, ImageColorGenerator
import matplotlib.pyplot as plt
from os import path
import jieba

# 获取当前的项目文件加的路径
d = path.dirname(__file__)
# 读取一个txt文件
text = open(r'C:\Users\Administrator\Desktop\阿里传：这是阿里巴巴的世界美特里斯曼.txt', 'r', encoding='utf-8').read()
# 读入背景图片
bg_pic = plt.imread(r'C:\Users\Administrator\Pictures\Other\155061877268618276.jpg')
wordlist_after_jieba = jieba.cut(text, cut_all=True)
wl_space_split = " ".join(wordlist_after_jieba)
# 生成词云
font = d + r'static/simkai.ttf'
wc = WordCloud(
    mask=bg_pic,
    background_color='white',
    font_path=font,
    scale=1.5,
    max_words=1500
).generate(wl_space_split)
image_colors = ImageColorGenerator(bg_pic)
# 图片背景
bg_color = ImageColorGenerator(bg_pic)
# 开始画图
plt.imshow(wc.recolor(color_func=bg_color))
plt.axis('off')
plt.show()
# 保存图片
wc.to_file(d + r"/image/render_09.png")
```
<div class="note info"><p>text文本是《阿里传》
font为字体路径
</p></div>

## Wordcloud各参数含义 
```
font_path : string  #字体路径，需要展现什么字体就把该字体路径+后缀名写上，如：font_path = '黑体.ttf'

width : int (default=400) #输出的画布宽度，默认为400像素

height : int (default=200) #输出的画布高度，默认为200像素

prefer_horizontal : float (default=0.90) #词语水平方向排版出现的频率，默认 0.9 （所以词语垂直方向排版出现频率为 0.1 ）

mask : nd-array or None (default=None) #如果参数为空，则使用二维遮罩绘制词云。如果 mask 非空，设置的宽高值将被忽略，遮罩形状被 mask 取代。除全白（#FFFFFF）的部分将不会绘制，其余部分会用于绘制词云。如：bg_pic = imread('读取一张图片.png')，背景图片的画布一定要设置为白色（#FFFFFF），然后显示的形状为不是白色的其他颜色。可以用ps工具将自己要显示的形状复制到一个纯白色的画布上再保存，就ok了。

scale : float (default=1) #按照比例进行放大画布，如设置为1.5，则长和宽都是原来画布的1.5倍

min_font_size : int (default=4) #显示的最小的字体大小

font_step : int (default=1) #字体步长，如果步长大于1，会加快运算但是可能导致结果出现较大的误差

max_words : number (default=200) #要显示的词的最大个数

stopwords : set of strings or None #设置需要屏蔽的词，如果为空，则使用内置的STOPWORDS

background_color : color value (default=”black”) #背景颜色，如background_color='white',背景颜色为白色

max_font_size : int or None (default=None) #显示的最大的字体大小

mode : string (default=”RGB”) #当参数为“RGBA”并且background_color不为空时，背景为透明

relative_scaling : float (default=.5) #词频和字体大小的关联性

color_func : callable, default=None #生成新颜色的函数，如果为空，则使用 self.color_func

regexp : string or None (optional) #使用正则表达式分隔输入的文本

collocations : bool, default=True #是否包括两个词的搭配

colormap : string or matplotlib colormap, default=”viridis” #给每个单词随机分配颜色，若指定color_func，则忽略该方法

random_state : int or None  #为每个单词返回一个PIL颜色


fit_words(frequencies)  #根据词频生成词云
generate(text)  #根据文本生成词云
generate_from_frequencies(frequencies[, ...])   #根据词频生成词云
generate_from_text(text)    #根据文本生成词云
process_text(text)  #将长文本分词并去除屏蔽词（此处指英语，中文分词还是需要自己用别的库先行实现，使用上面的 fit_words(frequencies) ）
recolor([random_state, color_func, colormap])   #对现有输出重新着色。重新上色会比重新生成整个词云快很多
to_array()  #转化为 numpy array
to_file(filename)   #输出到文件
```

背景图
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/155061877268618276.jpg)

效果图
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/render_09.png)