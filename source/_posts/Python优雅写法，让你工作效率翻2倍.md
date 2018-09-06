---
title: Python优雅写法，让你工作效率翻2倍
copyright: true
top: 95
date: 2018-09-06 16:23:23
categories: [Python]
tags: [Python]
image: http://pic1.win4000.com/wallpaper/2018-08-29/5b860476b93e0.jpg
description: 我们都知道，Python 的设计哲学是「优雅」、「明确」、「简单」。这也许很多人选择 Python 的原因。但是我收到有些伙伴反馈，他写的 Python 并不优雅，甚至很臃肿，那可能是你的姿势不对哦！今天就给大家带来 Python 语句的十大优雅之法。
---

<span></span>

<!--more-->

#### 为多个变量赋值

有时，有多个变量需要赋值，这时你会怎么赋值呢？

###### 常规方法：

常规方法是给变量逐个赋值。

```py
a = 0
b = 1
c = 2
```
###### 优雅方法：

直接按顺序对应一一赋值。
```py
a, b, c = 0, 1, 2  
```
#### 序列解包

需要取出列表中的元素。

###### 常规方法：

一般我们知道可以通过下标获取具体元素。
```py
info = ['brucepk', 'man', 'python']
name = info[0]
sex = info[1]
tech = info[2]
print(name,sex,tech)

# 结果
brucepk man python 
```

###### 优雅方法：

给出对应变量接收所有元素。

```py
info = ['brucepk', 'man', 'python']
name,sex,tech = info
print(name,sex,tech)

# 结果
brucepk man python
``` 

#### 优雅你的判断语句

我们用判断语句来定义一个绝对值函数。

###### 常规方法：

```py
x = -6
if x < 0:
    y = -x
else:
    y = x
print(y)

# 结果
6
```

###### 优雅方法：

```py
x = -6
y = -x if x<0 else x
print(y)

# 结果
6
```

#### 区间判断

使用 and 连续两次判断的语句，条件都符合时才执行语句。

###### 常规方法：
```py
score = 82  
if score >=80 and score < 90:  
    level = 'B'  
print(level)  
  
# 结果  
B  
```
###### 优雅方法：

使用链式判断。
```py
score = 82  
if  80 <= score < 90:  
    level = 'B'  
print(level)  
  
# 结果  
B  
```
#### 多个值符合条件判断

多个值任意一个值符合条件即为 True 的情况。

###### 常规方法：
```py
num = 1  
if num == 1 or num == 3 or num == 5:  
    type = '奇数'  
print(type)  
  
# 结果  
奇数  
```
###### 优雅方法：

使用关键字 in，让你的语句更优雅。
```py
num = 1  
if num in(1,3,5):  
    type = '奇数'  
print(type)  
  
# 结果  
奇数  
```
#### 判断是否为空

判断元素是空还是非空。

###### 常规方法：

一般我们想到的是 len() 方法来判断元素长度，大于 0 则为非空。

```py
A,B,C =[1,3,5],{},''
if len(A) > 0:
    print('A 为非空')
if len(B) > 0:
    print('B 为非空')
if len(C) > 0:
    print('C 为非空')

# 结果
A 为非空
```

###### 优雅方法：

if 后面的执行条件是可以简写的，只要条件 是非零数值、非空字符串、非空 list 等，就判断为 True，否则为 False。

```py
A,B,C =[1,3,5],{},''
if A:
    print('A 为非空')
if B:
    print('B 为非空')
if C:
    print('C 为非空')

# 结果
A 为非空
```

#### 多条件内容判断至少一个成立

###### 常规方法：

用 or 连接多个条件。
```py
math,English,computer =90,80,88  
if math<60 or English<60 or computer<60:  
    print('not pass')  
  
# 结果  
not pass  
```
###### 优雅方法：

使用 any 语句。
```
math,English,computer =90,59,88  
if any([math<60,English<60,computer<60]):  
    print('not pass')  
  
# 结果  
not pass  
```
#### 多条件内容判断全部成立

###### 常规方法：

使用 and 连接条件做判断。
```py
math,English,computer =90,80,88  
if math>60 and English>60 and computer>60:  
    print('pass')  
  
# 结果  
pass  
```
###### 优雅方法：

使用 all 方法。

```py
math,English,computer =90,80,88
if all([math>60,English>60,computer>60]):
    print('pass')

# 结果
pass
```

#### 遍历序列的元素和元素下标

###### 常规方法：

使用 for 循环进行遍历元素和下标。

```py
L =['math', 'English', 'computer', 'Physics']
for i in range(len(L)):
    print(i, ':', L[i])

# 结果
0 : math
1 : English
2 : computer
3 : Physics
``` 

###### 优雅方法：

使用 enumerate 函数。

```py
L =['math', 'English', 'computer', 'Physics']
for k,v in enumerate(L):
    print(k, ':', v)

# 结果
0 : math
1 : English
2 : computer
3 : Physics
``` 

#### 循环语句优化

###### 常规方法：

使用简单的 for 循环可以达到目的。

```py
L = []
for i in range(1, 6):
    L.append(i*i)
print(L) 

#结果：
[1, 4, 9, 16, 25]
``` 

###### 优雅方法：

使用列表生成式，一行代码搞定。

```py
print([x*x for x in range(1, 6)]) 

#结果：
[1, 4, 9, 16, 25]
```

  

Python 这些优雅的写法学会了吗？自己赶紧动手试试吧。

#### 推荐阅读
[Python骚操作 | 还原已撤回的微信消息](https://yfzhou.coding.me/2018/09/06/Python%E9%AA%9A%E6%93%8D%E4%BD%9C-%E8%BF%98%E5%8E%9F%E5%B7%B2%E6%92%A4%E5%9B%9E%E7%9A%84%E5%BE%AE%E4%BF%A1%E6%B6%88%E6%81%AF/)

[Python骚操作：微信远程控制电脑](https://yfzhou.coding.me/2018/08/20/Python%E9%AA%9A%E6%93%8D%E4%BD%9C%EF%BC%9A%E5%BE%AE%E4%BF%A1%E8%BF%9C%E7%A8%8B%E6%8E%A7%E5%88%B6%E7%94%B5%E8%84%91/)

[微信最强花式操作，带你玩转-wxpy](https://yfzhou.coding.me/2018/09/04/%E5%BE%AE%E4%BF%A1%E6%9C%80%E5%BC%BA%E8%8A%B1%E5%BC%8F%E6%93%8D%E4%BD%9C%EF%BC%8C%E5%B8%A6%E4%BD%A0%E7%8E%A9%E8%BD%AC-wxpy/)  

[手把手教你用 Python 来朗读网页](https://yfzhou.coding.me/2018/09/05/%E6%89%8B%E6%8A%8A%E6%89%8B%E6%95%99%E4%BD%A0%E7%94%A8-Python-%E6%9D%A5%E6%9C%97%E8%AF%BB%E7%BD%91%E9%A1%B5/)