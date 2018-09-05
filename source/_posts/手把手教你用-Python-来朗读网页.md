---
title: 手把手教你用 Python 来朗读网页
copyright: true
top: 95
date: 2018-09-05 09:28:36
categories: [Python]
tags: [Python]
image: http://pic1.win4000.com/wallpaper/2018-07-11/5b45a0302e57b.jpg
description: 是不是有的时候懒得自己看新闻？那么不妨试试用 Python 来朗读给你听吧。
---

<span></span>

<!--more-->

是不是有的时候懒得自己看新闻？那么不妨试试用 Python 来朗读给你听吧。

网页转换成语音，步骤无外乎：

1.  网页正文识别，获取到正文的文本内容；
2.  文本转语音，通过接口将文本转换成语音文件；
3.  语音文件的发声，即将语音文件读出；

[](#网页正文识别 "网页正文识别")网页正文识别
==========================

我们之所以用 Python，就是因为 Python 有着丰富的库，网页正文识别也不在话下。这里我尝试了 `readability`、`goose-extractor`、`cx-extractor-python`，

[](#readability "readability")readability
-----------------------------------------

[readability](https://github.com/buriy/python-readability) 支持 Python3，使用 `pip install readability-lxml` 安装即可。

readability 使用起来也很方便：

```py
import requests
from readability import Document

response = requests.get('https://hoxis.github.io/run-ansible-without-specifying-the-inventory-but-the-host-directly.html')
doc = Document(response.text)
print(doc.title())
```

但是 readability 提取到的正文内容不是文本，里面仍包含 HTML 标签。

当然也可以结合其他组件再对 HTML 进行处理，如 `html2text`，我们这里就不再延伸，有兴趣的可以自行尝试。

[](#goose3 "goose3")goose3
--------------------------

Goose 本来是一个用 Java 编写的文章提取器，后来就有了 Python 实现版： [goose3](https://github.com/goose3/goose3) 。

使用起来也很方便，同时对中文支持也不错。使用 `pip install goose3` 即可安装。

```
>>> from goose3 import Goose
>>> from goose3.text import StopWordsChinese
>>> url  = 'http://news.china.com/socialgd/10000169/20180616/32537640_all.html'
>>> g = Goose({'stopwords_class': StopWordsChinese})
>>> article = g.extract(url=url)
>>> print(article.cleaned_text[:150])
北京时间6月15日23:00(圣彼得堡当地时间18:00)，2018年世界杯B组一场比赛在圣彼得堡球场展开角逐，伊朗1比0险胜摩洛哥，伊朗前锋阿兹蒙半场结束前错过单刀机会，鲍哈杜兹第95分钟自摆乌
龙。这是伊朗20年来首度在世界杯决赛圈取胜。

本届世界杯，既相继出现替补便进球，贴补梅开二度以及东道主
```

可以看出网页正文提取效果还不错，基本满足我们的要求，可以使用！

<div class="note info"><p>注意：goose 还有另外一个 Python2 的版本：`Python-Goose`，使用方法和 goose3 基本一样。</p></div>

[](#文本转语音 "文本转语音")文本转语音
=======================

文本转语音，[百度](http://ai.baidu.com/docs#/TTS-API/top)、[阿里](https://helpcdn.aliyun.com/document_detail/52793.html?spm=a2c4g.11186623.6.577.CyUtzC)、[腾讯](https://cloud.tencent.com/document/product/441/8217)、[讯飞](http://doc.xfyun.cn/rest_api/)等都有提供 REST API 接口，阿里和腾讯的申请相对时间较长，阿里的貌似还要收费，百度和讯飞的在线申请后即可使用，没办法，好的东西得来总是要曲折一些。其中百度的没有调用量的限制（其实默认是 200000 次/天），讯飞有每天 500 次的限制。

这里我们使用百度的 REST API 接口中的语言合成接口，一方面原因是百度的调用次数没有限制，另一方面，我大致看了下讯飞的接口文档，接口限制还是比较多的。还有就是百度提供了 REST API 的 Python 封装，使用也更方便。

[](#baidu-aip-的使用 "baidu-aip 的使用")baidu-aip 的使用
-----------------------------------------------

百度提供了 Python SDK，使用 `pip install baidu-aip` 可以直接安装。接口的使用可以参考接口文档：[http://ai.baidu.com/docs#/TTS-Online-Python-SDK/top](http://ai.baidu.com/docs#/TTS-Online-Python-SDK/top)。

使用示例如下：

```
from aip import AipSpeech

"""
你的 APPID AK SK 
均可在服务控制台中的应用列表中查看。
"""
APP_ID = '你的 App ID'
API_KEY = '你的 Api Key'
SECRET_KEY = '你的 Secret Key'

client = AipSpeech(APP_ID, API_KEY, SECRET_KEY)


result  = client.synthesis('你好，你在做什么', 'zh', 3, {
    'vol': 5,
})

# 识别正确返回语音二进制 错误则返回dict 参照下面错误码
if not isinstance(result, dict):
    with open('auido.mp3', 'wb') as f:
        f.write(result)
```

接口参数：

<table><thead><tr><th>参数</th><th>类型</th><th>描述</th><th>是否必须</th></tr></thead><tbody><tr><td>tex</td><td>String</td><td>合成的文本，使用UTF-8编码，请注意文本长度必须小于1024字节</td><td>是</td></tr><tr><td>lang</td><td>String</td><td>语言选择,填写zh</td><td>是</td></tr><tr><td>ctp</td><td>String</td><td>客户端类型选择，web端填写1</td><td>是</td></tr><tr><td>cuid</td><td>String</td><td>用户唯一标识，用来区分用户，填写机器 MAC 地址或 IMEI 码，长度为60以内</td><td>否</td></tr><tr><td>spd</td><td>String</td><td>语速，取值0-9，默认为5中语速</td><td>否</td></tr><tr><td>pit</td><td>String</td><td>音调，取值0-9，默认为5中语调</td><td>否</td></tr><tr><td>vol</td><td>String</td><td>音量，取值0-15，默认为5中音量</td><td>否</td></tr><tr><td>per</td><td>String</td><td>发音人选择,0为女声，1为男声，3为情感合成-度逍遥，4为情感合成-度丫丫，默认为普通女</td><td>否</td></tr></tbody></table>


接口对单次传入的文本进行了限制，合成文本长度必须小于1024字节，如果文本长度过长，就需要进行切割处理，采用多次请求的方式，分别转换成语音文件，最后再将多个语音文件合并成一个。

[](#文本切割 "文本切割")文本切割
--------------------

可以使用如下代码将文本分割成多个长度为 500 的文本列表

```py
# 将文本按 500 的长度分割成多个文本
text_list = [text[i:i+500] for i in range(0, len(text), 500)]
``` 

[](#语言文件合并 "语言文件合并")语言文件合并
--------------------------

我们使用 [pydub](https://github.com/jiaaro/pydub) 来处理生成的音频文件。使用 `pip install pydub` 即可安装。

另外还 Ubuntu 环境需要安装依赖 `sudo apt-get install libav-tools`，Windows 环境需要到 [https://ffmpeg.zeranoe.com/builds/](https://ffmpeg.zeranoe.com/builds/) 下载 `FFmpeg`，并将其配置到环境变量中。

若还有问题，可以参考官网配置：[https://github.com/jiaaro/pydub](https://github.com/jiaaro/pydub)。

```py
# 合并音频文件
def merge_voice(file_list):
    voice_dict = {}
    song = None
    for i,f in enumerate(file_list):
        if i == 0:
            song = AudioSegment.from_file(f,"mp3")
        else:
            # 拼接音频文件
            song += AudioSegment.from_file(f,"mp3")
        # 删除临时音频
        os.unlink(f)
 
    # 导出合并后的音频文件，格式为MP3格式
    file_name = str(uuid.uuid1()) + ".mp3"
    song.export(file_name, format="mp3")
    return file_name
```

通过百度的接口，我们可以将文字转化成音频文件，下面的问题就是如何播放音频文件。

[](#音频文件播放 "音频文件播放")音频文件播放
==========================

网上获取到 Python 播放 wav 文件的方式由好几种，包括 pyaudio、pygame、winsound、playsound。不过测试下来，只有 [playsound](https://github.com/TaylorSMarks/playsound) 成功。其他方式有兴趣的可以试下，有问题可以留言交流。

使用 `pip install playsound` 安装后即可使用。

使用也很简单：

```
> from playsound import playsound
>>> playsound('/path/to/a/sound/file/you/want/to/play.mp3')
```

<div class="note info"><p>说明：音频的播放需要在图形化页面下运行，因为命令行模式下，没有播放声音的出口。</p></div>

[](#实现代码 "实现代码")实现代码
====================

```py
# encoding:utf-8

import uuid
import re
import os
import argparse
from pydub import AudioSegment
from aip import AipSpeech
from playsound import playsound
from goose3 import Goose
from goose3.text import StopWordsChinese

""" 你的 百度 APPID AK SK """
APP_ID = '11407664'
API_KEY = 'GT69E8M6sgOcSnIGElrgXo1e'
SECRET_KEY = 'fOCr1mwnyGOEjZg93GoonaGqzqp0paIB'

# 命令行输入参数处理
parser = argparse.ArgumentParser()
parser.add_argument('-u', '--url', type=str, help="input the target url")

# 获取参数
args = parser.parse_args()
URL = args.url

client = AipSpeech(APP_ID, API_KEY, SECRET_KEY)

def text_to_voice(text):
    file_name = str(uuid.uuid1()) + '.mp3'
    result = client.synthesis(text, 'zh', 3, {
        'vol': 5,
    })

    # 识别正确返回语音二进制 错误则返回 dict 参照下面错误码
    if not isinstance(result, dict):
        with open(file_name, 'wb+') as f:
            f.write(result)
    return file_name

def get_text(url):
    g = Goose({'stopwords_class': StopWordsChinese})
    article = g.extract(url=url)
    return article.cleaned_text

# 合并音频文件
def merge_voice(file_list):
    voice_dict = {}
    song = None
    for i,f in enumerate(file_list):
        if i == 0:
            song = AudioSegment.from_file(f,"mp3")
        else:
            # 拼接音频文件
            song += AudioSegment.from_file(f,"mp3")
        # 删除临时音频
        os.unlink(f)
 
    # 导出合并后的音频文件，格式为MP3格式
    file_name = str(uuid.uuid1()) + ".mp3"
    song.export(file_name, format="mp3")
    return file_name

if __name__ == "__main__":
    # url = "http://news.china.com/socialgd/10000169/20180616/32537640_all.html"
    text = get_text(URL)

    # 将文本按 500 的长度分割成多个文本
    text_list = [text[i:i+500] for i in range(0, len(text), 500)]
    file_list = []
    for t in text_list:
        file_list.append(text_to_voice(t))
    # print(file_list)
    final_voice = merge_voice(file_list)
    print(final_voice)
    # 播放音频
    playsound(final_voice)
```

[](#运行 "运行")运行
--------------
```
python page2voice.py -u "https://so.gushiwen.org/shiwenv_c244fc77f6fb.aspx"  
```
运行后，代码就会自动解析网页并进行朗读啦。

[](#总结 "总结")总结
==============

至此，网页到音频的转换就结束了，当然程序没有这么完美，比如中英文混合的网页解析和转换的结果就不怎么理想，但是纯中文的新闻页面效果还是不错的。

源码已上传至 [GitHub](https://github.com/hoxis/to_voice/blob/master/page2voice.py)，欢迎取阅。

* * *