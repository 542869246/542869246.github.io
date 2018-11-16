---
title: 图解Java常用数据结构(一)
copyright: true
top: 95
date: 2018-11-16 09:19:22
categories: [数据结构]
tags: [数据结构,java]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1541993835149_0.png
description:
---

<span></span>

<!--more-->



最近在整理数据结构方面的知识, 系统化看了下Java中常用数据结构.
主要基于jdk8, 可能会有些特性与jdk7之前不相同, 例如LinkedList LinkedHashMap中的双向列表不再是回环的.
HashMap中的单链表是尾插, 而不是头插入等等, 后文不再赘叙这些差异, 本文目录结构如下:

 ![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717140301329-1795204354.png)

### LinkedList

经典的双链表结构, 适用于乱序插入, 删除. 指定序列操作则性能不如ArrayList, 这也是其数据结构决定的.

**add(E) / addLast(E)**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717133746276-313211308.gif)

**add(index, E)**

这边有个小的优化, 他会先判断index是靠近队头还是队尾, 来确定从哪个方向遍历链入.
```java
if (index < (size >> 1)) {
	Node<E> x = first;
	for (int i = 0; i < index; i++)
		x = x.next;
	return x;
} else {
	Node<E> x = last;
	for (int i = size - 1; i > index; i--)
		x = x.prev;
	return x;
}
```

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134043714-1008528320.gif)

**靠队尾**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134100309-1487165805.gif)

**get(index)**

也是会先判断index, 不过性能依然不好, 这也是为什么不推荐用for(int i = 0; i < lengh; i++)的方式遍历linkedlist, 而是使用iterator的方式遍历.

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134201828-1536755274.gif)

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134212062-1192617618.gif)

**remove(E)**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134240000-783801823.gif)

### ArrayList

底层就是一个数组, 因此按序查找快, 乱序插入, 删除因为涉及到后面元素移位所以性能慢.

**add(index, E)**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134402495-1450834113.gif)

**扩容**

一般默认容量是10, 扩容后, 会length*1.5.

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180718113204058-1401567917.gif)

**remove(E)**

循环遍历数组, 判断E是否equals当前元素, 删除性能不如LinkedList.

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134440963-1609104909.gif)

### Stack

经典的数据结构, 底层也是数组, 继承自Vector, 先进后出FILO, 默认new Stack()容量为10, 超出自动扩容.

**push(E)**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134532106-566548837.gif)

**pop()**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134546142-1425174736.gif)

### 后缀表达式

Stack的一个典型应用就是计算表达式如 9 + (3 - 1) * 3 + 10 / 2, 计算机将中缀表达式转为后缀表达式, 再对后缀表达式进行计算.

**中缀转后缀**

*   数字直接输出
*   栈为空时，遇到运算符，直接入栈
*   遇到左括号, 将其入栈
*   遇到右括号, 执行出栈操作，并将出栈的元素输出，直到弹出栈的是左括号，左括号不输出。
*   遇到运算符(加减乘除)：弹出所有优先级大于或者等于该运算符的栈顶元素，然后将该运算符入栈
*   最终将栈中的元素依次出栈，输出。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134649235-361366195.gif)

**计算后缀表达**

*   遇到数字时，将数字压入堆栈
*   遇到运算符时，弹出栈顶的两个数，用运算符对它们做相应的计算, 并将结果入栈
*   重复上述过程直到表达式最右端
*   运算得出的值即为表达式的结果

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134706912-413651296.gif)

### 队列

与Stack的区别在于, Stack的删除与添加都在队尾进行, 而Queue删除在队头, 添加在队尾.

**ArrayBlockingQueue**

生产消费者中常用的阻塞有界队列, FIFO.

**put(E)**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134917471-223068187.gif)

**put(E) 队列满了**
```java
final ReentrantLock lock = this.lock;
        lock.lockInterruptibly();
        try {
            while (count == items.length)
                notFull.await();
            enqueue(e);
        } finally {
            lock.unlock();
        }
```

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134930548-1581371083.gif)

**take()**

当元素被取出后, 并没有对数组后面的元素位移, 而是更新takeIndex来指向下一个元素.

takeIndex是一个环形的增长, 当移动到队列尾部时, 会指向0, 再次循环.
```java
private E dequeue() {
        // assert lock.getHoldCount() == 1;
        // assert items[takeIndex] != null;
        final Object[] items = this.items;
        @SuppressWarnings("unchecked")
        E x = (E) items[takeIndex];
        items[takeIndex] = null;
        if (++takeIndex == items.length)
            takeIndex = 0;
        count--;
        if (itrs != null)
            itrs.elementDequeued();
        notFull.signal();
        return x;
    }
```

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717134947090-1857674903.gif)

### HashMap

最常用的哈希表, 面试的童鞋必备知识了, 内部通过数组 \+ 单链表的方式实现. jdk8中引入了红黑树对长度 > 8的链表进行优化, 我们另外篇幅再讲.

**put(K, V****)**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717135210703-312944088.gif)

**put(K, V) 相同hash值**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717135235292-826682325.gif)

**resize 动态扩容**

当map中元素超出设定的阈值后, 会进行resize (length * 2)操作, 扩容过程中对元素一通操作, 并放置到新的位置.

具体操作如下:

*   在jdk7中对所有元素直接rehash, 并放到新的位置.
*   在jdk8中判断元素原hash值新增的bit位是0还是1, 0则索引不变, 1则索引变成"原索引 + oldTable.length".
```java
//定义两条链
    //原来的hash值新增的bit为0的链，头部和尾部
    Node<K,V> loHead = null, loTail = null;
    //原来的hash值新增的bit为1的链，头部和尾部
    Node<K,V> hiHead = null, hiTail = null;
    Node<K,V> next;
    //循环遍历出链条链
    do {
        next = e.next;
        if ((e.hash & oldCap) == 0) {
            if (loTail == null)
                loHead = e;
            else
                loTail.next = e;
            loTail = e;
        }
        else {
            if (hiTail == null)
                hiHead = e;
            else
                hiTail.next = e;
            hiTail = e;
        }
    } while ((e = next) != null);
    //扩容前后位置不变的链
    if (loTail != null) {
        loTail.next = null;
        newTab[j] = loHead;
    }
    //扩容后位置加上原数组长度的链
    if (hiTail != null) {
        hiTail.next = null;
        newTab[j + oldCap] = hiHead;
    }
```

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717135330300-1394283875.gif)

### LinkedHashMap

继承自HashMap, 底层额外维护了一个双向链表来维持数据有序. 可以通过设置accessOrder来实现FIFO(插入有序)或者LRU(访问有序)缓存.

**put(K, V)**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717135428093-1692938646.gif)

**get(K)**

accessOrder为false的时候, 直接返回元素就行了, 不需要调整位置. 

accessOrder为true的时候, 需要将最近访问的元素, 放置到队尾.

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717135449262-926868516.gif)

**removeEldestEntry 删除最老的元素**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1285727-20180717135601748-1338089287.gif)




<div class="note info"><p>作者：大道方圆
出处：[https://www.cnblogs.com/xdecode](https://www.cnblogs.com/xdecode/)</p></div>