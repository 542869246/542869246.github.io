---
title: hashCode()和hash算法的那些事儿
copyright: true
top: 95
date: 2018-12-06 10:10:20
categories: [java]
tags: [java,hash,HashMap]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/12563.jpg?x-oss-process=style/ys30
description: 解析String和HashMap中hash算法
---

<span></span>

<!--more-->

## 热身
读这篇文章之前，先回顾下常用的几个位运算。大概了解一下就好了，因为位运算平时在项目里真的用不上，在我们普通的业务项目里，代码易读性比这点位运算性能要重要的多。但是，在框架中，位运算的必要性就显示出来的了。因为需要服务大量的运算，性能要求也极高，如果性能渣渣，谁还用你？

```java
<< : 左移运算符，num << 1,相当于num乘以2  低位补0
>> : 右移运算符，num >> 1,相当于num除以2  高位补0
>>> : 无符号右移，无论是正数还是负数，高位通通补0
% : 模运算 取余
^ : 位异或 第一个操作数的的第n位于第二个操作数的第n位相反，那么结果的第n为也为1，否则为0
& : 与运算 第一个操作数的的第n位于第二个操作数的第n位如果都是1，那么结果的第n为也为1，否则为0
| : 或运算 第一个操作数的的第n位于第二个操作数的第n位 只要有一个是1，那么结果的第n为也为1，否则为0
~ : 非运算 操作数的第n位为1，那么结果的第n位为0，反之，也就是取反运算（一元操作符：只操作一个数）
```

## 定义
百度百科copy来一段：
> Hash，一般翻译做“散列”，也有直接音译为“哈希”的，就是把任意长度的输入（又叫做预映射pre-image）通过散列算法变换成固定长度的输出，该输出就是散列值。这种转换是一种压缩映射，也就是，散列值的空间通常远小于输入的空间，不同的输入可能会散列成相同的输出，所以不可能从散列值来确定唯一的输入值。简单的说就是一种将任意长度的消息压缩到某一固定长度的消息摘要的函数。

## String的hashCode()
首先看源码：
```java


 /** The value is used for character storage. */
	//String 类是通过该数组来存在字符串的
    private final char value[];

    /** Cache the hash code for the string */
	//用来存放 String 对象的 hashCode。
    private int hash; // Default to 0

    /**
     * Returns a hash code for this string. The hash code for a
     * {@code String} object is computed as
     * <blockquote><pre>
     * s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]
     * </pre></blockquote>
     * using {@code int} arithmetic, where {@code s[i]} is the
     * <i>i</i>th character of the string, {@code n} is the length of
     * the string, and {@code ^} indicates exponentiation.
     * (The hash value of the empty string is zero.)
     *
     * @return  a hash code value for this object.
     */
    public int hashCode() {
        int h = hash;
        if (h == 0 && value.length > 0) {
            char val[] = value;

            for (int i = 0; i < value.length; i++) {
                h = 31 * h + val[i];
            }
            hash = h;
        }
        return h;
    }

```

接下来分析 hashCode() 的实现逻辑如下：

### 判定条件
首先根据判断条件`h == 0 && value.length > 0`得知如果hash值不等于0且value.length 大于 0才会进行hash计算

Q：为什么需要`h==0`?
A：
h 是一个 int 类型的值，默认值为 0，因此 0 可以表示可能未执行过 hash 计算，但不能表示一定未执行过 hash 计算，原因是我们现在还不确定 hash 计算后是否会产生 0 值。

那么执行hash计算之后，会不会产生0值的hash呢？根据 hash 的计算逻辑，当 `val[0] = 0` 时，根据公式 `h = 31 * h + val[i];` 进行计算， h 的值等于 0。

`val[0] = 0` 怎么解释呢？查看 ASCII 表发现， null 的 ASCII 值为 0 。显然 val[0]中永远不可能存放 null，因此 hash 计算后不会产生 0 值， h == 0 可以作为是否进行过 hash 计算的判定条件。

Q：为什么需要`value.length > 0`?
A：很简单了，字符串的长度为 0 ，不进行 hash 计算。

### 计算公式

```java
char val[] = value;

for (int i = 0; i < value.length; i++) {
	h = 31 * h + val[i];
}
hash = h;
```
上面的代码就是 String hashCode() 方法的实现，是不是很简单。实际上 hashCode 方法核心的计算逻辑只有这三行，也就是代码中的 for 循环。我们可以由上面的 for 循环推导出一个计算公式，hashCode 方法注释中已经给出。如下：
```
s[0]*31^(n-1) + s[1]*31^(n-2) + … + s[n-1]
```
这里说明一下，上面的 s 数组即源码中的 val 数组，是 String 内部维护的一个 char 类型数组。

这里简单模拟下hash计算步骤：
```java
String name = "felix";

//初始化
value = {'f','e','l','i','x'};
hash = 0;
value.length = 5;

val = value;
val[0] = "f";
val[1] = "e";
val[2] = "l";
val[3] = "i";
val[4] = "x";

h = 31 * 0 + f = f;
h = 31 * (31 * 0 + f) + e = 31 * f + e;
h = 31 * (31 * (31 * 0 + f) + e) + l = 31 * 31 * f * 31 * e + l
...

```

那么问题来了，为啥要`* 31`呢？？32，99，2不行吗？

这个问题StackOverflow上也有讨论 可以去参考参考[https://stackoverflow.com/questions/299304/why-does-javas-hashcode-in-string-use-31-as-a-multiplier](https://stackoverflow.com/questions/299304/why-does-javas-hashcode-in-string-use-31-as-a-multiplier)

在名著 《Effective Java》第 42 页就有对 hashCode 为什么采用 31 做了说明：

> The value 31 was chosen because it is an odd prime. If it were even and the multiplication overflowed, information would be lost, as multiplication by 2 is equivalent to shifting. The advantage of using a prime is less clear, but it is traditional. A nice property of 31 is that the multiplication can be replaced by a shift and a subtraction for better performance: `31 * i == (i << 5) - i`. Modern VMs do this sort of optimization automatically.

简单翻译一下：
> 选择数字31是因为它是一个奇质数，如果选择一个偶数会在乘法运算中产生溢出，导致数值信息丢失，因为乘二相当于移位运算。选择质数的优势并不是特别的明显，但这是一个传统。同时，数字31有一个很好的特性，即乘法运算可以被移位和减法运算取代，来获取更好的性能：`31 * i == (i << 5) - i`，现代的 Java 虚拟机可以自动的完成这个优化

排名第二的答案设这样说的：
> As Goodrich and Tamassia point out, If you take over 50,000 English words (formed as the union of the word lists provided in two variants of Unix), using the constants 31, 33, 37, 39, and 41 will produce less than 7 collisions in each case. Knowing this, it should come as no surprise that many Java implementations choose one of these constants.

简单翻译一下：
> 正如 Goodrich 和 Tamassia 指出的那样，如果你对超过 50,000 个英文单词（由两个不同版本的 Unix 字典合并而成）进行 hash code 运算，并使用常数 31, 33, 37, 39 和 41 作为乘子，每个常数算出的哈希值冲突数都小于7个，所以在上面几个常数中，常数 31 被 Java 实现所选用也就不足为奇了。

总结下大佬们的话：主要是因为31是一个奇质数，转为二进制为`11111`，在进行乘法运算时，可以转换为 `(x << 5) - x` 。所以`31*i=32*i-i=(i<<5)-i`，这种位移与减法结合的计算相比一般的运算快很多，性能更好。

## HashMap的hash
好了，知道了 hashCode 的生成原理了，我们要看看今天的主角，hash 算法
基于jdk1.8的HashMap 的 hash 算法：
```java
    /**
     * Computes key.hashCode() and spreads (XORs) higher bits of hash
     * to lower.  Because the table uses power-of-two masking, sets of
     * hashes that vary only in bits above the current mask will
     * always collide. (Among known examples are sets of Float keys
     * holding consecutive whole numbers in small tables.)  So we
     * apply a transform that spreads the impact of higher bits
     * downward. There is a tradeoff between speed, utility, and
     * quality of bit-spreading. Because many common sets of hashes
     * are already reasonably distributed (so don't benefit from
     * spreading), and because we use trees to handle large sets of
     * collisions in bins, we just XOR some shifted bits in the
     * cheapest possible way to reduce systematic lossage, as well as
     * to incorporate impact of the highest bits that would otherwise
     * never be used in index calculations because of table bounds.
     */
    static final int hash(Object key) {
        int h;
        return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
    }

```
代码很少是不是，也就是三元运行判断非空，不为空就就行无符号右移和异或运算，返回算出的hash值。但是没什么要无符号右移呢？为什么偏偏右移16位呢？为什么要用异或运算呢？？

咋们先看看HashMap的put实现源码
```java
final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
        Node<K,V>[] tab; Node<K,V> p; int n, i;
        if ((tab = table) == null || (n = tab.length) == 0)
            n = (tab = resize()).length;
        if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
        else {
            Node<K,V> e; K k;
            if (p.hash == hash &&
                ((k = p.key) == key || (key != null && key.equals(k))))
                e = p;
            else if (p instanceof TreeNode)
                e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
            else {
                for (int binCount = 0; ; ++binCount) {
                    if ((e = p.next) == null) {
                        p.next = newNode(hash, key, value, null);
                        if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                            treeifyBin(tab, hash);
                        break;
                    }
                    if (e.hash == hash &&
                        ((k = e.key) == key || (key != null && key.equals(k))))
                        break;
                    p = e;
                }
            }
            if (e != null) { // existing mapping for key
                V oldValue = e.value;
                if (!onlyIfAbsent || oldValue == null)
                    e.value = value;
                afterNodeAccess(e);
                return oldValue;
            }
        }
        ++modCount;
        if (++size > threshold)
            resize();
        afterNodeInsertion(evict);
        return null;
    }

```
此处不解析HashMap的put、get等操作，留着以后专门开一篇。
注意putVal()里面的第二个if判断
```java
 if ((p = tab[i = (n - 1) & hash]) == null)
            tab[i] = newNode(hash, key, value, null);
```
这点代码的意思是根据hash值算出该key所在的数组下标，n为buckets的长度。如果为null，就把值填进去。

ok，也就是说，HashMap里面先把key作hash()运算，得出的hash再进行`(n - 1) & hash`运算，得到的结果即是数组的下标。

那么问题又来了，为啥需要`n - 1`（数组长度 - 1）呢？

大家都知道，HashMap的底层数组长度总是为2的整次幂。什么？你不知道？？你说你这样初始化HashMap`new HashMap(5)`他的长度不就是不为2的整次幂了吗？？我敢打赌兄弟你肯定没看仔细看HashMap源码，这里我就不说为什么了，留着以后讲，一篇文章全说完了以后写什么呀。此处给个小提示`tableSizeFor()`

ok,现在你知道HashMap的底层数组长度总是为2的整次幂了，数组长度 - 1 正好形成了一个`分布均匀有效低位掩码`。以长度16为例，16二进制为10000，那么16 - 1的结果为`01111`，形成了一个低 4 位掩码，和哈希值做与运算，相当于截取哈希值的低 4 位。

下面我们以值为"felix"的 Key 来演示整个过程：
1. 计算 felix 的 hashcode，`Integer.toBinaryString("felix".hashCode())`结果为十进制的 97315196，二进制的10111001100111010010111 1100。 
2. 假定 HashMap 长度是默认的16，计算Length-1的结果为十进制的15，二进制的1111。 
3. 把以上两个结果做与运算，10111001100111010010111 1100 & 1111 = 1100，十进制是12，所以 index=12。



假设 HashMap 的长度是10，重复刚才的运算步骤：

| HashCode | 101 1100 1100 1110 1001 0111 1100 |
|:--------:|----------------------------------:|
| length-1 |                              1001 |
|   index  |                              1000 |

单独看这个结果，表面上并没有问题。我们再来尝试一个新的 HashCode 101 1100 1100 1110 1001 0111 1011 ：

| HashCode | 101 1100 1100 1110 1001 0111 1011 |
|:--------:|----------------------------------:|
| length-1 |                              1001 |
|   index  |                              1001 |

让我们再换一个 HashCode  101 1100 1100 1110 1001 0111 1111 试试 ：

| HashCode | 101 1100 1100 1110 1001 0111 1111 |
|:--------:|----------------------------------:|
| length-1 |                              1001 |
|   index  |                              1001 |

再换一个 HashCode  101 1100 1100 1110 1001 0111 1001 ：

| HashCode | 101 1100 1100 1110 1001 0111 1001 |
|:--------:|----------------------------------:|
| length-1 |                              1001 |
|   index  |                              1001 |

可以说，Hash 算法最终得到的 index 结果，完全取决于 Key 的 Hashcode 值的`最后几位`。
所以，当 HashMap 长度为10的时候，有些index结果的出现几率会更大，而有些index结果永远不会出现（比如0111）！造成了大部分的值都存储到了相同的位置。（即当低位存在某种规律的重复，容易造成极大的哈希冲突），于是，明明key相差很大的pair，却存放在了同一个链表里，导致以后查询起来比较慢。这样，显然不符合Hash算法`均匀分布`的原则。更要命的是如果散列本身做得不好，分布上成等差数列的漏洞，恰好使最后几个低位呈现规律性重复，就无比蛋疼。

为了解决该问题，JDK 1.8 后，在计算哈希值时引入了 `扰动函数`：`key.hashCode()) ^ (h >>> 16)`!

把HashMap的hash分解开来，如看下图：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/59497ea7e76b887ee3dd46b1875610f1.jpg)

右位移16位，正好是32bit的一半，自己的高半区和低半区做异或，就是为了**混合原始哈希码的高位和低位，以此来加大低位的随机性**。而且混合后的低位掺杂了高位的部分特征，这样高位的信息也被变相保留下来。

是不是晕了？这样，举个小栗子吧
创建一个HashMap，其entry数组为默认大小16
现在有一个pair需要存储到该HashMap里面，其key的hashcode为0ABC0000，如果不经过hash函数处理这个hashcode，这个pair过会儿将会被存放在entry数组中下标为0处。下标=ABCD0000 & (16-1) = 0。
然后我们又要存储另外一个pair，其key的hashcode是0DEF0000，得到数组下标依然是0。想必你已经看出来了，这是个实现得很差的hash算法，因为hashcode的1位全集中在前16位了，导致算出来的数组下标一直是0。于是，明明key相差很大的pair，却存放在了同一个链表里，导致以后查询起来比较慢。
hash函数的通过若干次的移位、异或操作，把hashcode的“1位”变得“松散”，比如，经过hash函数处理后，0ABC0000变为A02188B，0DEF0000变为D2AFC70，他们的数组下标不再是清一色的0了。


> 总之，一切因为效率

