---
title: 剑指ConcurrentHashMap【基于JDK1.8】
copyright: true
top: 95
date: 2018-12-24 14:03:40
categories: [java]
tags: [java,HashMap,ConcurrentHashMap,JUC]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/wallhaven-376073_3384x1440.png?x-oss-process=style/ys30
description: 都不懂ConcurrentHashMap原理？请问你怎么敢去面试的？
---

<span></span>

<!--more-->

## 上期回顾

先说明下，本文的ConcurrentHashMap是基于jdk1.8的

之前的几篇文章 [hashCode()和hash算法的那些事儿](https://542869246.github.io/2018/12/06/hashCode-%E5%92%8Chash%E7%AE%97%E6%B3%95%E7%9A%84%E9%82%A3%E4%BA%9B%E4%BA%8B%E5%84%BF/ "hashCode()和hash算法的那些事儿")， [HashMap扫盲](https://542869246.github.io/2018/12/07/HashMap%E6%89%AB%E7%9B%B2/ "HashMap扫盲") ， [浅谈HashMap线程安全问题](https://542869246.github.io/2018/12/13/%E6%B5%85%E8%B0%88HashMap%E7%BA%BF%E7%A8%8B%E5%AE%89%E5%85%A8%E9%97%AE%E9%A2%98/ "浅谈HashMap线程安全问题") 详细给大家分析了一波HashMap源码实现，以及并发情况下HashMap的隐患，其解决方案谈到ConcurrentHashMap，这篇文章就开始谈谈ConcurrentHashMap。ConcurrentHashMap和HashMap有很多相同点，类似的地方本文就不多说了，可以看我之前的文章，就默认在看的各位是看过HashMap源码的优秀程序猿啦~

## ConcurrentHashMap简介

在并发场景下，ConcurrentHashMap是一个经常被使用的数据结构。相对于HashTable和Collections.synchronizedMap()，ConcurrentHashMap在线程安全的基础上提供了更好的写并发能力，**利用了锁分段的思想提高了并发度。**

在此膜拜下Doug Lea大师！！牛逼！！！

## ConcurrentHashMap在JDK1.6，1.7实现主要思路：

ConcurrentHashMap采用了分段锁的设计，只有在同一个分段内才存在竞态关系，不同的分段锁之间没有锁竞争。相比于对整个Map加锁的设计，分段锁大大的提高了高并发环境下的处理能力。
ConcurrentHashMap中的分段锁称为`Segment`，它即类似于HashMap（JDK7与JDK8中HashMap的实现）的结构，即内部拥有一个Entry数组，数组中的每个元素又是一个链表；同时又是一个`ReentrantLock`（`Segment`继承了`ReentrantLock`）。
贴一个1.7的ConcurrentHashMap数据结构图：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/JDK1.7%20ConcurrentHashMap.jpg)
关于1.7，本文不再累赘，具体实现大家可以百度，以后我可能也会写个基于1.7的ConcurrentHashMap。


## ConcurrentHashMap在JDK1.8实现主要思路：
ConcurrentHashMap在JDK8中进行了巨大改动，光是代码量就从1000多行增加到6000行！1.8摒弃了`Segment`(锁段)的概念，引入了大量的`CAS`无锁操机制以及`synchronized`来保证多线程操作的安全性。到这里有人就有疑问了，怎么又开始使用`synchronized`啦？1.7的`ReentrantLock`方式不行吗？？其实是1.8对`synchronized`也进行了很多优化，使用`synchronized`相较于ReentrantLock的性能会持平甚至在某些情况更优。

贴一个1.8的ConcurrentHashMap数据结构图：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/JDK1.8%20ConcurrentHashMap.jpg)
可以看到，和HashMap 1.8的数据结构很像。底层数据结构改变为采用数组+链表+红黑树的数据形式。


## 和HashMap1.8相同的一些地方

- 底层数据结构一致
- HashMap初始化是在第一次put元素的时候进行的，而不是init
- HashMap的底层数组长度总是为2的整次幂
- 默认树化的阈值为 8，而链表化的阈值为 6
- hash算法也很类似，但多了一步` & HASH_BITS`，该步是为了消除最高位上的负符号，hash的负在ConcurrentHashMap中有特殊意义表示在**扩容或者是树节点**

```java
    static final int HASH_BITS = 0x7fffffff; // usable bits of normal node hash

    static final int spread(int h) {
        return (h ^ (h >>> 16)) & HASH_BITS;
    }
```

这些相同的地方我就不多说了，前几篇关于HashMap的文章都深度分析过了，有兴趣的可以去看看，老司机忽略。

## 一些关键属性

```java
private static final int MAXIMUM_CAPACITY = 1 << 30; //数组最大大小 同HashMap

private static final int DEFAULT_CAPACITY = 16;//数组默认大小

static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8; //数组可能最大值，需要与toArray（）相关方法关联

private static final int DEFAULT_CONCURRENCY_LEVEL = 16; //兼容旧版保留的值，默认线程并发度，类似信号量

private static final float LOAD_FACTOR = 0.75f;//默认map扩容比例，实际用(n << 1) - (n >>> 1)代替了更高效

static final int TREEIFY_THRESHOLD = 8; // 链表转树阀值，大于8时

static final int UNTREEIFY_THRESHOLD = 6; //树转链表阀值，小于等于6（tranfer时，lc、hc=0两个计数器分别++记录原bin、新binTreeNode数量，<=UNTREEIFY_THRESHOLD 则untreeify(lo)）。【仅在扩容tranfer时才可能树转链表】

static final int MIN_TREEIFY_CAPACITY = 64;

private static final int MIN_TRANSFER_STRIDE = 16;//扩容转移时的最小数组分组大小

private static int RESIZE_STAMP_BITS = 16;//本类中没提供修改的方法 用来根据n生成位置一个类似时间戳的功能

private static final int MAX_RESIZERS = (1 << (32 - RESIZE_STAMP_BITS)) - 1; // 2^15-1，help resize的最大线程数

private static final int RESIZE_STAMP_SHIFT = 32 - RESIZE_STAMP_BITS; // 32-16=16，sizeCtl中记录size大小的偏移量

static final int MOVED = -1; // hash for forwarding nodes（forwarding nodes的hash值）、标示位

static final int TREEBIN = -2; // hash for roots of trees（树根节点的hash值）

static final int RESERVED = -3; // ReservationNode的hash值

static final int HASH_BITS = 0x7fffffff; // 用在计算hash时进行安位与计算消除负hash

static final int NCPU = Runtime.getRuntime().availableProcessors(); // 可用处理器数量

/* ---------------- Fields -------------- */

transient volatile Node<K,V>[] table; //装载Node的数组，作为ConcurrentHashMap的数据容器，采用懒加载的方式，直到第一次插入数据的时候才会进行初始化操作，数组的大小总是为2的幂次方。

private transient volatile Node<K,V>[] nextTable; //扩容时使用，平时为null，只有在扩容的时候才为非null

/**
* 实际上保存的是hashmap中的元素个数  利用CAS锁进行更新但它并不用返回当前hashmap的元素个数 
*/
private transient volatile long baseCount;

/**
*该属性用来控制table数组的大小，根据是否初始化和是否正在扩容有几种情况：
*当值为负数时：如果为-1表示正在初始化，如果为-N则表示当前正有N-1个线程进行扩容操作；
*当值为正数时：如果当前数组为null的话表示table在初始化过程中，sizeCtl表示为需要新建数组的长度；若已经初始化了，表示当前数据容器（table数组）可用容量也可以理解成临界值（插入节点数超过了该临界值就需要扩容），具体指为数组的长度n 乘以 加载因子loadFactor；当值为0时，即数组长度为默认初始值。
*/
private transient volatile int sizeCtl;


```
很多关键字都很眼熟吧。

## Unsafe与CAS
在阅读ConcurrentHashMap源码过程中，你会发现有许多的`U`，`U.compareAndSwapXXX`的方法，比如：
```java
static final <K,V> boolean casTabAt(Node<K,V>[] tab, int i, Node<K,V> c, Node<K,V> v) {
     return U.compareAndSwapObject(tab, ((long)i << ASHIFT) + ABASE, c, v);
}
```
引用的是`sun.misc.Unsafe`包里面的方法，这个包哪里还用到了？看过我之前写的 [CAS机制是什么鬼？](https://542869246.github.io/2018/12/17/CAS%E6%9C%BA%E5%88%B6%E6%98%AF%E4%BB%80%E4%B9%88%E9%AC%BC%EF%BC%9F/) 读者可能会知道。
JDK原子变量类可以保证原子操作，看下`AtomicReference`原子变量类内部源码：
```java
    public final boolean compareAndSet(V expect, V update) {
        return unsafe.compareAndSwapObject(this, valueOffset, expect, update);
    }
```
这个方法是利用一个CAS算法实现无锁化的修改值的操作，他可以大大降低锁代理的性能消耗。其中`unsafe.compareAndSwapObject()`就是引用了`sun.misc.Unsafe`包里面的`compareAndSwapObject`方法。

## TreeBin是什么鬼？
大家都知道HashMap1.8中，链表长度超过8，就会转为TreeNode(红黑树)
```java
else if (p instanceof TreeNode)
    e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
```
但是来看看ConcurrentHashMap中的：
```java
else if (f instanceof TreeBin) {
                            
    ...
}
```
咦？我们的`TreeNode`同志哪里去啦？有经验的读者可能已经推算出这个地方就是判断节点是否红黑树的依据了。

其实TreeBin就是封装TreeNode的容器，TreeBin这个类并不负责包装用户的key、value信息，而是包装的很多TreeNode节点。它代替了TreeNode的根节点，也就是说在实际的ConcurrentHashMap“数组”中，存放的是TreeBin对象，而不是TreeNode对象。

## put操作
和HashMap差不多，最后调用的是putVal()方法，直接贴putVal()代码
```java

    final V putVal(K key, V value, boolean onlyIfAbsent) {
        if (key == null || value == null) throw new NullPointerException();
        // 根据 key 计算出 hashcode
        int hash = spread(key.hashCode());
        int binCount = 0;
        for (Node<K,V>[] tab = table;;) {
            Node<K,V> f; int n, i, fh;
             // 判断是否需要进行初始化
            if (tab == null || (n = tab.length) == 0)
                tab = initTable();
            // f 即为当前 key 定位出的 Node，如果为空表示当前位置可以写入数据，利用 CAS 尝试写入，失败则自旋保证成功
            else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {
                if (casTabAt(tab, i, null,
                             new Node<K,V>(hash, key, value, null)))
                    break;                   // no lock when adding to empty bin
            }
            // 如果当前位置的 hashcode == MOVED == -1,则需要进行扩容
            else if ((fh = f.hash) == MOVED)
                tab = helpTransfer(tab, f);
            // 如果都不满足，则利用 synchronized 锁写入数据
            else {
                V oldVal = null;
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        // 当前为链表，在链表中插入新的键值对
                        if (fh >= 0) {
                            binCount = 1;
                            for (Node<K,V> e = f;; ++binCount) {
                                K ek;
                                if (e.hash == hash &&
                                    ((ek = e.key) == key ||
                                     (ek != null && key.equals(ek)))) {
                                    oldVal = e.val;
                                    if (!onlyIfAbsent)
                                        e.val = value;
                                    break;
                                }
                                Node<K,V> pred = e;
                                if ((e = e.next) == null) {
                                    pred.next = new Node<K,V>(hash, key,
                                                              value, null);
                                    break;
                                }
                            }
                        }
                        // 当前为红黑树，将新的键值对插入到红黑树中
                        else if (f instanceof TreeBin) {
                            Node<K,V> p;
                            binCount = 2;
                            if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                           value)) != null) {
                                oldVal = p.val;
                                if (!onlyIfAbsent)
                                    p.val = value;
                            }
                        }
                    }
                }
                // 插入完键值对后再根据实际大小看是否需要转换成红黑树
                if (binCount != 0) {
                    if (binCount >= TREEIFY_THRESHOLD)
                        treeifyBin(tab, i);
                    if (oldVal != null)
                        return oldVal;
                    break;
                }
            }
        }
        // 对当前容量大小进行检查，如果超过了临界值（实际大小*加载因子）就需要扩容 
        addCount(1L, binCount);
        return null;
    }

```
putVal操作和HashMap1.8操作过程总体上差不多的，说下过程：

1. `spread()`方法获取hash，减小hash冲突
2. 判断是否初始化table数组，没有的话调用`initTable()`方法进行初始化
3. 判断是否能直接将新值插入到table数组中
4. 判断当前是否在扩容，`MOVED`为-1说明当前ConcurrentHashMap正在进行扩容操作，正在扩容的话就进行协助扩容
5. 当table[i]为链表的头结点，在链表中插入新值，通过synchronized (f)的方式进行加锁以实现线程安全性。
 1. 在链表中如果找到了与待插入的键值对的key相同的节点，就直接覆盖
 2. 如果没有找到的话，就直接将待插入的键值对追加到链表的末尾
6. 当table[i]为红黑树的根节点，在红黑树中插入新值/覆盖旧值
7. 根据当前节点个数进行调整，否需要转换成红黑树(个数大于等于8，就会调用`treeifyBin`方法将tabel[i]`第i个散列桶`拉链转换成红黑树)
8. 对当前容量大小进行检查，如果超过了临界值（实际大小*加载因子）就进行扩容

我们可以发现JDK8中的实现也是**锁分离**的思想，只是锁住的是一个Node，而不是JDK7中的Segment，而锁住Node之前的操作是无锁的并且也是线程安全的，建立在之前提到的原子操作上。

*ps：ConcurrentHashMap不允许key或value为null值*

## addCount()方法
在put方法结尾处调用了addCount方法，把当前ConcurrentHashMap的元素个数+1这个方法一共做了两件事,更新baseCount的值，检测是否进行扩容。
```java
//  从 putVal 传入的参数是 1， binCount，binCount 默认是0，只有 hash 冲突了才会大于 1.且他的大小是链表的长度（如果不是红黑数结构的话）。
private final void addCount(long x, int check) {
        CounterCell[] as; long b, s;
        //利用CAS方法更新baseCount的值
        if ((as = counterCells) != null ||
            !U.compareAndSwapLong(this, BASECOUNT, b = baseCount, s = b + x)) {
            CounterCell a; long v; int m;
            boolean uncontended = true;
            if (as == null || (m = as.length - 1) < 0 ||
                (a = as[ThreadLocalRandom.getProbe() & m]) == null ||
                !(uncontended =
                  U.compareAndSwapLong(a, CELLVALUE, v = a.value, v + x))) {
                fullAddCount(x, uncontended);
                return;
            }
            if (check <= 1)
                return;
            s = sumCount();
        }
        //如果需要检查,检查是否需要扩容，在 putVal 方法调用时，默认就是要检查的。
        if (check >= 0) {
            Node<K,V>[] tab, nt; int n, sc;
            // 如果map.size() 大于 sizeCtl（达到扩容阈值需要扩容） 且
            // table 不是空；且 table 的长度小于 1 << 30。（可以扩容）
            while (s >= (long)(sc = sizeCtl) && (tab = table) != null &&
                   (n = tab.length) < MAXIMUM_CAPACITY) {
                // 根据 length 得到一个标识
                int rs = resizeStamp(n);
                // 如果正在扩容
                if (sc < 0) {
                    // 如果 sc 的低 16 位不等于 标识符（校验异常 sizeCtl 变化了）
                    // 如果 sc == 标识符 + 1 （扩容结束了，不再有线程进行扩容）（默认第一个线程设置 sc ==rs 左移 16 位 + 2，当第一个线程结束扩容了，就会将 sc 减一。这个时候，sc 就等于 rs + 1）
                    // 如果 sc == 标识符 + 65535（帮助线程数已经达到最大）
                    // 如果 nextTable == null（结束扩容了）
                    // 如果 transferIndex <= 0 (转移状态变化了)
                    // 结束循环
                    if ((sc >>> RESIZE_STAMP_SHIFT) != rs || sc == rs + 1 ||
                        sc == rs + MAX_RESIZERS || (nt = nextTable) == null ||
                        transferIndex <= 0)
                        break;
                    // 如果可以帮助扩容，那么将 sc 加 1. 表示多了一个线程在帮助扩容
                    if (U.compareAndSwapInt(this, SIZECTL, sc, sc + 1))
                        // 扩容
                        transfer(tab, nt);
                }
                // 如果不在扩容，将 sc 更新：标识符左移 16 位 然后 + 2. 也就是变成一个负数。高 16 位是标识符，低 16 位初始是 2.
                else if (U.compareAndSwapInt(this, SIZECTL, sc,
                                             (rs << RESIZE_STAMP_SHIFT) + 2))
                    // 更新 sizeCtl 为负数后，开始扩容。
                    transfer(tab, null);
                s = sumCount();
            }
        }
    }
```
CounterCell类是只有一个volatile的long类型变量

```
if ((as = counterCells) != null ||
            !U.compareAndSwapLong(this, BASECOUNT, b = baseCount, s = b + x))
```
这个if主要干的事
1. counterCells初始是null，则运行后面的CAS对baseCount增加，但存在多线程可能会导致CAS增加失败，则运行fullAddCount把数量值存到counterCells数组中
2. counterCells不null之前已经有过baseCount CAS失败，这种能失败大多代表并发不低，则在counterCells数组中使用随机数随便取一个索引位置之前记录的数据进行数量累加，如果在counterCells数组中CAS累加因多线程还是失败这继续fullAddCount，fullAddCount中会触发扩容等操作，因此直接return

总结下来看，addCount 方法做了两件事情：
1. 对 table 的长度加一。无论是通过修改 baseCount，还是通过使用 CounterCell。当 CounterCell 被初始化了，就优先使用他，不再使用 baseCount。
2. 检查是否需要扩容，或者是否正在扩容。如果需要扩容，就调用扩容方法，如果正在扩容，就帮助其扩容。

## size()方法

```java
    public int size() {
        long n = sumCount();
        return ((n < 0L) ? 0 :
                (n > (long)Integer.MAX_VALUE) ? Integer.MAX_VALUE :
                (int)n);
    }

    final long sumCount() {
        CounterCell[] as = counterCells; CounterCell a;
        long sum = baseCount;
        if (as != null) {
            for (int i = 0; i < as.length; ++i) {
                if ((a = as[i]) != null)
                    sum += a.value;
            }
        }
        return sum;
    }
```

因为元素个数保存baseCount中，部分元素的变化个数保存在CounterCell数组中，CounterCell数组中保存的就是并发导致 CAS 失败的数据，所以通过累加baseCount和CounterCell数组中的数量，即可得到元素的总个数。

```java
    public long mappingCount() {
        long n = sumCount();
        return (n < 0L) ? 0L : n; // ignore transient negative values
    }
```
顺带说下JDK 8 推荐使用`mappingCount` 方法，因为这个方法的返回值是 long 类型，不会因为 size 方法是 int 类型限制最大值


## helpTransfer()

从字面上就可以知道，这是帮助扩容。在`putVal()`方法中，如果发现线程当前 hash 冲突了，也就是当前 hash 值对应的槽位有值了，且如果这个值是 -1 （MOVED），说明 Map 正在扩容。那么就帮助 Map 进行扩容。以加快速度。具体代码如下：

```java
    final Node<K,V>[] helpTransfer(Node<K,V>[] tab, Node<K,V> f) {
        Node<K,V>[] nextTab; int sc;
        // 如果 table 不是空 且 node 节点是转移类型，数据检验
        // 且 node 节点的 nextTable（新 table） 不是空，同样也是数据校验
        // 尝试帮助扩容
        if (tab != null && (f instanceof ForwardingNode) &&
            (nextTab = ((ForwardingNode<K,V>)f).nextTable) != null) {
            // 根据 length 得到一个标识符号
            int rs = resizeStamp(tab.length);
            // 如果 nextTab 没有被并发修改 且 tab 也没有被并发修改
            // 且 sizeCtl  < 0 （说明还在扩容）
            while (nextTab == nextTable && table == tab &&
                   (sc = sizeCtl) < 0) {
                // 如果 sizeCtl 无符号右移  16 不等于 rs （ sc前 16 位如果不等于标识符，则标识符变化了）
                // 或者 sizeCtl == rs + 1  （扩容结束了，不再有线程进行扩容）（默认第一个线程设置 sc ==rs 左移 16 位 + 2，当第一个线程结束扩容了，就会将 sc 减一。这个时候，sc 就等于 rs + 1）
                // 或者 sizeCtl == rs + 65535  （如果达到最大帮助线程的数量，即 65535）
                // 或者转移下标正在调整 （扩容结束）
                // 结束循环，返回 table
                if ((sc >>> RESIZE_STAMP_SHIFT) != rs || sc == rs + 1 ||
                    sc == rs + MAX_RESIZERS || transferIndex <= 0)
                    break;
                // 如果以上都不是, 将 sizeCtl + 1, （表示增加了一个线程帮助其扩容）
                if (U.compareAndSwapInt(this, SIZECTL, sc, sc + 1)) {
                    // 进行转移
                    transfer(tab, nextTab);
                    break;
                }
            }
            return nextTab;
        }
        return table;
    }
```

总结一下：
当put元素的时候，如果发现这个节点的元素类型是 forward 的话，就帮助正在扩容的线程一起扩容，提高速度。其中， sizeCtl 是关键，该变量高 16 位保存 length 生成的标识符，低 16 位保存并发扩容的线程数，通过这连个数字，可以判断出，是否结束扩容了。这也是为什么ConcurrentHashMap扩容性能那么高的原因。

## 扩容方法 transfer
ConcurrentHashMap的扩容操作总体来说分为两个部分：
- 构建一个nextTable,它的容量是原来的两倍，这个操作是单线程完成的。这个单线程的保证是通过`RESIZE_STAMP_SHIFT`这个常量经过一次运算来保证的。
- 将原来table中的元素复制到nextTable中，这里允许多线程进行操作。



```java
  /**
     * 一个过渡的table表  只有在扩容的时候才会使用
     */
    private transient volatile Node<K,V>[] nextTable;
 
 /**
     * Moves and/or copies the nodes in each bin to new table. See
     * above for explanation.
     */
    private final void transfer(Node<K,V>[] tab, Node<K,V>[] nextTab) {
        int n = tab.length, stride;
        if ((stride = (NCPU > 1) ? (n >>> 3) / NCPU : n) < MIN_TRANSFER_STRIDE)
            stride = MIN_TRANSFER_STRIDE; // subdivide range
        if (nextTab == null) {            // initiating
            try {
                @SuppressWarnings("unchecked")
                Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n << 1];//构造一个nextTable对象 它的容量是原来的两倍
                nextTab = nt;
            } catch (Throwable ex) {      // try to cope with OOME
                sizeCtl = Integer.MAX_VALUE;
                return;
            }
            nextTable = nextTab;
            transferIndex = n;
        }
        int nextn = nextTab.length;
        ForwardingNode<K,V> fwd = new ForwardingNode<K,V>(nextTab);//构造一个连节点指针 用于标志位
        boolean advance = true;//并发扩容的关键属性 如果等于true 说明这个节点已经处理过
        boolean finishing = false; // to ensure sweep before committing nextTab
        for (int i = 0, bound = 0;;) {
            Node<K,V> f; int fh;
            //这个while循环体的作用就是在控制i--  通过i--可以依次遍历原hash表中的节点
            while (advance) {
                int nextIndex, nextBound;
                if (--i >= bound || finishing)
                    advance = false;
                else if ((nextIndex = transferIndex) <= 0) {
                    i = -1;
                    advance = false;
                }
                else if (U.compareAndSwapInt
                         (this, TRANSFERINDEX, nextIndex,
                          nextBound = (nextIndex > stride ?
                                       nextIndex - stride : 0))) {
                    bound = nextBound;
                    i = nextIndex - 1;
                    advance = false;
                }
            }
            if (i < 0 || i >= n || i + n >= nextn) {
                int sc;
                if (finishing) {
                	//如果所有的节点都已经完成复制工作  就把nextTable赋值给table 清空临时对象nextTable
                    nextTable = null;
                    table = nextTab;
                    sizeCtl = (n << 1) - (n >>> 1);//扩容阈值设置为原来容量的1.5倍  依然相当于现在容量的0.75倍
                    return;
                }
                //利用CAS方法更新这个扩容阈值，在这里面sizectl值减一，说明新加入一个线程参与到扩容操作
                if (U.compareAndSwapInt(this, SIZECTL, sc = sizeCtl, sc - 1)) {
                    if ((sc - 2) != resizeStamp(n) << RESIZE_STAMP_SHIFT)
                        return;
                    finishing = advance = true;
                    i = n; // recheck before commit
                }
            }
            //如果遍历到的节点为空 则放入ForwardingNode指针
            else if ((f = tabAt(tab, i)) == null)
                advance = casTabAt(tab, i, null, fwd);
            //如果遍历到ForwardingNode节点  说明这个点已经被处理过了 直接跳过  这里是控制并发扩容的核心
            else if ((fh = f.hash) == MOVED)
                advance = true; // already processed
            else {
            		//节点上锁
                synchronized (f) {
                    if (tabAt(tab, i) == f) {
                        Node<K,V> ln, hn;
                        //如果fh>=0 证明这是一个Node节点
                        if (fh >= 0) {
                            int runBit = fh & n;
                            //以下的部分在完成的工作是构造两个链表  一个是原链表  另一个是原链表的反序排列
                            Node<K,V> lastRun = f;
                            for (Node<K,V> p = f.next; p != null; p = p.next) {
                                int b = p.hash & n;
                                if (b != runBit) {
                                    runBit = b;
                                    lastRun = p;
                                }
                            }
                            if (runBit == 0) {
                                ln = lastRun;
                                hn = null;
                            }
                            else {
                                hn = lastRun;
                                ln = null;
                            }
                            for (Node<K,V> p = f; p != lastRun; p = p.next) {
                                int ph = p.hash; K pk = p.key; V pv = p.val;
                                if ((ph & n) == 0)
                                    ln = new Node<K,V>(ph, pk, pv, ln);
                                else
                                    hn = new Node<K,V>(ph, pk, pv, hn);
                            }
                            //在nextTable的i位置上插入一个链表
                            setTabAt(nextTab, i, ln);
                            //在nextTable的i+n的位置上插入另一个链表
                            setTabAt(nextTab, i + n, hn);
                            //在table的i位置上插入forwardNode节点  表示已经处理过该节点
                            setTabAt(tab, i, fwd);
                            //设置advance为true 返回到上面的while循环中 就可以执行i--操作
                            advance = true;
                        }
                        //对TreeBin对象进行处理  与上面的过程类似
                        else if (f instanceof TreeBin) {
                            TreeBin<K,V> t = (TreeBin<K,V>)f;
                            TreeNode<K,V> lo = null, loTail = null;
                            TreeNode<K,V> hi = null, hiTail = null;
                            int lc = 0, hc = 0;
                            //构造正序和反序两个链表
                            for (Node<K,V> e = t.first; e != null; e = e.next) {
                                int h = e.hash;
                                TreeNode<K,V> p = new TreeNode<K,V>
                                    (h, e.key, e.val, null, null);
                                if ((h & n) == 0) {
                                    if ((p.prev = loTail) == null)
                                        lo = p;
                                    else
                                        loTail.next = p;
                                    loTail = p;
                                    ++lc;
                                }
                                else {
                                    if ((p.prev = hiTail) == null)
                                        hi = p;
                                    else
                                        hiTail.next = p;
                                    hiTail = p;
                                    ++hc;
                                }
                            }
                            //如果扩容后已经不再需要tree的结构 反向转换为链表结构
                            ln = (lc <= UNTREEIFY_THRESHOLD) ? untreeify(lo) :
                                (hc != 0) ? new TreeBin<K,V>(lo) : t;
                            hn = (hc <= UNTREEIFY_THRESHOLD) ? untreeify(hi) :
                                (lc != 0) ? new TreeBin<K,V>(hi) : t;
                             //在nextTable的i位置上插入一个链表    
                            setTabAt(nextTab, i, ln);
                            //在nextTable的i+n的位置上插入另一个链表
                            setTabAt(nextTab, i + n, hn);
                             //在table的i位置上插入forwardNode节点  表示已经处理过该节点
                            setTabAt(tab, i, fwd);
                            //设置advance为true 返回到上面的while循环中 就可以执行i--操作
                            advance = true;
                        }
                    }
                }
            }
        }
    }
```
扩容过程有点复杂，这里主要涉及到多线程并发扩容,实在看不懂也没关系 ，只要记住结论就行。ForwardingNode的作用就是支持扩容操作，将已处理的节点和空节点置为ForwardingNode，并发处理时多个线程经过ForwardingNode就表示已经遍历了，就往后遍历。















