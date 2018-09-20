---
title: MySQL不为人知的主键与唯一索引约束
copyright: true
top: 95
date: 2018-09-19 17:31:09
categories: [数据库]
tags: [数据库,SQL,InnoDB,MySQL]
image: http://pic1.win4000.com/wallpaper/2018-02-03/5a7555b21eb97.jpg
description:
---

<span></span>

<!--more-->
<center>此文摘自微信公众号【架构师之路】
微信扫一扫
关注该公众号
</center>
![](https://mp.weixin.qq.com/mp/qrcode?scene=10000004&size=102&__biz=MjM5ODYxMDA5OQ==&mid=2651961431&idx=1&sn=4f46fbada3d99ca6cf74b305d06c1ac6&send_time=)


今天和大家简单聊聊MySQL的约束**主键与唯一索引约束**：

PRIMARY KEY and UNIQUE Index Constraints

文章不长，保证有收获。

触发约束检测的时机：
*   insert
*   update

当检测到违反约束时，不同存储引擎的处理动作是不一样的。

**如果存储引擎支持事务，SQL会自动<span style="color: rgb(255, 76, 0);"><strong><span style="font-size: 14px;letter-spacing: 1px;">回滚</span></strong></span>。**

例子：
create table t1 (
id int(10) <span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">primary key</span>
)engine=<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">innodb</span>;
insert into t1 values(1);
insert into t1 values(1);
其中第二条insert会因为违反约束，而导致回滚。

通常可以使用：
show warnings;
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20180919175612.webp)

来查看违反约束后的错误提示。

**如果存储引擎不支持事务，SQL的执行会<span style="color: rgb(255, 76, 0);"><strong><span style="font-size: 14px;letter-spacing: 1px;">中断</span></strong></span>，此时可能会导致后续有符合条件的行不被操作，出现不符合预期的结果。**


例子：
create table t2 (
id int(10) <span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">unique</span>
)engine=<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">MyISAM</span>;
insert into t2 values(<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">1</span>);
insert into t2 values(<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">5</span>);
insert into t2 values(<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">6</span>);
insert into t2 values(<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">10</span>);
update t2 <span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">set id=id+1</span>;

**update执行后，猜猜会得到什么结果集？**
猜想一：2, 6, 7, 11
猜想二：1, 5, 6, 10
.
.
.
都不对，正确答案是：<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">2</span>, 5, 6, 10

第一行id=1，加1后，没有违反unique约束，<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">执行成功</span>；
第二行id=5，加1后，由于id=6的记录存在，违反uinique约束，<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">SQL终止</span>，<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">修改失败</span>；
第三行id=6，第四行id=10便<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">不再执行</span>；
<span style="color: rgb(0, 82, 255);"><em><span style="font-size: 14px;letter-spacing: 1px;">画外音：这太操蛋了，一个update语句，部分执行成功，部分执行失败。</span></em></span>

  

**为了避免这种情况出现，请使用InnoDB存储引擎**，InnoDB在遇到违反约束时，会自动回滚update语句，一行都不会修改成功。

<span style="color: rgb(0, 82, 255);"><em><span style="font-size: 14px;letter-spacing: 1px;">画外音：大家把存储引擎换成InnoDB，把上面的例子再跑一遍，印象更加深刻。</span></em></span>

另外，对于<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">insert的约束冲突</span>，可以使用：
<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">insert … on duplicate key</span>
指出**在违反主键或唯一索引约束时，需要进行的额外操作**。

例子：
create table t3 (
id int(10) <span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">unique</span>,
flag char(10) <span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">default 'true'</span>
)engine=<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">MyISAM</span>;
insert into t3(id) values(1);
insert into t3(id) values(5);
insert into t3(id) values(6);
insert into t3(id) values(<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">10</span>);
insert into t3(id) values(<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">10</span>) on duplicate key update flag='false';

**insert执行后，猜猜会发生什么？**
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20180919175500.webp)

插入id=10的记录，会违反unique约束，此时执行update flag=’false’，于是有一行记录被update了。  

这**相当于执行**：
update t3 set flag='false' where id=10;

仔细看，insert的结果返回，提示：
Query OK, <span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);">2</span> rows affected
有意思么？
<span style="color: rgb(0, 82, 255);"><em><span style="font-size: 14px;letter-spacing: 1px;">画外音：本文所有实验，基于MySQL5.6。</span></em></span>

**总结**，对于<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">主键与唯一索引约束</span>：
*   执行insert和update时，会触发约束检查 
*   **InnoDB**违反约束时，会<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">回滚对应SQL</span>
*   **MyISAM**违反约束时，会<span style="font-size: 14px;letter-spacing: 1px;color: rgb(255, 76, 0);">中断对应的SQL</span>，可能造成不符合预期的结果集
*   可以使用<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);"> insert … on duplicate key </span>来指定触发约束时的动作
*   通常使用<span style="letter-spacing: 1px;font-size: 12px;color: rgb(255, 76, 0);"> show warnings; </span>来查看与调试违反约束的ERROR

  
互联网大数据量高并发量业务，**为了大家的身心健康，请使用InnoDB**。


相关推荐：  
《[业界难题 - 『跨库分页』的四种方案](https://yfzhou.coding.me/2018/09/10/%E4%B8%9A%E7%95%8C%E9%9A%BE%E9%A2%98%20-%20%E3%80%8E%E8%B7%A8%E5%BA%93%E5%88%86%E9%A1%B5%E3%80%8F%E7%9A%84%E5%9B%9B%E7%A7%8D%E6%96%B9%E6%A1%88/)》
《[InnoDB，为什么并发如此之高？](https://yfzhou.coding.me/2018/08/14/InnoDB%E5%B9%B6%E5%8F%91%E5%A6%82%E6%AD%A4%E9%AB%98%EF%BC%8C%E5%8E%9F%E5%9B%A0%E7%AB%9F%E7%84%B6%E5%9C%A8%E8%BF%99%EF%BC%9F/)》
《[InnoDB，快照读，在RR和RC下有何差异？](https://yfzhou.coding.me/2018/09/05/InnoDB%EF%BC%8C%E5%BF%AB%E7%85%A7%E8%AF%BB%EF%BC%8C%E5%9C%A8RR%E5%92%8CRC%E4%B8%8B%E6%9C%89%E4%BD%95%E5%B7%AE%E5%BC%82%EF%BC%9F/)》

了解了几个坑，也是好的，求转。