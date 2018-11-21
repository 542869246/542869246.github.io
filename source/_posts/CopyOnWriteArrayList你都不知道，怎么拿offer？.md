---
title: CopyOnWriteArrayList你都不知道，怎么拿offer？
copyright: true
top: 95
date: 2018-11-21 17:57:25
categories: [java]
tags: [java,CopyOnWriteArrayList]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1541993757070_0.png
description:
---

<span></span>

<!--more-->


大家对线程安全容器可能最熟悉的就是ConcurrentHashMap了，因为这个容器经常会在面试的时候考查。

比如说，一个常见的面试场景：

*   面试官问：“HashMap是线程安全的吗？如果HashMap线程不安全的话，那有没有安全的Map容器”
*   3y：“线程安全的Map有两个，一个是Hashtable，一个是ConcurrentHashMap”
*   面试官继续问：“那Hashtable和ConcurrentHashMap有什么区别啊？”
*   3y：“balabalabalabalabalabala"
*   面试官：”ok,ok,ok,看你Java基础挺不错的呀“
    

那如果有这样的面试呢？

*   面试官问：“ArrayList是线程安全的吗？如果ArrayList线程不安全的话，那有没有安全的类似ArrayList的容器”
*   3y：“线程安全的ArrayList我们可以使用Vector，或者说我们可以使用Collections下的方法来包装一下”
*   面试官继续问：“嗯，我相信你也知道Vector是一个比较老的容器了，还有没有其他的呢？”
*   3y：“Emmmm,这个…“
*   面试官**提示**：“就比如JUC中有ConcurrentHashMap，那JUC中有类似"ArrayList"的线程安全容器类吗？“
*   3y：“Emmmm,这个…“
*   面试官：”ok,ok,ok,**今天的面试时间也差不多了，你回去等通知吧**。“
    

今天主要讲解的是CopyOnWriteArrayList~

本文**力求简单讲清每个知识点**，希望大家看完能有所收获

一、Vector和SynchronizedList
=========================

1.1回顾线程安全的Vector和SynchronizedList
---------------------------------

我们知道ArrayList是用于替代Vector的，Vector是线程安全的容器。因为它几乎在每个方法声明处都加了**synchronized关键字**来使容器安全。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793882153_1.png "Vector实现")

Vector实现

如果使用`Collections.synchronizedList(new ArrayList())`来使ArrayList变成是线程安全的话，也是几乎都是每个方法都加上synchronized关键字的，只不过**它不是加在方法的声明处，而是方法的内部**。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793882444_2.png "Collections.synchronizedList()的实现")

Collections.synchronizedList()的实现

1.2Vector和SynchronizedList可能会出现的问题
----------------------------------

在讲解CopyOnWrite容器之前，我们还是先来看一下线程安全容器的一些**可能没有注意到**的地方~

下面我们直接来看一下这段代码：

```java
   // 得到Vector最后一个元素
    public static Object getLast(Vector list) {
        int lastIndex = list.size() - 1;
        return list.get(lastIndex);
    }

    // 删除Vector最后一个元素
    public static void deleteLast(Vector list) {
        int lastIndex = list.size() - 1;
        list.remove(lastIndex);
    }
```

以我们第一反应来分析一下上面两个方法：**在多线程环境下，是否有问题**？

*   我们可以知道的是Vector的`size()和get()以及remove()`都被synchronized修饰的。
    

答案：从调用者的角度是**有问题**的

我们可以写段代码测试一下：

```java
import java.util.Vector;

public class UnsafeVectorHelpers {


    public static void main(String[] args) {

        // 初始化Vector
        Vector<String> vector = new Vector();
        vector.add("关注公众号");
        vector.add("Java3y");
        vector.add("买Linux可到我下面的链接，享受最低价");
        vector.add("给3y加鸡腿");

        new Thread(() -> getLast(vector)).start();
        new Thread(() -> deleteLast(vector)).start();
        new Thread(() -> getLast(vector)).start();
        new Thread(() -> deleteLast(vector)).start();
    }

    // 得到Vector最后一个元素
    public static Object getLast(Vector list) {
        int lastIndex = list.size() - 1;
        return list.get(lastIndex);
    }

    // 删除Vector最后一个元素
    public static void deleteLast(Vector list) {
        int lastIndex = list.size() - 1;
        list.remove(lastIndex);
    }
}
```

可以发现的是，有可能会抛出异常的：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793882774_3.png "代码抛出异常")

代码抛出异常

原因也很简单，我们照着流程走一下就好了：

*   线程A执行`getLast()`方法，线程B执行`deleteLast()`方法
    
*   线程A执行`int lastIndex = list.size() - 1;`得到lastIndex的值是3。**同时**，线程B执行`int lastIndex = list.size() - 1;`得到的lastIndex的值**也**是3
    
*   此时线程B先得到CPU执行权，执行`list.remove(lastIndex)`将下标为3的元素删除了
    
*   接着线程A得到CPU执行权，执行`list.get(lastIndex);`，发现已经没有下标为3的元素，抛出异常了.
    

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793883158_4.png "交替执行导致异常发生")

交替执行导致异常发生

出现这个问题的原因也很简单：

*   `getLast()`和`deleteLast()`这两个方法并不是原子性的，即使他们**内部的每一步操作是原子性**的(被Synchronize修饰就可以实现原子性)，但是内部之间还是可以**交替**执行。
    

*   这里的意思就是：\`size()和get()以及remove()\`都是原子性的，但是如果并发执行\`getLast()\`和\`deleteLast()\`，方法里面的\`size()和get()以及remove()\`是可以交替执行的。
    

要解决上面这种情况也很简单，因为我们都是对Vector进行操作的，**只要操作Vector前把它锁住就没毛病了**！

所以我们可以改成这样子：

```java
    // 得到Vector最后一个元素
    public static Object getLast(Vector list) {
        synchronized (list) {
            int lastIndex = list.size() - 1;
            return list.get(lastIndex);
        }
    }
    // 删除Vector最后一个元素
    public static void deleteLast(Vector list) {
        synchronized (list) {
            int lastIndex = list.size() - 1;
            list.remove(lastIndex);
        }
    }
```

> ps:如果有人去测试一下，发现会抛出异常java.lang.ArrayIndexOutOfBoundsException: -1，这是**没有检查角标的异常**，不是并发导致的问题。

经过上面的例子我们可以看看下面的代码：

```java
   public static void main(String[] args) {

        // 初始化Vector
        Vector<String> vector = new Vector();
        vector.add("关注公众号");
        vector.add("Java3y");
        vector.add("买Linux可到我下面的链接，享受最低价");
        vector.add("给3y加鸡腿");

        // 遍历Vector
        for (int i = 0; i < vector.size(); i++) {

            // 比如在这执行vector.clear();
            //new Thread(() -> vector.clear()).start();

            System.out.println(vector.get(i));
        }
    }
```

同样地：如果在遍历Vector的时候，有别的线程修改了Vector的长度，那还是会**有问题**！

*   线程A遍历Vector，执行`vector.size()`时，发现Vector的长度为5
    
*   此时**很有可能存在**线程B对Vector进行`clear()`操作
    
*   随后线程A执行`vector.get(i)`时，抛出异常
    

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793883418_5.png "Vector遍历抛出异常")

Vector遍历抛出异常

在JDK5以后，Java推荐使用`for-each`(迭代器)来遍历我们的集合，好处就是**简洁、数组索引的边界值只计算一次**。

如果使用`for-each`(迭代器)来做上面的操作，会抛出ConcurrentModificationException异常

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793883700_6.png "迭代器遍历会抛出ConcurrentModificationException")

迭代器遍历会抛出ConcurrentModificationException

SynchronizedList在使用**迭代器遍历**的时候同样会有问题的，源码已经提醒我们要手动加锁了。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793883978_7.png "SynchronizedList在遍历的时候同样会有问题的")

SynchronizedList在遍历的时候同样会有问题的

如果想要完美解决上面所讲的问题，我们可以在**遍历前加锁**：

```java
        // 遍历Vector
         synchronized (vector) {
            for (int i = 0; i < vector.size(); i++) {
                vector.get(i);
            }
        }
```

有经验的同学就可以知道：**哇，遍历一下容器都要我加上锁，这这这不是要慢死了吗**.的确是挺慢的..

所以我们的CopyOnWriteArrayList就登场了！

二、CopyOnWriteArrayList(Set)介绍
=============================

一般来说，我们会认为：CopyOnWriteArrayList是同步List的替代品，CopyOnWriteArraySet是同步Set的替代品。

无论是Hashtable-->ConcurrentHashMap，还是说Vector-->CopyOnWriteArrayList。JUC下支持并发的容器与老一代的线程安全类相比，总结起来就是加锁**粒度**的问题

*   Hashtable、Vector加锁的粒度大(直接在方法声明处使用synchronized)
*   ConcurrentHashMap、CopyOnWriteArrayList加锁粒度小(用各种的方式来实现线程安全，比如我们知道的ConcurrentHashMap用了cas锁、volatile等方式来实现线程安全..)
*   JUC下的线程安全容器在遍历的时候**不会**抛出ConcurrentModificationException异常

所以一般来说，我们都会**使用JUC包下给我们提供的线程安全容器**，而不是使用老一代的线程安全容器。

下面我们来看看CopyOnWriteArrayList是怎么实现的，为什么使用**迭代器遍历**的时候就**不用额外加锁**，也不会抛出ConcurrentModificationException异常。

2.1CopyOnWriteArrayList实现原理
---------------------------

我们还是先来回顾一下COW：

> 如果有多个调用者（callers）同时请求相同资源（如内存或磁盘上的数据存储），他们会共同获取**相同的指针指向相同的资源**，直到某个调用者**试图修改**资源的内容时，系统才会**真正复制一份专用副本**（private copy）给该调用者，而其他调用者所见到的最初的资源仍然保持不变。**优点**是如果调用者**没有修改该资源，就不会有副本**（private copy）被建立，因此多个调用者只是读取操作时可以**共享同一份资源**。

参考自维基百科：https://zh.wikipedia.org/wiki/%E5%AF%AB%E5%85%A5%E6%99%82%E8%A4%87%E8%A3%BD

> 之前写博客的时候，如果是要看源码，一般会翻译一下源码的注释并用图贴在文章上的。Emmm，发现阅读体验并不是很好，所以我这里就**直接概括一下源码注释**说了什么吧。另外，如果使用IDEA的话，可以下一个插件**Translation**(免费好用).

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793884303_8.png "Translation插件")

Translation插件

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793884659_9.png "Translation插件")

Translation插件

* * *

概括一下CopyOnWriteArrayList源码注释介绍了什么：

*   CopyOnWriteArrayList是线程安全容器(相对于ArrayList)，底层通过**复制数组**的方式来实现。
*   CopyOnWriteArrayList在遍历的使用不会抛出ConcurrentModificationException异常，并且遍历的时候就不用额外加锁
*   元素可以为null
    

2.1.1看一下CopyOnWriteArrayList基本的结构
---------------------------------
```java
    /** 可重入锁对象 */
    final transient ReentrantLock lock = new ReentrantLock();

    /** CopyOnWriteArrayList底层由数组实现，volatile修饰 */
    private transient volatile Object[] array;

    /**
     * 得到数组
     */
    final Object[] getArray() {
        return array;
    }

    /**
     * 设置数组
     */
    final void setArray(Object[] a) {
        array = a;
    }

    /**
     * 初始化CopyOnWriteArrayList相当于初始化数组
     */
    public CopyOnWriteArrayList() {
        setArray(new Object[0]);
    }
```

看起来挺简单的，CopyOnWriteArrayList底层就是数组，加锁就交由ReentrantLock来完成。

2.1.2常见方法的实现
------------

根据上面的分析我们知道如果遍历`Vector/SynchronizedList`是需要自己手动加锁的。

CopyOnWriteArrayList使用迭代器遍历时不需要显示加锁，看看`add()、clear()、remove()`与`get()`方法的实现可能就有点眉目了。

首先我们可以看看`add()`方法

```java
 public boolean add(E e) {

        // 加锁
        final ReentrantLock lock = this.lock;
        lock.lock();
        try {

            // 得到原数组的长度和元素
            Object[] elements = getArray();
            int len = elements.length;

            // 复制出一个新数组
            Object[] newElements = Arrays.copyOf(elements, len + 1);

            // 添加时，将新元素添加到新数组中
            newElements[len] = e;

            // 将volatile Object[] array 的指向替换成新数组
            setArray(newElements);
            return true;
        } finally {
            lock.unlock();
        }
    }
```

通过代码我们可以知道：在添加的时候就上锁，并**复制一个新数组，增加操作在新数组上完成，将array指向到新数组中**，最后解锁。

再来看看`size()`方法：

```java
    public int size() {

        // 直接得到array数组的长度
        return getArray().length;
    }
```

再来看看`get()`方法：
```java
    public E get(int index) {
        return get(getArray(), index);
    }

    final Object[] getArray() {
        return array;
    }
```

那再来看看`set()`方法

```java
public E set(int index, E element) {
    final ReentrantLock lock = this.lock;
    lock.lock();
    try {

        // 得到原数组的旧值
        Object[] elements = getArray();
        E oldValue = get(elements, index);

        // 判断新值和旧值是否相等
        if (oldValue != element) {

            // 复制新数组，新值在新数组中完成
            int len = elements.length;
            Object[] newElements = Arrays.copyOf(elements, len);
            newElements[index] = element;

            // 将array引用指向新数组
            setArray(newElements);
        } else {
            // Not quite a no-op; enssures volatile write semantics
            setArray(elements);
        }
        return oldValue;
    } finally {
        lock.unlock();
    }
}
```

对于`remove()、clear()`跟`set()和add()`是类似的，这里我就不再贴出代码了。

总结：

*   **在修改时，复制出一个新数组，修改的操作在新数组中完成，最后将新数组交由array变量指向**。
    
*   **写加锁，读不加锁**
    

2.1.3剖析为什么遍历时不用调用者显式加锁
----------------------

常用的方法实现我们已经基本了解了，但还是不知道为啥能够在容器遍历的时候对其进行修改而不抛出异常。所以，来看一下他的迭代器吧：

```java
    // 1. 返回的迭代器是COWIterator
    public Iterator<E> iterator() {
        return new COWIterator<E>(getArray(), 0);
    }


    // 2. 迭代器的成员属性
    private final Object[] snapshot;
    private int cursor;

    // 3. 迭代器的构造方法
    private COWIterator(Object[] elements, int initialCursor) {
        cursor = initialCursor;
        snapshot = elements;
    }

    // 4. 迭代器的方法...
    public E next() {
        if (! hasNext())
            throw new NoSuchElementException();
        return (E) snapshot[cursor++];
    }

    //.... 可以发现的是，迭代器所有的操作都基于snapshot数组，而snapshot是传递进来的array数组
```

到这里，我们应该就可以想明白了！CopyOnWriteArrayList在使用迭代器遍历的时候，操作的都是**原数组**！

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1542793884946_10.png "一张图来解析COW容器")

一张图来解析COW容器

2.1.4CopyOnWriteArrayList缺点
---------------------------

看了上面的实现源码，我们应该也大概能分析出CopyOnWriteArrayList的缺点了。

*   **内存占用**：如果CopyOnWriteArrayList经常要增删改里面的数据，经常要执行`add()、set()、remove()`的话，那是比较耗费内存的。
    

*   因为我们知道每次\`add()、set()、remove()\`这些增删改操作都要**复制一个数组**出来。
    

*   **数据一致性**：CopyOnWrite容器**只能保证数据的最终一致性，不能保证数据的实时一致性**。
    

*   从上面的例子也可以看出来，比如线程A在迭代CopyOnWriteArrayList容器的数据。线程B在线程A迭代的间隙中将CopyOnWriteArrayList部分的数据修改了(已经调用\`setArray()\`了)。但是线程A迭代出来的是原有的数据。
    

2.1.5CopyOnWriteSet
-------------------

CopyOnWriteArraySet的原理就是CopyOnWriteArrayList。
```java
    private final CopyOnWriteArrayList<E> al;

    public CopyOnWriteArraySet() {
        al = new CopyOnWriteArrayList<E>();
    }
```




<div class="note info"><p>作者：Java3y
出处：[https://mp.weixin.qq.com/s/4ngxvYpTQ6ME63YcMNdLew](https://mp.weixin.qq.com/s/4ngxvYpTQ6ME63YcMNdLew)</p></div>