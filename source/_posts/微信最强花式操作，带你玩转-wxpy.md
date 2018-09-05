---
title: 微信最强花式操作，带你玩转 wxpy
copyright: true
top: 95
date: 2018-09-04 10:39:25
categories: [Python]
tags: [Python]
image: http://www.tuling123.com/resources/web/v4/img/index/banner-new.png
description: wxpy基于itchat，使用了 Web 微信的通讯协议，通过大量接口优化提升了模块的易用性，并进行丰富的功能扩展。实现了微信登录、收发消息、搜索好友、数据统计、微信公众号、微信好友、微信群基本信息获取等功能。
---

<span></span>

<!--more-->

## 一、wxpy基本介绍与安装

### 1.wxpy基本介绍

<div class="note info"><p>wxpy基于itchat，使用了 Web 微信的通讯协议，通过大量接口优化提升了模块的易用性，并进行丰富的功能扩展。实现了微信登录、收发消息、搜索好友、数据统计、微信公众号、微信好友、微信群基本信息获取等功能。
可用来实现各种微信个人号的自动化操作。
</p></div>
  
### 2.wxpy安装

方法一：直接安装
```
pip install wxpy  
```
方法二：豆瓣源安装（推荐）
```
pip install -i https://pypi.douban.com/simple/  wxpy 
```
## 二、实践出真知

### 1.给自己的文件传输助手发消息
```py
#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2018/9/4 10:46
# @Author  : yfzhou
# @Site    : 
# @File    : demo1.py
# @Software: PyCharm
# Life is short, I use python.

# 给自己的文件传输助手发消息
from wxpy import *
# 初始化一个机器人对象
bot = Bot(cache_path=True)

# 向文件传输助手发送消息
bot.file_helper.send("hello,I'm Felix!") 
```
`Bot`类基本参数介绍：
```
cache_path –  
    设置当前会话的缓存路径，并开启缓存功能；为 None (默认) 则不开启缓存功能。  
    开启缓存后可在短时间内避免重复扫码，缓存失效时会重新要求登陆。  
    设为 True 时，使用默认的缓存路径 ‘wxpy.pkl’。  
qr_path – 保存二维码的路径  
console_qr – 在终端中显示登陆二维码  
```
运行后弹出一个二维码图片，用微信扫码登录即可，再回来看手机消息。  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/IMG_9380_看图王.png)


<div class="note warning"><p>特别提醒：_使用的微信账号不能为新注册的账号，不然会报错`KeyError: 'pass_ticket'`。
</p></div>

### 2.给指定朋友发送消息
```py
#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2018/9/4 10:54
# @Author  : yfzhou
# @Site    : 
# @File    : demo2.py
# @Software: PyCharm
# Life is short, I use python.

from wxpy import *
#
# 初始化一个机器人对象
# cache_path缓存路径，给定值为第一次登录生成的缓存文件路径
bot = Bot(cache_path="D:\PycharmProjects\pythonProcedure\com\zyf\weixin\wxpy.pkl")
# 查找朋友"极简XksA"
my_friend = bot.friends().search('张大饼')[0]
# 发送消息
my_friend.send('Felix TURING RoBot test') 
'''  
除此之外还有可以发送一下内容，自己动手尝试吧  
发送图片  
my\_friend.send\_image('hello.png')  
发送视频  
my\_friend.send\_video('hello.mp4')  
发送文件  
my\_friend.send\_file('hello.rar')  
'''  
```
运行结果：  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/IMG_9381_看图王.png)


### 3.群发消息

```py
import time
# 初始化一个机器人对象
# cache_path为登录状态缓存路径，给定值为第一次登录生成的缓存文件路径
bot = Bot(cache_path="D:\PycharmProjects\pythonProcedure\com\zyf\weixin\wxpy.pkl")

# 群发消息（谨慎使用，哈哈哈）
my_friends = bot.friends(update=False)
my_friends.pop(0)   # 去除列表第一个元素（自己）
for i in range(120): # 时间限制2分钟内最多发120次（具体看wxpy官方文档异常处理）
    friend = my_friends[i]
    friend.send('Good morning,the early bird catches the worm!(早上好，早起的鸟儿有虫吃！)')
    time.sleep(2)
    friend.send('不用回复，生活中一起加油！')
```
### 4.获取自己的微信好友数、活跃微信群数、关注微信公众号数

```py
# 获取所有好友[返回列表包含Chats对象(你的所有好友，包括自己)]
t0 = bot.friends(update=False)
# 查看自己好友数(除开自己)
print("我的好友数："+str(len(t0)-1))

# 获取所有微信群[返回列表包含Groups对象]
t1 = bot.groups(update=False)
# 查看微信群数(活跃的)
print("我的微信群聊数："+str(len(t1)))

# 获取所有关注的微信公众号[返回列表包含Chats对象]
t2 = bot.mps(update=False)
# 查看关注的微信公众号数
print("我关注的微信公众号数："+str(len(t2)))
```

运行结果：

```
# 注：如果直接把t0、t1、t2打印出就是对应得名称(不同类型，自己可以试一下)
我的好友数：102
我的微信群聊数：5
我关注的微信公众号数：64
```

### 5.个人聊天机器人搭建（基于自己的）

#### （1）自己的聊天机器人

```
# 查找聊天对象
my_friend = bot.friends().search('张大饼')[0]
my_friend.send('Felix TURING RoBot test')

# 自动回复
# 如果想对所有好友实现机器人回复把参数 my_friend 改成 chats = [Friend]
@bot.register(my_friend)
def my_friednd_message(msg):
    print('[接收]' + str(msg))
    if msg.type != 'Text':   # 除文字外其他消息回复内容
        ret = '你给我看了什么！[拜托]'
    elif "你来自哪里" in str(msg):   # 特定问题回答
        ret = "我来自China"
    else:         # 文字消息自动回答
        ret = '我爱你'
    print('[发送]' + str(ret))
    return ret
# 进入交互式的 Python 命令行界面，并堵塞当前线程
embed()
```
  

### 6.个人聊天机器人搭建（基于图灵机器人的）

#### （1）事前准备

百度图灵机器人，注册图灵机器人账号,然后创建一个机器人，即可获得属于你的图灵机器人api。


![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20180904170507.png)
  

#### （2） 创建属于自己的聊天机器人

*   方法一：使用`Tuling`类，简单实现
    
```py
#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2018/9/4 11:09
# @Author  : yfzhou
# @Site    : 
# @File    : demo6.py
# @Software: PyCharm
# Life is short, I use python.

from wxpy import *

# 登录缓存路径,第一次设置为True
# 生成缓存文件wxpy.pkl后，为该文件路径
bot = Bot(cache_path="D:\PycharmProjects\pythonProcedure\com\zyf\weixin\wxpy.pkl")
tuling = Tuling(api_key='b28b82730280474394c52d217d8de222')
print('Felix机器人已经启动')
# 我的小号，测试需谨慎
my_friend = bot.friends().search('张大饼')[0]
my_friend.send('Felix图灵机器人已启动，可以开始和劳资bb啦~~')
# 如果想对所有好友实现机器人回复把参数my_friend改成chats = [Friend]
# 使用图灵机器人自动与指定好友聊天
@bot.register(my_friend)
def reply_my_friend(msg):
    tuling.do_reply(msg)
# 进入交互式的 Python 命令行界面，并堵塞当前线程
embed()
```

*   方法二：自己手动发送`post`请求，有点麻烦哈哈哈~
    
```py
def auto_ai(text):
    url = "http://www.tuling123.com/openapi/api"
    api_key = "你的图灵接口api"
    payload = {
        "key": api_key,
        "info": text,
        "userid": "userid"
    }
    r = requests.post(url, data=json.dumps(payload))
    result = json.loads(r.content)
    return "[Felix图灵机器人]  " + result["text"]

bot = Bot(cache_path="D:\PycharmProjects\pythonProcedure\com\zyf\weixin\wxpy.pkl")  
print('Felix图灵机器人已经启动')
# 我的小号，测试需谨慎
my_friednd = bot.friends().search('张大饼')[0]
# 如果想对所有好友实现机器人回复把参数my_friend改成chats = [Friend]
@bot.register(my_friednd)
def my_friednd_message(msg):
    print('[接收]' + str(msg))
    if msg.type != 'Text':
        ret = '你给我看了什么！[拜托]'
    else:
        ret = auto_ai(msg.text)
    print('[发送]' + str(ret))
    return ret
# 进入交互式的 Python 命令行界面，并堵塞当前线程
embed()
```

#### （3）聊天效果图

基本测试，图灵机器人可以实现查询天气、车票、翻译、基本聊天等功能，比我们自己写的，，，哈哈哈。  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/IMG_9382_看图王.png)


### 7.来点有趣的

#### 获取微信好友性别、位置分布数据

```
from wxpy import *

# 初始化一个机器人对象
# cache_path缓存路径，给定值为第一次登录生成的缓存文件路径
bot = Bot(cache_path="D:\PycharmProjects\pythonProcedure\com\zyf\weixin\wxpy.pkl")
#获取好友列表(包括自己)
my_friends = bot.friends(update=False)
'''
stats_text 函数：帮助我们简单统计微信好友基本信息
简单的统计结果的文本
    :param total: 总体数量
    :param sex: 性别分布
    :param top_provinces: 省份分布
    :param top_cities: 城市分布
    :return: 统计结果文本
'''
print(my_friends.stats_text())
```

运行结果：

```
雨碎 共有 103 位微信好友

男性: 68 (66.0%)
女性: 27 (26.2%)

TOP 10 省份
江苏: 61 (59.22%)
上海: 5 (4.85%)
安徽: 2 (1.94%)
广东: 2 (1.94%)
北京: 2 (1.94%)
Carinthia: 1 (0.97%)
内蒙古: 1 (0.97%)
Barcelona: 1 (0.97%)
江西: 1 (0.97%)
Auckland: 1 (0.97%)

TOP 10 城市
常州: 34 (33.01%)
南京: 23 (22.33%)
广州: 2 (1.94%)
浦东新区: 2 (1.94%)
苏州: 2 (1.94%)
阜阳: 1 (0.97%)
房山: 1 (0.97%)
九江: 1 (0.97%)
徐州: 1 (0.97%)
无锡: 1 (0.97%)
```


#### 获取好友微信昵称和个性签名，词云分析

```py
bot = Bot(cache_path="D:\PycharmProjects\pythonProcedure\com\zyf\weixin\wxpy.pkl")
#获取好友列表(包括自己)
my_friends = bot.friends(update=False)
# 微信昵称
nick_name = ''
# 微信个性签名
wx_signature = ''
for friend in my_friends:
    # 微信昵称：NickName
    nick_name = nick_name + friend.raw['NickName']
    # 个性签名：Signature
    wx_signature = wx_signature + friend.raw['Signature']

nick_name = jiebaclearText(nick_name)
wx_signature = jiebaclearText(wx_signature)
make_wordcloud(nick_name,1)
make_wordcloud(wx_signature,2)
```

效果图：  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/render_01.png)


![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/render_02.png)

##### 5）获取关注微信公众号名称和基本简介，词云分析

```py
# 获取微信公众号名称
wx_public_name = ''
# 公众号简介
wx_pn_signature = ''
# 获取微信公众号列表
my_wx_pn = bot.mps(update=False)
for wx_pn in my_wx_pn:
    wx_public_name = wx_public_name + wx_pn.raw['NickName']
    wx_pn_signature = wx_pn_signature + wx_pn.raw['Signature']

wx_public_name = jiebaclearText(wx_public_name)
make_wordcloud(wx_public_name,3)
wx_pn_signature = jiebaclearText(wx_pn_signature)
make_wordcloud(wx_pn_signature,4)
```

效果图：  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/render_03.png)

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/render_04.png)

本文参考文档：

  
1.wxpy官方介绍文档: https://wxpy.readthedocs.io/zh/latest/messages.html

2.matplotlib官方介绍文档: https://matplotlib.org/
  

源代码：https://gitee.com/ShaErHu/wxpy_matplotlib_learning
