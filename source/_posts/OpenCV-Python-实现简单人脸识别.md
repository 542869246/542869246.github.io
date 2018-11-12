---
title: OpenCV + Python 实现简单人脸识别
copyright: true
top: 95
date: 2018-11-12 10:52:23
categories: [Python]
tags: [Python,OpenCV,人脸识别]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1541992917699_0.png?x-oss-process=style/ys30
description:
---

<span></span>

<!--more-->


如果读取图像首先要导入OpenCV包
```python
import cv2
```

OpenCV自带的haarcascade_frontalface_default.xml，在cv2/data/目录下能找到,包含了所有OpenCV的人脸检测XML文件。

- haarcascade_eye.xml
- haarcascade_eye_tree_eyeglasses.xml
- haarcascade_frontalcatface.xml
- haarcascade_frontalcatface_extended.xml
- haarcascade_frontalface_alt.xml
- haarcascade_frontalface_alt_tree.xml
- haarcascade_frontalface_alt2.xml
- haarcascade_frontalface_default.xml
- haarcascade_fullbody.xml
- haarcascade_lefteye_2splits.xml
- haarcascade_licence_plate_rus_16stages.xml
- haarcascade_lowerbody.xml
- haarcascade_profileface.xml
- haarcascade_righteye_2splits.xml
- haarcascade_russian_plate_number.xml
- haarcascade_smile.xml
- haarcascade_upperbody.xml

直接上代码：
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2018/11/5 14:21
# @Author  : yfzhou
# @Site    : 
# @File    : face_id.py
# @Software: PyCharm
# Life is short, I use python.
# 人脸识别

import cv2

filename = "C:\\Users\\Administrator\\Pictures\\2018-05-16\\1865.JPG"

def detect(filename):
    # haarcascade_frontalface_default.xml存储在package安装的位置
    # haarcascade_frontalface_default 识别人脸
    # haarcascade_eye 识别眼睛
    face_cascade = cv2.CascadeClassifier(
        "D:\\Python\\Python37\\Lib\\site-packages\\cv2\\data\\haarcascade_frontalface_default.xml")
    eye_cascade = cv2.CascadeClassifier("D:\\Python\\Python37\\Lib\\site-packages\\cv2\\data\\haarcascade_eye.xml")
    img = cv2.imread(filename)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    # 传递参数是scaleFactor和minNeighbors,分别表示人脸检测过程中每次迭代时图像的压缩率以及每个人脸矩形保留近邻数目的最小值
    # 检测结果返回人脸矩形数组
    faces = face_cascade.detectMultiScale(gray, 1.1, 5)
    print(faces)
    for (x, y, w, h) in faces:
        # 给最新的检测到的人脸图片外面，标明一个方框
        img = cv2.rectangle(img, (x, y), (x + w, y + h), (255, 0, 0), 3)
        face_re = img[y:y + h, x:x + h]
        face_re_g = gray[y:y + h, x:x + h]
        eyes = eye_cascade.detectMultiScale(face_re_g)
        for (ex, ey, ew, eh) in eyes:
            cv2.rectangle(face_re, (ex, ey), (ex + ew, ey + eh), (0, 255, 0), 2)

    # cv2.namedWindow("Human Face Result!")
    # cv2.imshow("Human Face Result!", img)
    # 吧识别后的图片保存至指定目录
    cv2.imwrite("C:\\Users\\Administrator\\Pictures\\2018-05-16\\Face.jpg", img)
    # cv2.waitKey(0)
    # cv2.destroyAllWindows()

detect(filename)
```


效果如下图：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/3ed14e189ed9a8c50d9759a50e6b362.png)

根据检测结果，可以看到，OpenCV人脸检测效果好像并不太好。