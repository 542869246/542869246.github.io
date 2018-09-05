---
title: Python的22个编程技巧，Pick一下？
copyright: true
top: 95
date: 2018-09-03 16:41:20
categories: [Python]
tags: [Python]
image: http://pic1.win4000.com/wallpaper/2018-01-15/5a5c744635839.jpg
description: 
---

<span></span>

<!--more-->

<div class="note info"><p>源 / `代码湾`   编辑 / `AI时间`</p></div>

## 1. 原地交换两个数字

Python 提供了一个直观的在一行代码中赋值与交换（变量值）的方法，请参见下面的示例：

```
x,y= 10,20print(x,y)x,y= y,xprint(x,y)#1 (10, 20)#2 (20, 10)
```

赋值的右侧形成了一个新的元组，左侧立即解析（unpack）那个（未被引用的）元组到变量 和 。  

一旦赋值完成，新的元组变成了未被引用状态并且被标记为可被垃圾回收，最终也完成了变量的交换。

## 2. 链状比较操作符

比较操作符的聚合是另一个有时很方便的技巧：

```
n= 10result= 1< n< 20print(result)# Trueresult= 1> n<= 9print(result)# False
```

## 3. 使用三元操作符来进行条件赋值

三元操作符是 if-else 语句也就是条件操作符的一个快捷方式：

```
[表达式为真的返回值] if [表达式] else [表达式为假的返回值]

这里给出几个你可以用来使代码紧凑简洁的例子。下面的语句是说“如果 y 是 9，给 x 赋值 10，不然赋值为 20”。如果需要的话我们也可以延长这条操作链。

x = 10 if (y == 9) else 20

同样地，我们可以对类做这种操作：

x = (classA if y == 1 else classB)(param1, param2)

在上面的例子里 classA 与 classB 是两个类，其中一个类的构造函数会被调用。

下面是另一个多个条件表达式链接起来用以计算最小值的例子：

def small(a,b,c):returnaifa<= banda<= celse(bifb<= aandb<= celsec)print(small(1,0,1))print(small(1,2,2))print(small(2,2,3))print(small(5,4,3))#Output#0 #1 #2 #3

我们甚至可以在列表推导中使用三元运算符：

[m**2 if m > 10 else m**4 for m in range(50)]#=> [0, 1, 16, 81, 256, 625, 1296, 2401, 4096, 6561, 10000, 121, 144, 169, 196, 225, 256, 289, 324, 361, 400, 441, 484, 529, 576, 625, 676, 729, 784, 841, 900, 961, 1024, 1089, 1156, 1225, 1296, 1369, 1444, 1521, 1600, 1681, 1764, 1849, 1936, 2025, 2116, 2209, 2304, 2401]
```

## 4. 多行字符串

基本的方式是使用源于 C 语言的反斜杠：

```
multiStr= “select * from multi_rowwhere row_id < 5”print(multiStr)# select * from multi_row where row_id < 5
```

另一个技巧是使用三引号：  

```
multiStr= “””select * from multi_rowwhere row_id < 5″””print(multiStr)#select * from multi_row#where row_id < 5
```

上面方法共有的问题是缺少合适的缩进，如果我们尝试缩进会在字符串中插入空格。所以最后的解决方案是将字符串分为多行并且将整个字符串包含在括号中：  

```
multiStr= (“select * from multi_row ”“where row_id < 5 ”“order by age”)print(multiStr)#select * from multi_row where row_id < 5 order by age
```

## 5. 存储列表元素到新的变量中

我们可以使用列表来初始化多个变量，在解析列表时，变量的数目不应该超过列表中的元素个数：【译者注：元素个数与列表长度应该严格相同，不然会报错】

```
testList= [1,2,3]x,y,z= testListprint(x,y,z)#-> 1 2 3
```

## 6. 打印引入模块的文件路径

如果你想知道引用到代码中模块的绝对路径，可以使用下面的技巧：
```
import threadingimport socketprint(threading)print(socket)#1- #2-
```

## 7. 交互环境下的 “_” 操作符

这是一个我们大多数人不知道的有用特性，在 Python 控制台，不论何时我们测试一个表达式或者调用一个方法，结果都会分配给一个临时变量： _（一个下划线）。

```
>>> 2+ 13>>> _3>>> print_3
```

“_” 是上一个执行的表达式的输出。

## 8. 字典/集合推导

与我们使用的列表推导相似，我们也可以使用字典/集合推导，它们使用起来简单且有效，下面是一个例子：

```
testDict= {i: i *iforiinxrange(10)}testSet= {i *2foriinxrange(10)}print(testSet)print(testDict)#set([0, 2, 4, 6, 8, 10, 12, 14, 16, 18])#{0: 0, 1: 1, 2: 4, 3: 9, 4: 16, 5: 25, 6: 36, 7: 49, 8: 64, 9: 81}
```

注：两个语句中只有一个 <:\> 的不同，另，在 Python3 中运行上述代码时，将 改为 。

## 9. 调试脚本

我们可以在 模块的帮助下在 Python 脚本中设置断点，下面是一个例子：
```
import pdbpdb.set_trace()
```

我们可以在脚本中任何位置指定 并且在那里设置一个断点，相当简便。

## 10. 开启文件分享

Python 允许运行一个 HTTP 服务器来从根路径共享文件，下面是开启服务器的命令：
```
# Python 2
python -m SimpleHTTPServer

# Python 3
python3 -m http.server
```
上面的命令会在默认端口也就是 8000 开启一个服务器，你可以将一个自定义的端口号以最后一个参数的方式传递到上面的命令中。

## 11. 检查 Python 中的对象

我们可以通过调用 dir() 方法来检查 Python 中的对象，下面是一个简单的例子：
```
test= [1,3,5,7]
print(dir(test))[‘__add__’, ‘__class__’, ‘__contains__’, ‘__delattr__’, ‘__delitem__’, ‘__delslice__’, ‘__doc__’, ‘__eq__’, ‘__format__’, ‘__ge__’, ‘__getattribute__’, ‘__getitem__’, ‘__getslice__’, ‘__gt__’, ‘__hash__’, ‘__iadd__’, ‘__imul__’, ‘__init__’, ‘__iter__’, ‘__le__’, ‘__len__’, ‘__lt__’, ‘__mul__’, ‘__ne__’, ‘__new__’, ‘__reduce__’, ‘__reduce_ex__’, ‘__repr__’, ‘__reversed__’, ‘__rmul__’, ‘__setattr__’, ‘__setitem__’, ‘__setslice__’, ‘__sizeof__’, ‘__str__’, ‘__subclasshook__’, ‘append’, ‘count’, ‘extend’, ‘index’, ‘insert’, ‘pop’, ‘remove’, ‘reverse’, ‘sort’]
```
## 12. 简化 if 语句

我们可以使用下面的方式来验证多个值：
```
if m in [1,3,5,7]:
```
而不是：  
```
if m==1 or m==3 or m==5 or m==7:
```
或者，对于 in 操作符我们也可以使用 ‘{1,3,5,7}’ 而不是 ‘[1,3,5,7]’，因为 set 中取元素是 O(1) 操作。

## 13. 一行代码计算任何数的阶乘

Python 2.x.
```
result= (lambdak: reduce(int.__mul__,range(1,k+1),1))(3)print(result)#-> 6
```
Python 3.x.
```
import functools
result= (lambdak: functools.reduce(int.__mul__,range(1,k+1),1))(3)
print(result)#-> 6
```
## 14. 找到列表中出现最频繁的数  

```
test= [1,2,3,4,2,2,3,1,4,4,4]
print(max(set(test),key=test.count))#-> 4
```

## 15. 重置递归限制

Python 限制递归次数到 1000，我们可以重置这个值：

```
import sys
x=1001
print(sys.getrecursionlimit())#1-> 1000
sys.setrecursionlimit(x)
print(sys.getrecursionlimit())#2-> 1001
```

请只在必要的时候采用上面的技巧。

## 16. 检查一个对象的内存使用

在 Python 2.7 中，一个 32 比特的整数占用 24 字节，在 Python 3.5 中利用 28 字节。为确定内存使用，我们可以调用 getsizeof 方法：

在 Python 2.7 中
```
import sys
x=1
print(sys.getsizeof(x))#-> 24
```

在 Python 3.5 中  

```
import sys
x=1
print(sys.getsizeof(x))#-> 28
```

## 17. 使用 __slots__ 来减少内存开支

你是否注意到你的 Python 应用占用许多资源特别是内存？有一个技巧是使用 __slots__ 类变量来在一定程度上减少内存开支。

```
#In Python 3.5
import sys
class FileSystem(object):
  def __init__(self,files,folders,devices):
    self.files= files
    self.folders= folders
    self.devices= devices
    print(sys.getsizeof(FileSystem))#1-> 1016

class FileSystem1(object):
  __slots__= [‘files’,’folders’,’devices’]
  def __init__(self,files,folders,devices):
    self.files= files
    self.folders= folders
    self.devices= devices
    print(sys.getsizeof(FileSystem1))#2-> 888
```

很明显，你可以从结果中看到确实有内存使用上的节省，但是你只应该在一个类的内存开销不必要得大时才使用 __slots__。只在对应用进行性能分析后才使用它，不然地话，你只是使得代码难以改变而没有真正的益处。  

【译者注：在我的 win10 python2.7 中上面的结果是：

```
#In Python 2.7 win10#1-> 896#2-> 1016
```

所以，这种比较方式是不那么让人信服的，使用 __slots__ 主要是用以限定对象的属性信息，另外，当生成对象很多时花销可能会小一些，具体可以参见 python 官方文档:  

<div class="note info"><p>The slots declaration takes a sequence of instance variables and reserves just enough space in each instance to hold a value for each variable. Space is saved because dict is not created for each instance.</p></div>


## 18. 使用 lambda 来模仿输出方法

```
import syslprint=lambda *args:sys.stdout.write(” “.join(map(str,args)))lprint(“python”,”tips”,1000,1001)#-> python tips 1000 1001
```

## 19.从两个相关的序列构建一个字典

```
t1= (1,2,3)
t2= (10,20,30)
print(dict(zip(t1,t2)))#-> {1: 10, 2: 20, 3: 30}
```

## 20. 一行代码搜索字符串的多个前后缀
```
print(“http://www.google.com”.startswith((“http://”,”https://”)))print(“http://www.google.co.uk”.endswith((“.com”,”.co.uk”)))#1-> True#2-> True
```
## 21. 不使用循环构造一个列表

```
import itertoolstest= [[-1,-2],[30,40],[25,35]]print(list(itertools.chain.from_iterable(test)))#-> [-1, -2, 30, 40, 25, 35]
```

## 22. 在 Python 中实现一个真正的 switch-case 语句

下面的代码使用一个字典来模拟构造一个 switch-case。

```
def xswitch(x):returnxswitch._system_dict.get(x,None)xswitch._system_dict= {‘files’: 10,’folders’: 5,’devices’: 2}print(xswitch(‘default’))print(xswitch(‘devices’))#1-> None#2-> 2 
```