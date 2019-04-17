---
title: CAS机制是什么鬼？
copyright: true
top: 95
date: 2018-12-17 14:08:28
categories: [java]
tags: [java,CAS,JUC]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/12638.jpg?x-oss-process=style/ys30
description: CAS是现在面试经常问的问题，本文将深入的介绍CAS的原理。
---

<span></span>

<!--more-->

本来这篇文章想写ConcurrentHashMap的，看了看源码，其中使用了大量的CAS操作，就准备单独开一篇关于CAS的文章，讲解下CAS机制。

## 概述
> 比较并交换(compare and swap, CAS)，是原子操作的一种，可用于在多线程编程中实现不被打断的数据交换操作，从而避免多线程同时改写某一数据时由于执行顺序不确定性以及中断的不可预知性产生的数据不一致问题。 该操作通过将内存中的值与指定数据进行比较，当数值一样时将内存中的数据替换为新的值。

大家都知道悲观锁、乐观锁吧？这里的悲观锁、乐观锁指的是线程方面的锁，不是数据库方面的锁。其实CAS机制就是乐观锁。
synchronized操作就是一种悲观锁，这种线程一旦得到锁，其他需要锁的线程就挂起，等待持有锁的线程释放锁。当一个线程正在等待锁时，它不能做任何事，所以悲观锁有很大的缺点。

乐观锁的核心思路就是**每次不加锁而是假设修改数据之前其他线程一定不会修改，如果因为修改过产生冲突就失败就重试，直到成功为止。**CAS机制就是一种。可以理解成一个**无阻塞**多线程争抢资源的模型

**CAS 操作包含三个操作数 —— 内存地址（V）、旧的预期值（A）和即将要更新的新值(B)。执行CAS操作的时候，将内存位置的值与预期原值比较，如果相匹配，那么处理器会自动将该位置值更新为新值。否则，处理器不做任何操作。**

画个图演示下吧
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/CAS.jpg)

理解CAS的核心就是：CAS是原子性的，虽然你可能看到比较后再修改(compare and swap)觉得会有两个操作，但终究是原子性的！

## ++、- -问题
`volatile`关键字大家很眼熟吧？HashMap源码、双重检测机制实现单例等场景都出现过它的身影。这里我就不详细介绍`volatile`关键字，因为要说的太多了，说到`volatile`就要说到JMM，说到JMM就要说原子性、有序性、一致性，然后又涉及到处理器优化、指令重排等等，可以扯个几小时。其实这也是为什么面试官喜欢问HashMap的问题，因为可以深度挖掘的东西太多了，可以直接看出面试者的深浅。[这篇文章](https://542869246.github.io/2018/11/01/%E5%86%8D%E6%9C%89%E4%BA%BA%E9%97%AE%E4%BD%A0Java%E5%86%85%E5%AD%98%E6%A8%A1%E5%9E%8B%E6%98%AF%E4%BB%80%E4%B9%88-%E5%B0%B1%E6%8A%8A%E8%BF%99%E7%AF%87%E6%96%87%E7%AB%A0%E5%8F%91%E7%BB%99%E4%BB%96/ "这篇文章")大概讲了下JMM，可以看下。好了，扯远了，回归文章。。。

`volatile`关键字主要是保证能`禁止指令重排序`和保证`可见性`，但是要注意，这并不能保证`原子性`！

看代码：
```java
public class Cases {
	public static volatile int n;

	public static void add() {
		n++;
	}

	public static void main(String[] args) throws InterruptedException {

		ExecutorService service = Executors.newCachedThreadPool();
		// 20个线程对共享变量进行add()
		for (int i = 0; i < 20; i++) {
			service.execute(() -> {
				for (int j = 0; j < 1000; j++) {
					add();
				}
			});
		}
		// 等待上述的线程执行完
		service.shutdown();
		service.awaitTermination(1, TimeUnit.DAYS);

		System.out.println(n);
	}

}
```
这段代码创建20个线程，每个线程对n变量进行1000次自增，如果这段代码能够正确并发的话，最后输出的结果应该是20000。但是，运行结果每次都是一个小于20000的数字。为什么呢？

问题就出现在`n++`这个自增操作上面。我们用Javap反编译：
cmd里面进入该类路径，输入`javac Cases.java`编译成class文件后，再输入指令`javap -verbose Cases`，查看add方法的字节码指令
贴出部分：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20181217162623.png)

n++被拆分成了几个指令：

1. 执行getfield拿到原始n；
2. 执行iadd进行加1操作；
3. 执行putfield写把累加后的值写回n；

通过`volatile`修饰的变量可以保证线程之间的可见性，但`n++`这个操作并不是一个指令操作，而是三个，`volatile`并不能保证这3个指令的原子执行，因此在多线程并发执行下，无法做到线程安全。

那么怎么解决呢？大家都知道，在add方法加上synchronized修饰就可以解决。这个方案自然也可以，都是是否有一种杀鸡用牛刀的感觉，就一个简单的自增操作，就要用synchronized来锁起来，性能上差了好多。


## JDK原子变量类简单介绍

看下几个JDK自带的CAS方案：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/JDK%E7%9A%84CAS%E6%96%B9%E6%A1%88.jpg)

*注： JDK8新增DoubleAccumulator、LongAccumulator、DoubleAdder、LongAdder，是对AtomicLong等类的改进。比如LongAccumulator与LongAdder在高并发环境下比AtomicLong更高效。*


## 原子变量类使用

使用原子变量类更改之前的案例
```java
public class Cases {
	// 共享变量(使用AtomicInteger来替代Synchronized锁)
	public static AtomicInteger count = new AtomicInteger(0);

	public static void add() {
		count.incrementAndGet();
	}

	public static void main(String[] args) throws InterruptedException {

		ExecutorService service = Executors.newCachedThreadPool();
		// 20个线程对共享变量进行add()
		for (int i = 0; i < 20; i++) {
			service.execute(() -> {
				for (int j = 0; j < 1000; j++) {
					add();
				}
			});
		}
		// 等待上述的线程执行完
		service.shutdown();
		service.awaitTermination(1, TimeUnit.DAYS);

		System.out.println(count);
	}

}
```
修改完，无论执行多少次，我们的结果永远是20000！

其余几个原子变量类就不演示了，使用方法差不多，可以自行看看API，百度。

## CAS缺陷

### 循环时间长开销大
自旋CAS如果长时间不成功，会给CPU带来非常大的执行开销。


### 只能保证一个共享变量的原子操作
当对一个共享变量执行操作时，我们可以使用循环CAS的方式来保证原子操作，但是对多个共享变量操作时，循环CAS就无法保证操作的原子性，这个时候就可以用锁，或者有一个取巧的办法，就是把多个共享变量合并成一个共享变量来操作。比如有两个共享变量i＝2,j=a，合并一下ij=2a，然后用CAS来操作ij。从Java1.5开始JDK提供了AtomicReference类来保证引用对象之间的原子性，你可以把多个变量放在一个对象里来进行CAS操作。

### ABA问题
如果内存地址V初次读取的值是A，并且在准备赋值的时候检查到它的值仍然为A，那我们就能说它的值没有被其他线程改变过了吗？

如果在这段期间它的值曾经被改成了B，后来又被改回为A，那CAS操作就会误认为它从来没有被改变过。这个漏洞称为CAS操作的“ABA”问题。

ABA问题的解决思路就是使用版本号。在变量前面追加上版本号，每次变量更新的时候把版本号加一，那么A－B－A 就会变成1A-2B－3A。从Java1.5开始JDK的atomic包里提供了一个类`AtomicStampedReference`来解决ABA问题。这个类的`compareAndSet`方法作用是首先检查当前引用是否等于预期引用，并且当前标志是否等于预期标志，如果全部相等，则以原子方式将该引用和该标志的值设置为给定的更新值。

因此，在使用CAS前要考虑清楚“ABA”问题是否会影响程序并发的正确性，如果需要解决ABA问题，改用传统的互斥同步可能会比原子类更高效。


