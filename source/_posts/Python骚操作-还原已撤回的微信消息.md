---
title: Python骚操作 | 还原已撤回的微信消息
copyright: true
top: 95
date: 2018-09-06 15:54:00
categories: [Python]
tags: [Python]
image: http://pic1.win4000.com/wallpaper/2018-09-05/5b8f909d44540.jpg
description:
---

<span></span>

<!--more-->

一大早醒来，发现女神昨晚发来三条消息，但是显示都已撤回，OMG，我错过了什么？群里有一个漂亮妹纸的爆照照片撤回了，想看又看不到！群里大佬分享的经典语录被撤回了，感觉错过一个亿！怎么办？用无所不能的 Python 就可以将这些撤回的消息发给你的微信，让你从此走上人生巅峰!

#### 项目环境

语言：Python3  
编辑器：Pycharm

#### 导包

itchat：控制微信的第三方库

这个库相信大家不陌生了，之前写的 [微信最强花式操作，带你玩转 wxpy](https://yfzhou.coding.me/2018/09/04/%E5%BE%AE%E4%BF%A1%E6%9C%80%E5%BC%BA%E8%8A%B1%E5%BC%8F%E6%93%8D%E4%BD%9C%EF%BC%8C%E5%B8%A6%E4%BD%A0%E7%8E%A9%E8%BD%AC-wxpy/) 文章里用的 wxpy 库就是在 itchat 库的基础上封装的。

#### 效果展示

以下截图显示的撤回消息类型依次是文字消息、微信自带表情、图片、语音、定位地图、名片、公众号文章、音乐、视频。有群里撤回的，也有个人号撤回的。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/613709486458704724_看图王.png?x-oss-process=style/w200)

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/706731996162609493.png?x-oss-process=style/w200)

#### 程序思路

**主要由两部分组成：**  
<span style="color: rgb(165, 200, 255);">handler_receive_msg()</span>：处理接收到的消息，将消息临时放在字典中。

<span style="color: rgb(165, 200, 255);">send_msg_helper()</span>：将撤回的消息自动发给文件传输助手。

#### 程序分析

首先，我们定义一个字典来储存消息，定义消息储存的临时路径。  

```py
# 说明：可以撤回的有文本文字、微信自带&收藏的表情、图片、语音、位置、名片、分享、附件、视频
msg_dict = {}    # 定义字典储存消息
rev_tmp_dir = "D:\PycharmProjects\pythonProcedure\com\zyf\weixin\wxpy.pkl"   # 定义文件存储临时目录
if not os.path.exists(rev_tmp_dir):
    os.mkdir(rev_tmp_dir)
face_bug = None    # 处理表情解决方法
```
#### 接收信息处理

先将我们需要处理的消息用 msg_register 装饰器进行注册，格式化本地时间，定义消息 ID 和消息时间。如果是群成员而且是自己微信好友撤回消息，则显示撤回消息的名称是你备注的名字，如果没有备注名字，则显示名称为微信昵称。

```py
@itchat.msg_register([TEXT, PICTURE, MAP, CARD, SHARING, RECORDING, ATTACHMENT, VIDEO, FRIENDS],
                     isFriendChat=True, isGroupChat=True)
def handler_receive_msg(msg):    # 将接收到的消息存放在字典中，不接受不具有撤回功能的信息
    global face_bug     # 全局变量
    msg_time_rec = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())   # 格式化本地时间戳 e: 2018-09-04 22:02:08
    msg_id = msg['MsgId']   # 消息ID
    msg_time = msg['CreateTime']    # 消息时间
    if 'ActualNickName' in msg:     # 判断是否为群消息
        from_user = msg['ActualUserName']    # 群消息的发送者,用户的唯一标识
        msg_from = msg['ActualNickName']
        friends = itchat.get_friends(update=True)    # 获取所有好友
        for friend in friends:
            if from_user == friend['UserName']:      # 判断群里撤回消息的是否为自己好友
                if friend['RemarkName']:             # 优先使用好友的备注名称，没有则使用昵称
                    msg_from = friend['RemarkName']
                else:
                    msg_from = friend['NickName']
                break
```

获取你的所有群的消息，判断出撤回的消息来自哪个群，显示出群名称。
```py
        groups = itchat.get_chatrooms(update=True)        # 获取所有的群
        for group in groups:
            if msg['FromUserName'] == group['UserName']:  # 根据群消息的FromUserName匹配是哪个群
                group_name = group['NickName']
                group_members = group['MemberCount']
                break
        group_name = group_name + '(' + str(group_members) + ')'
```

#### 个人消息处理

如果为个人聊天信息，也是优先显示备注名称，没有备注名就显示昵称。  

```py
    else:    # 否则输入个人消息
        if itchat.search_friends(userName=msg['FromUserName'])['RemarkName']:   # 优先使用备注名称
            msg_from = itchat.search_friends(userName=msg['FromUserName'])['RemarkName']
        else:
            msg_from = itchat.search_friends(userName=msg['FromUserName'])['NickName']
        group_name = ''
```
#### 各类型消息处理

用判断语句对各种类型的消息进行处理，包括文字消息、微信自带的表情和收藏的表情、图片、语音、位置、名片、分享、附件、视频。多条件时这里用了 in 的用法，还记得之前讲  [Python 优雅的写法](https://yfzhou.coding.me/2018/09/06/Python%E4%BC%98%E9%9B%85%E5%86%99%E6%B3%95%EF%BC%8C%E8%AE%A9%E4%BD%A0%E5%B7%A5%E4%BD%9C%E6%95%88%E7%8E%87%E7%BF%BB2%E5%80%8D/#more)  文章里把用 or 连接条件改成用 in，代码更简洁，这样我们通过项目不断的巩固之前学到的知识点，这样才能不断进步。
```py
    if msg['Type'] in ('Text', 'Friends'):
        msg_content = msg['Text']    # 如果发送的消息是文本或者好友推荐
    elif msg['Type'] in ('Recording', 'Attachment', 'Video', 'Picture'):
        msg_content = r"" + msg['FileName']     # 如果发送的消息是附件、视频、图片、语音
        msg['Text'](rev_tmp_dir + msg['FileName'])   # 保存文件
    elif msg['Type'] == 'Card':
        msg_content = msg['RecommendInfo']['NickName'] + r" 的名片"
    elif msg['Type'] == 'Map':
        x, y, location = re.search(
            "<location x=\"(.*?)\" y=\"(.*?)\".*label=\"(.*?)\".*", msg['OriContent']).group(1, 2, 3)
        if location is None:
            msg_content = r"纬度->" + x.__str__() + " 经度->" + y.__str__()      # 内容为详细的地址
        else:
            msg_content = r"" + location
    elif msg['Type'] == 'Sharing':      # 如果消息为分享的音乐或者文章，详细的内容为文章的标题或者是分享的名字
        msg_content = msg['Text']
        msg_share_url = msg['Url']      # 分享链接
    face_bug = msg_content
```
更新信息字典

```py
    # 更新字典
    msg_dict.update({msg_id: {"msg_from": msg_from,
                              "msg_time": msg_time,
                              "msg_time_rec": msg_time_rec,
                              "msg_type": msg["Type"],
                              "msg_content": msg_content,
                              "msg_share_url": msg_share_url,
                              "group_name": group_name}})
```

#### 处理撤回消息

先判断是否是撤回消息，将撤回消息发送到你的文件传输助手里，把上面函数储存的消息的发送人、发送类型、发送时间、撤回的内容发出来。以下是部分代码。

```py
@itchat.msg_register(NOTE, isFriendChat=True, isGroupChat=True, isMpChat=True)
# 收到note通知类消息，判断是不是撤回并进行相应操作
def send_msg_helper(msg):
    global face_bug
    if re.search(r"\<\!\[CDATA\[.*撤回了一条消息\]\]\>", msg['Content']) is not None:
        # 获取消息的id
        old_msg_id = re.search(
            "\<msgid\>(.*?)\<\/msgid\>",
            msg['Content']).group(1)  # 在返回的content查找撤回的消息的id
        old_msg = msg_dict.get(old_msg_id, {})
        if len(old_msg_id) < 11:
            itchat.send_file(rev_tmp_dir + face_bug, toUserName='filehelper')
            os.remove(rev_tmp_dir + face_bug)
        else:
            msg_body = "快来看啊，有人撤回消息啦！" + "\n" \
                       + old_msg.get('msg_from') + " 撤回了 " + old_msg.get("msg_type") + " 消息" + "\n" \
                       + old_msg.get('msg_time_rec') + "\n" \
                       + "撤回了什么 ⇣" + "\n" \
                       + r"" + old_msg.get('msg_content')
```
#### 主函数

最后用主函数执行微信的登录和运行。第一次需要扫码登录微信，登录时加上 hotReload 参数，为 True 时，短时间内再次运行会保存上次微信的登录态，不需要再次扫码登录。

```py
if __name__ == '__main__':
    itchat.auto_login(hotReload=True)
    itchat.run()
```

如果你电脑中有安装 Python 环境，在编辑器中直接运行源码或者在 cmd 中运行 py 文件即可。源码获取方式在文末给出。有需要的话以后可以做成界面化工具，挂在服务器上，支持做成界面化工具。
#### 写在最后

今天的分享就到这里了，需要优化的地方：长时间运行时会报 ConnectionError 提示的错误，但是不影响发送撤回消息的功能，后期加个异常捕捉机制优化下。

赶紧动手试试吧，把你朋友撤回的消息发给 TA 看看，看看他是什么反应，有趣的撤回消息发到朋友圈去提高逼格，奈斯！

#### 源码
```py
#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2018/9/6 16:09
# @Author  : yfzhou
# @Site    :
# @File    : withdraw.py
# @Software: PyCharm
# Life is short, I use python.
import os
import re
import shutil
import time
import itchat
from itchat.content import *

# 说明：可以撤回的有文本文字、微信自带&收藏的表情、图片、语音、位置、名片、分享、附件、视频
msg_dict = {}  # 定义字典储存消息
rev_tmp_dir = "D:\PycharmProjects\pythonProcedure\com\zyf\weixin\wxpy.pkl"  # 定义文件存储临时目录
if not os.path.exists(rev_tmp_dir):
    os.mkdir(rev_tmp_dir)
face_bug = None  # 处理表情解决方法


@itchat.msg_register([TEXT, PICTURE, MAP, CARD, SHARING, RECORDING, ATTACHMENT, VIDEO, FRIENDS],
                     isFriendChat=True, isGroupChat=True)
def handler_receive_msg(msg):  # 将接收到的消息存放在字典中，不接受不具有撤回功能的信息
    global face_bug  # 全局变量
    msg_time_rec = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())  # 格式化本地时间戳 e: 2018-09-04 22:02:08
    msg_id = msg['MsgId']  # 消息ID
    msg_time = msg['CreateTime']  # 消息时间
    if 'ActualNickName' in msg:  # 判断是否为群消息
        from_user = msg['ActualUserName']  # 群消息的发送者,用户的唯一标识
        msg_from = msg['ActualNickName']
        friends = itchat.get_friends(update=True)  # 获取所有好友
        for friend in friends:
            if from_user == friend['UserName']:  # 判断群里撤回消息的是否为自己好友
                if friend['RemarkName']:  # 优先使用好友的备注名称，没有则使用昵称
                    msg_from = friend['RemarkName']
                else:
                    msg_from = friend['NickName']
                break

        groups = itchat.get_chatrooms(update=True)  # 获取所有的群
        for group in groups:
            if msg['FromUserName'] == group['UserName']:  # 根据群消息的FromUserName匹配是哪个群
                group_name = group['NickName']
                group_members = group['MemberCount']
                break
        group_name = group_name + '(' + str(group_members) + ')'

    else:  # 否则输入个人消息
        if itchat.search_friends(userName=msg['FromUserName'])['RemarkName']:  # 优先使用备注名称
            msg_from = itchat.search_friends(userName=msg['FromUserName'])['RemarkName']
        else:
            msg_from = itchat.search_friends(userName=msg['FromUserName'])['NickName']
        group_name = ''

    msg_content = None  # 消息内容
    msg_share_url = None  # 分享的链接

    if msg['Type'] in ('Text', 'Friends'):
        msg_content = msg['Text']  # 如果发送的消息是文本或者好友推荐
    elif msg['Type'] in ('Recording', 'Attachment', 'Video', 'Picture'):
        msg_content = r"" + msg['FileName']  # 如果发送的消息是附件、视频、图片、语音
        msg['Text'](rev_tmp_dir + msg['FileName'])  # 保存文件
    elif msg['Type'] == 'Card':
        msg_content = msg['RecommendInfo']['NickName'] + r" 的名片"
    elif msg['Type'] == 'Map':
        x, y, location = re.search(
            "<location x=\"(.*?)\" y=\"(.*?)\".*label=\"(.*?)\".*", msg['OriContent']).group(1, 2, 3)
        if location is None:
            msg_content = r"纬度->" + x.__str__() + " 经度->" + y.__str__()  # 内容为详细的地址
        else:
            msg_content = r"" + location
    elif msg['Type'] == 'Sharing':  # 如果消息为分享的音乐或者文章，详细的内容为文章的标题或者是分享的名字
        msg_content = msg['Text']
        msg_share_url = msg['Url']  # 分享链接
    face_bug = msg_content
    # 更新字典
    msg_dict.update({msg_id: {"msg_from": msg_from,
                              "msg_time": msg_time,
                              "msg_time_rec": msg_time_rec,
                              "msg_type": msg["Type"],
                              "msg_content": msg_content,
                              "msg_share_url": msg_share_url,
                              "group_name": group_name}})


@itchat.msg_register(NOTE, isFriendChat=True, isGroupChat=True, isMpChat=True)
# 收到note通知类消息，判断是不是撤回并进行相应操作
def send_msg_helper(msg):
    global face_bug
    if re.search(r"\<\!\[CDATA\[.*撤回了一条消息\]\]\>", msg['Content']) is not None:
        # 获取消息的id
        old_msg_id = re.search(
            "\<msgid\>(.*?)\<\/msgid\>",
            msg['Content']).group(1)  # 在返回的content查找撤回的消息的id
        old_msg = msg_dict.get(old_msg_id, {})
        if len(old_msg_id) < 11:
            itchat.send_file(rev_tmp_dir + face_bug, toUserName='filehelper')
            os.remove(rev_tmp_dir + face_bug)
        else:
            msg_body = "快来看啊，有人撤回消息啦！" + "\n" \
                       + old_msg.get('msg_from') + " 撤回了 " + old_msg.get("msg_type") + " 消息" + "\n" \
                       + old_msg.get('msg_time_rec') + "\n" \
                       + "撤回了什么 ⇣" + "\n" \
                       + r"" + old_msg.get('msg_content')
            # 如果是分享存在链接
            if old_msg['msg_type'] == "Sharing":
                msg_body += "\n就是这个链接➣ " + old_msg.get('msg_share_url')
            itchat.send(msg_body, toUserName='filehelper')  # 将撤回消息发送到文件助手
            if old_msg["msg_type"] in (
                    "Picture", "Recording", "Video", "Attachment"):
                file = '@fil@%s' % (rev_tmp_dir + old_msg['msg_content'])
                itchat.send(msg=file, toUserName='filehelper')
                os.remove(rev_tmp_dir + old_msg['msg_content'])
            msg_dict.pop(old_msg_id)  # 删除字典旧消息


if __name__ == '__main__':
    itchat.auto_login(hotReload=True)
    itchat.run()

```

#### 推荐阅读

[Python骚操作：微信远程控制电脑](https://yfzhou.coding.me/2018/08/20/Python%E9%AA%9A%E6%93%8D%E4%BD%9C%EF%BC%9A%E5%BE%AE%E4%BF%A1%E8%BF%9C%E7%A8%8B%E6%8E%A7%E5%88%B6%E7%94%B5%E8%84%91/)

[微信最强花式操作，带你玩转-wxpy](https://yfzhou.coding.me/2018/09/04/%E5%BE%AE%E4%BF%A1%E6%9C%80%E5%BC%BA%E8%8A%B1%E5%BC%8F%E6%93%8D%E4%BD%9C%EF%BC%8C%E5%B8%A6%E4%BD%A0%E7%8E%A9%E8%BD%AC-wxpy/)  

[手把手教你用 Python 来朗读网页](https://yfzhou.coding.me/2018/09/05/%E6%89%8B%E6%8A%8A%E6%89%8B%E6%95%99%E4%BD%A0%E7%94%A8-Python-%E6%9D%A5%E6%9C%97%E8%AF%BB%E7%BD%91%E9%A1%B5/)  
