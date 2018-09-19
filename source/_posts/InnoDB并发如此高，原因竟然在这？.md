---
title: InnoDB并发如此高，原因竟然在这？
top: 95
copyright: true
date: 2018-08-14 18:07:19
categories: [数据库]
tags: [数据库,SQL,InnoDB,MySQL]
image: http://pic1.win4000.com/wallpaper/a/599d24580ffcf.jpg
---

<span></span>
<!--more-->
此文摘自微信公众号【架构师之路】

微信扫一扫
关注该公众号

![](https://mp.weixin.qq.com/mp/qrcode?scene=10000004&size=102&__biz=MjM5ODYxMDA5OQ==&mid=2651961431&idx=1&sn=4f46fbada3d99ca6cf74b305d06c1ac6&send_time=)


《[InnoDB行锁，如何锁住一条不存在的记录？](http://mp.weixin.qq.com/s?__biz=MjM5ODYxMDA5OQ==&mid=2651961431&idx=1&sn=4f46fbada3d99ca6cf74b305d06c1ac6&chksm=bd2d0d8b8a5a849d8cb5a616c957abde7a6485cd2624372b84a5459eed081bd95429a09572f8&scene=21#wechat_redirect)》埋了一个坑，没想到评论反响剧烈，大家都希望深挖下去。原计划写写InnoDB的锁结束这个case，既然呼声这么高，干脆全盘**系统性**的写写InnoDB的**并发控制**，**锁**，**事务模型**好了。



体系相对宏大，一篇肯定写不完，容我娓娓道来，通俗地说清楚来龙去脉。

**一、并发控制**

**为啥要进行并发控制？**

并发的任务对同一个临界资源进行操作，如果不采取措施，可能导致不一致，故必须进行**并发控制**（Concurrency Control）。

  

**技术上，通常如何进行并发控制？**

通过并发控制保证数据一致性的常见手段有：

*   锁（Locking）
    
*   数据多版本（Multi Versioning）
    

**二、锁**

**如何使用普通锁保证一致性？**

普通锁，被使用最多：

(1)<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">操作数据前，锁住，实施互斥</span>，不允许其他的并发任务操作；

(2)操作完成后，释放锁，让其他任务执行；

如此这般，来保证一致性。

  

**普通锁存在什么问题？**

简单的锁住太过粗暴，连“读任务”也无法并行，任务执行过程本质上是串行的。

  

于是出现了**共享锁**与**排他锁**：

*   共享锁（<span style="color: rgb(255, 76, 0);"><strong><span style="letter-spacing: 1px;font-size: 12px;">S</span></strong></span>hare Locks，记为S锁），读取数据时加S锁
    
*   排他锁（e<span style="color: rgb(255, 76, 0);"><strong><span style="letter-spacing: 1px;font-size: 12px;">X</span></strong></span>clusive Locks，记为X锁），修改数据时加X锁
    

共享锁与排他锁的玩法是：

*   <span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">共享锁之间不互斥</span>，简记为：<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">读读可以并行</span>
    
*   <span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">排他锁与任何锁互斥</span>，简记为：<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">写读，写写不可以并行</span>
    

可以看到，一旦写数据的任务没有完成，数据是不能被其他任务读取的，这对并发度有较大的影响。

<span style="color: rgb(0, 82, 255);"><em><span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;">画外音：<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;">对应到数据库，可以理解为，写事务没有提交，读相关数据的</span></span><span style="font-family: 宋体;letter-spacing: 1px;font-size: 12px;">select</span><span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;">也会被阻塞。</span></em></span>

**有没有可能，进一步提高并发呢？**

即使写任务没有完成，其他读任务也可能并发，这就引出了数据多版本。

**三、数据多版本**

<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">数据多版本</span>是一种能够进一步提高并发的方法，它的**核心原理**是：

（1）写任务发生时，将数据克隆一份，以版本号区分；

（2）写任务操作新克隆的数据，直至提交；

（3）并发读任务可以继续读取旧版本的数据，不至于阻塞；

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/222481745858779089.jpg)

如上图：

1. 最开始数据的版本是V0；

2. T1时刻发起了一个写任务，这是把数据clone了一份，进行修改，版本变为V1，但任务还未完成；

3. T2时刻并发了一个读任务，依然可以读V0版本的数据；

4. T3时刻又并发了一个读任务，依然不会阻塞；

可以看到，数据多版本，通过“读取旧版本数据”能够极大提高任务的并发度。

  

提高并发的演进思路，就在如此：

*   **普通锁**，本质是<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">串行</span>执行
    
*   **读写锁**，可以实现<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">读读并发</span>
    
*   **数据多版本**，可以实现<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">读写并发</span>
    

<span style="color: rgb(0, 82, 255);"><em><span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;">画外音：这个思路，比整篇文章的其他技术细节更重要，希望大家牢记。</span></em></span>

  

好，对应到InnoDB上，具体是怎么玩的呢？

**四、redo, undo,****回滚段**

在进一步介绍InnoDB如何使用“读取旧版本数据”极大提高任务的并发度之前，有必要先介绍下redo日志，undo日志，回滚段（rollback segment）。

**为什么要有redo****日志？**

数据库事务提交后，必须将更新后的数据刷到磁盘上，以保证ACID特性。磁盘**随机写**性能较低，如果每次都刷盘，会极大影响数据库的吞吐量。

优化方式是，将修改行为先写到redo日志里（此时变成了**顺序写**），再定期将数据刷到磁盘上，这样能极大提高性能。

<span style="color: rgb(0, 82, 255);"><em><span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;">画外音：这里的架构设计方法是，<strong>随机写优化为顺序写</strong>，思路更重要。</span></em></span>

假如某一时刻，数据库崩溃，还没来得及刷盘的数据，在数据库重启后，会重做redo日志里的内容，以保证已提交事务对数据产生的影响都刷到磁盘上。

**一句话**，<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">redo<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">日志</span></span>用于保障，<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);"><span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">已提交事务的</span>ACID<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">特性</span></span>。

**为什么要有undo****日志？**

数据库事务未提交时，会将事务修改数据的镜像（即修改前的旧版本）存放到undo日志里，当事务回滚时，或者数据库奔溃时，可以利用undo日志，即旧版本数据，撤销未提交事务对数据库产生的影响。

<span style="color: rgb(0, 82, 255);"><em><span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;">画外音：更细节的，</span></em></span>

<span style="color: rgb(0, 82, 255);"><em><span style="color: rgb(0, 82, 255);font-size: 14px;letter-spacing: 1px;"><span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">对于</span><strong>insert<span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">操作</span></strong><span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">，</span>undo<span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">日志记录新数据的</span>PK(ROW_ID)<span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">，回滚时直接删除；</span></span></em></span>

<span style="color: rgb(0, 82, 255);"><em><span style="color: rgb(0, 82, 255);font-size: 14px;letter-spacing: 1px;"><span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">对于</span><strong>delete/update<span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">操作</span></strong><span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">，</span>undo<span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">日志记录旧数据</span>row<span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">，回滚时直接恢复；</span></span></em></span>

<span style="color: rgb(0, 82, 255);"><em><span style="color: rgb(0, 82, 255);font-size: 14px;letter-spacing: 1px;"><span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">他们分别存放在不同的</span>buffer<span style="color: rgb(0, 82, 255);letter-spacing: 1px;font-size: 14px;font-family: 宋体;">里。</span></span></em></span>

**一句话**，<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">undo<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">日志</span></span>用于保障，<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">未提交事务不会对数据库的ACID特性</span>产生影响。

**什么是回滚段？**

存储undo日志的地方，是回滚段。

undo日志和回滚段和InnoDB的MVCC密切相关，这里举个例子展开说明一下。

**栗子**：
```
t(id PK, name);
```
数据为：
```
1, shenjian
2, zhangsan
3, lisi
```
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/854310171767639185.jpg)  

此时没有事务未提交，故回滚段是空的。

接着启动了一个事务：
```
start trx;
delete (1, shenjian);
update set(3, lisi) to (3, xxx);
insert (4, wangwu);
```
并且事务处于<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">未提交</span>的状态。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/76916220599096767.jpg)

可以看到：

(1)被<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">删除前</span>的(1, shenjian)作为旧版本数据，进入了回滚段；

(2)被<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">修改前</span>的(3, lisi)作为旧版本数据，进入了回滚段；

(3)被<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">插入的</span>数据，PK(4)进入了回滚段；

接下来，假如事务rollback，此时可以通过回滚段里的undo日志回滚。

<span style="color: rgb(0, 82, 255);"><em><span style="font-size: 14px;letter-spacing: 1px;"><span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">画外音：假设事务提交，回滚段里的</span>undo<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">日志可以删除。</span></span></em></span>

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/138982544617441980.jpg)

可以看到：

(1)被删除的旧数据恢复了；

(2)被修改的旧数据也恢复了；

(3)被插入的数据，删除了；

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/319830267672366053.jpg)  

事务回滚成功，一切如故。

**四、InnoDB****是基于多版本并发控制的存储引擎**

《[大数据量，高并发量的互联网业务，一定要使用InnoDB](http://mp.weixin.qq.com/s?__biz=MjM5ODYxMDA5OQ==&mid=2651961428&idx=1&sn=31a9eb967941d888fbd4bb2112e9602b&chksm=bd2d0d888a5a849e7ebaa7756a8bc1b3d4e2f493f3a76383fc80f7e9ce7657e4ed2f6c01777d&scene=21#wechat_redirect)》提到，InnoDB是高并发互联网场景最为推荐的存储引擎，根本原因，就是其**多版本并发控制**（Multi Version Concurrency Control, MVCC）。<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">行锁，并发，事务回滚</span>等多种特性都和MVCC相关。

MVCC就是通过“读取旧版本数据”来降低并发事务的锁冲突，提高任务的并发度。

**核心问题：**

**旧版本数据存储在哪里？**

**存储旧版本数据，对MySQL****和InnoDB****原有架构是否有巨大冲击？**

通过上文<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">undo<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">日志</span></span>和<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">回滚段</span>的铺垫，这两个问题就非常好回答了：

(1)旧版本数据存储在回滚段里；

(2)对MySQL和InnoDB原有架构体系冲击不大；

InnoDB的内核，会对所有row数据增加三个内部属性：

(1)**DB_TRX_ID**，6字节，记录每一行最近一次修改它的事务ID；

(2)**DB_ROLL_PTR**，7字节，记录指向回滚段undo日志的指针；

(3)**DB_ROW_ID**，6字节，单调递增的行ID；

**InnoDB****为何能够做到这么高的并发？**

回滚段里的数据，其实是历史数据的<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;color: rgb(255, 76, 0);">快照</span>（snapshot），这些数据是不会被修改，select可以肆无忌惮的并发读取他们。

**快照读**（Snapshot Read），这种**一致性不加锁的读**（Consistent Nonlocking Read），就是<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">InnoDB<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">并发如此之高的核心原因之一</span></span>。

这里的**一致性**是指，事务读取到的数据，要么是事务开始前就已经存在的数据（当然，是其他已提交事务产生的），要么是事务自身插入或者修改的数据。

**什么样的select****是快照读？**

除非显示加锁，<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);"><span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">普通的</span>select<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">语句都是快照读</span></span>，例如：
```
select * from t where id>2;
```
这里的<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">显示加锁，非快照读</span>是指：
```
select * from t where id>2 **lock in share mode**;
select * from t where id>2 **for update**;
```
问题来了，这些显示加锁的读，是什么读？会加什么锁？和事务的隔离级别又有什么关系？

  

本节的内容已经够多了，且听下回分解。

**总结**

(1)常见并发控制保证数据一致性的方法有**锁**，**数据多版本**；

(2)**普通锁**<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);font-family: 宋体;">串行</span>，**读写锁**<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);font-family: 宋体;">读读并行</span>，**数据多版本**<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);font-family: 宋体;">读写并行</span>；

(3)**redo日志**保证<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">已提交事务的</span>，设计思路是，通过顺序写替代随机写，提高并发；

(4)**undo日志**用来<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">回滚未提交的事务</span>，它存储在回滚段里；

(5)InnoDB是基于**MVCC**的存储引擎，它利用了存储在回滚段里的undo日志，即数据的旧版本，提高并发；

(6)InnoDB之所以并发高，<span style="font-family: 宋体;font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">快照读不加锁</span>；

(7)InnoDB所有<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);"><span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">普通</span>select<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">都是快照读</span></span>；

<span style="color: rgb(0, 82, 255);"><em><span style="font-size: 14px;letter-spacing: 1px;"><span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">画外音：</span><span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">本文的知识点均基于</span>MySQL5.6<span style="letter-spacing: 1px;font-size: 14px;font-family: 宋体;">。</span></span></em></span>

  

希望大家有收获，下一篇继续深入InnoDB的**锁**。

  

希望通俗的技术文被更多人看到，求帮**转**。

  

相关文章：

《[InnoDB，5项最佳实践，知其所以然？](http://mp.weixin.qq.com/s?__biz=MjM5ODYxMDA5OQ==&mid=2651961428&idx=1&sn=31a9eb967941d888fbd4bb2112e9602b&chksm=bd2d0d888a5a849e7ebaa7756a8bc1b3d4e2f493f3a76383fc80f7e9ce7657e4ed2f6c01777d&scene=21#wechat_redirect)》

