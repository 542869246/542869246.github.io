---
title: HashMap扫盲
copyright: true
top: 95
date: 2018-12-07 14:27:37
categories: [java]
tags: [java,hash,HashMap]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/59f7d76d99a79.jpg?x-oss-process=style/ys30
description: HashMap扫盲
---

<span></span>

<!--more-->

上一篇文章 [hashCode-和hash算法的那些事儿](https://542869246.github.io/2018/12/06/hashCode-%E5%92%8Chash%E7%AE%97%E6%B3%95%E7%9A%84%E9%82%A3%E4%BA%9B%E4%BA%8B%E5%84%BF/ "hashCode()和hash算法的那些事儿")  详细讲解了hash算法，其中挖了几个小坑，在这篇来填坑。

## HashMap的底层数组长度总是为2的整次幂？

首先咋们先创建一个HashMap
```java
Map map = new HashMap(16);
```
将会执行HashMap的一个有参构造：
```java
	public HashMap(int initialCapacity) {
        this(initialCapacity, DEFAULT_LOAD_FACTOR);
    }
```
然后调用`this(initialCapacity, DEFAULT_LOAD_FACTOR);`,`DEFAULT_LOAD_FACTOR`默认为0.75f。如下：
```java
    public HashMap(int initialCapacity, float loadFactor) {
        if (initialCapacity < 0)
            throw new IllegalArgumentException("Illegal initial capacity: " +
                                               initialCapacity);
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        if (loadFactor <= 0 || Float.isNaN(loadFactor))
            throw new IllegalArgumentException("Illegal load factor: " +
                                               loadFactor);
        this.loadFactor = loadFactor;
        this.threshold = tableSizeFor(initialCapacity);
    }
```
第一个if简单判断长度。
第二个判断的是`initialCapacity`如果大于`MAXIMUM_CAPACITY`的话，就等于`MAXIMUM_CAPACITY`，`MAXIMUM_CAPACITY`是HashMap指定的一个最大容量，值为`1<<30`，1左移30，就是1*2的30次方，值为1073741824。为什么是30次方呢？因为如果是31的话就是负数`-2147483648`了，`1<<30`是最接近int的最大值的。
第三个判断也简单不说了。

注意`this.threshold = tableSizeFor(initialCapacity);`这里调用了`tableSizeFor`方法

来看下`tableSizeFor`方法实现：
```java
    static final int tableSizeFor(int cap) {
        int n = cap - 1;
        n |= n >>> 1;
        n |= n >>> 2;
        n |= n >>> 4;
        n |= n >>> 8;
        n |= n >>> 16;
        return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
    }
```
新手可能看到这一脸懵逼，哎呀这啥啊，怎么那么多无符号右移运算，或运算？？
别急，一步一步来。

假设咋们初始化大小为17，把值代入：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/tableSizeFor.jpg)

可以看到返回32

再测试其它几个数字吧
```java
		int[] arr = {1,12,16,17,23,33,43,54,67,344};
		for (int i = 0; i < arr.length; i++) {
			System.out.print(tableSizeFor(arr[i]) + " ");
		}
```
结果：
```java
1 16 16 32 32 64 64 64 128 512 

```

观察该结果，我们发现这些数字都是`2的n次幂`，并且，返回的结果还是离该整数`最近的2次幂`。比如cap=17，离它最近的2次幂是32；cap=43，离它最近的2次幂是64；cap=16，离它最近的2次幂是16，即本身。

所以，咋们初始化HashMap的时候，你给它指定的长度不管是奇数还是偶数，经过tableSizeFor方法后，都会重新赋值为离该整数`最近的2次幂`。

## HashMap到底是什么时候初始化的？

当你在敲下代码
```java
Map map = new HashMap(16);
```
的时候，你以为这个map初始化了吗？贴下构造方法：
```java
    public HashMap(int initialCapacity, float loadFactor) {
        if (initialCapacity < 0)
            throw new IllegalArgumentException("Illegal initial capacity: " +
                                               initialCapacity);
        if (initialCapacity > MAXIMUM_CAPACITY)
            initialCapacity = MAXIMUM_CAPACITY;
        if (loadFactor <= 0 || Float.isNaN(loadFactor))
            throw new IllegalArgumentException("Illegal load factor: " +
                                               loadFactor);
        this.loadFactor = loadFactor;
        this.threshold = tableSizeFor(initialCapacity);
    }

    public HashMap(int initialCapacity) {
        this(initialCapacity, DEFAULT_LOAD_FACTOR);
    }

    public HashMap() {
        this.loadFactor = DEFAULT_LOAD_FACTOR; // all other fields defaulted
    }
```
很明显构造方法里面并没有对这个map初始化，即使你指的了长度为16，它也仅仅是将这个数字先进行`tableSizeFor`函数运算再保存！！

那么什么时候才会初始化呢？答案是添加操作。

```java
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
			
			...
		
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }
```
可以看到第一个if判断，table为null的时候，调用`resize()`方法，去初始化table

看下resize：
```java
    final Node<K,V>[] resize() {
        Node<K,V>[] oldTab = table; // table就是buckets数组
        int oldCap = (oldTab == null) ? 0 : oldTab.length;
        int oldThr = threshold;
        int newCap, newThr = 0;
		// oldCap大于0，进行扩容，设置阈值与新的容量	
        if (oldCap > 0) {
            if (oldCap >= MAXIMUM_CAPACITY) {
                threshold = Integer.MAX_VALUE;
                return oldTab;
            }
            else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                     oldCap >= DEFAULT_INITIAL_CAPACITY)
                newThr = oldThr << 1; // double threshold
        }
		// oldCap = 0，oldThr大于0，那么就把阈值做为新容量以进行初始化
    	// 这种情况发生在用户调用了带有参数的构造函数（会对threshold进行初始化）
        else if (oldThr > 0) // initial capacity was placed in threshold
            newCap = oldThr;
    	// oldCap与oldThr都为0，这种情况发生在用户调用了无参构造函数
    	// 采用默认值进行初始化
        else {               // zero initial threshold signifies using defaults
            newCap = DEFAULT_INITIAL_CAPACITY;
            newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
        }
        if (newThr == 0) {
            float ft = (float)newCap * loadFactor;
            newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                      (int)ft : Integer.MAX_VALUE);
        }
        threshold = newThr;
		//创建
        @SuppressWarnings({"rawtypes","unchecked"})
            Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
        table = newTab;
        if (oldTab != null) {
            
			...

        }
        return newTab;
    }

```
看代码我们可以知道，当调用`new HashMap(16)`时，会走`oldThr > 0`这个分支；调用`new HashMap()`时，会走`else`分支，然后执行`Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];`完成初始化，返回newTab。

> 所以，HashMap初始化是在第一次put元素的时候进行的。


## JDK1.8HashMap存储结构做了哪些优化？

### 1.8之前
存储结构采用的是数组与链表相结合的方式，数组存储的是链表的链头，链接下一个节点。存储方式如下图所见。也即是哈希拉链法，该设计方式旨在解决哈希冲突（碰撞），哈希值相同时，存储于同一条链表。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/JDK1.7%20HashMap.jpg)

### 1.8 
引入了红黑树，当链表长度大于一定阈值时，将链表转换为红黑树，结构如下。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/JDK1.8%20HashMap.jpg)

使用红黑树的原因主要是随着数据越来越多，hash冲突也越来越多，原先的链表也越来越长，查询也越来越慢，因此引入红黑树结构，红黑树能够以O(log2(N))的时间复杂度进行搜索、插入、删除操作，效率可以得到很大的提升。

查看默认阈值情况如下源码，默认树化的阈值为 8，而链表化的阈值为 6。
```java
    /**
     * The bin count threshold for using a tree rather than list for a
     * bin.  Bins are converted to trees when adding an element to a
     * bin with at least this many nodes. The value must be greater
     * than 2 and should be at least 8 to mesh with assumptions in
     * tree removal about conversion back to plain bins upon
     * shrinkage.
     */
    static final int TREEIFY_THRESHOLD = 8;

    /**
     * The bin count threshold for untreeifying a (split) bin during a
     * resize operation. Should be less than TREEIFY_THRESHOLD, and at
     * most 6 to mesh with shrinkage detection under removal.
     */
    static final int UNTREEIFY_THRESHOLD = 6;
```

## JDK1.8HashMap添加操作优化

### 1.8之前：
```java
public V put(K key, V value) {
     if (key == null)
         return putForNullKey(value);
     int hash = hash(key.hashCode());
     int i = indexFor(hash, table.length);
     for (Entry<K,V> e = table[i]; e != null; e = e.next) {
         Object k;
         if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
             V oldValue = e.value;
             e.value = value;
             e.recordAccess(this);
             return oldValue;
         }
     }
     modCount++;
     addEntry(hash, key, value, i);
     return null;
}
```
操作过程：
1. 根据key计算hash
2. 根据hash计算下标
3. 若该链头为空，则创建节点，插入该值作为链头。
4. 若链头不为空，则遍历该链表，通过验证哈希值 与 key.equals(k) 相结合的验证方式寻找 key 值节点。并且，该结合方式也有助于减少验证的计算，因为哈希不相等必定键值不相等，相等才通过 equals 函数验证。
 4.1 若找到该键值，则修改对应值。
 4.2 否则，在链头插入该值节点。

### 1.8之后：put 函数的底层由 putVal 实现

```java
    final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
		 // 第一次调用put()，初始化table
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
		// 没有发生碰撞，直接放入到数组
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
			// 发生碰撞（头节点就是目标节点）
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
			// 节点为红黑树
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
			// 节点为链表
            else {
                for (int binCount = 0; ; ++binCount) {
					// 未找到目标节点，在链表尾部链接新节点
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
							 // 链表过长，转换为红黑树
                            treeifyBin(tab, hash);
                        break;
                    }
					// 找到目标节点，退出循环
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
			// 节点已存在，替换value
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
		// 超过临界值，进行扩容
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }

```

操作过程：
1. 数组是否为null，为null就就行`resize()`
2. 判断该哈希值对应的下标地址是否为空，如果为空，则插入该值作为新节点。
3. 判断该链头是否哈希值相等且键值相等，若是，则修改该节点的值。
4. 否则，验证该节点是否为红黑树，若是，进行 `putTreeVal` 操作插入到红黑树中。
5. 若不是红黑树，即是链表，则与 JDK 1.8 之前插入方式相同（如上所述）。


## 扩容操作

HashMap的容量超过当前数组长度(DEFAULT_INITIAL_CAPACITY)*加载因子(DEFAULT_LOAD_FACTOR)，就会执行resize()算法。假设初始长度为16，加载因子默认为0.75，`16*0.75=12`,当HashMap容量超过12时，就会执行扩容操作。长度是原来的两倍（旧的长度左移一位），并且将原来的HashMap数组的节点转换到新的数组。

```java
    final Node<K,V>[] resize() {
		// table就是buckets数组
        Node<K,V>[] oldTab = table;
        int oldCap = (oldTab == null) ? 0 : oldTab.length;
        int oldThr = threshold;
        int newCap, newThr = 0;
        if (oldCap > 0) {
			// 超过最大值不会进行扩容，并且把阈值设置成Interger.MAX_VALUE
            if (oldCap >= MAXIMUM_CAPACITY) {
                threshold = Integer.MAX_VALUE;
                return oldTab;
            }
			// 没超过最大值，扩容为原来的2倍
        	// 向左移1位等价于乘2
            else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                     oldCap >= DEFAULT_INITIAL_CAPACITY)
                newThr = oldThr << 1; // double threshold
        }
		// oldCap = 0，oldThr大于0，那么就把阈值做为新容量以进行初始化
	    // 这种情况发生在用户调用了带有参数的构造函数（会对threshold进行初始化）
        else if (oldThr > 0) // initial capacity was placed in threshold
            newCap = oldThr;
		// oldCap与oldThr都为0，这种情况发生在用户调用了无参构造函数
    	// 采用默认值进行初始化
        else {               // zero initial threshold signifies using defaults
            newCap = DEFAULT_INITIAL_CAPACITY;
            newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
        }
		// 如果newThr还没有被赋值，那么就根据newCap计算出阈值
        if (newThr == 0) {
            float ft = (float)newCap * loadFactor;
            newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                      (int)ft : Integer.MAX_VALUE);
        }
        threshold = newThr;
        @SuppressWarnings({"rawtypes","unchecked"})
            Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
        table = newTab;
		// 如果oldTab != null，代表这是扩容操作
   		// 需要将扩容前的数组数据迁移到新数组
        if (oldTab != null) {
			// 遍历oldTab的每一个bucket，然后移动到newTab
            for (int j = 0; j < oldCap; ++j) {
                Node<K,V> e;
                if ((e = oldTab[j]) != null) {
                    oldTab[j] = null;
					// 索引j的bucket只有一个Entry（未发生过碰撞）
                	// 直接移动到newTab
                    if (e.next == null)
                        newTab[e.hash & (newCap - 1)] = e;
					// 如果是一个树节点（代表已经转换成红黑树了）
                	// 那么就将这个节点拆分为lower和upper两棵树
                	// 首先会对这个节点进行遍历
                	// 只要当前节点的hash & oldCap == 0就链接到lower树
                	// 注意这里是与oldCap进行与运算，而不是oldCap - 1(n - 1)
                	// oldCap就是扩容后新增有效位的掩码
                	// 比如oldCap=16，二进制10000，n-1 = 1111，扩容后的n-1 = 11111
                	// 只要hash & oldCap == 0，就代表hash的新增有效位为0
                	// 否则就链接到upper树（新增有效位为1）
                	// lower会被放入newTab[原索引j]，upper树会被放到newTab[原索引j + oldCap]
                	// 如果lower或者upper树的节点少于阈值，会被退化成链表
                    else if (e instanceof TreeNode)
                        ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                    else { // preserve order
						// 下面操作的逻辑与分裂树节点基本一致
                    	// 只不过split()操作的是TreeNode
                    	// 而且会将两条TreeNode链表组织成红黑树
                        Node<K,V> loHead = null, loTail = null;
                        Node<K,V> hiHead = null, hiTail = null;
                        Node<K,V> next;
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
                        if (loTail != null) {
                            loTail.next = null;
                            newTab[j] = loHead;
                        }
                        if (hiTail != null) {
                            hiTail.next = null;
                            newTab[j + oldCap] = hiHead;
                        }
                    }
                }
            }
        }
        return newTab;
    }
```

了解了以上几个操作，再看下put()操作流程图回顾下： 
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/2950e97a1fc7a9dc71a5d67833620b2c.jpg)















