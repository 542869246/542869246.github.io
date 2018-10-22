---
title: InnoDB，快照读，在RR和RC下有何差异？
copyright: true
top: 95
date: 2018-09-05 16:25:00
categories: [数据库]
tags: [数据库,SQL,InnoDB,MySQL]
image: http://pic1.win4000.com/wallpaper/2018-08-31/5b88a449cd32c.jpg
description: 
---

<span></span>

<!--more-->

为了保证文章知识体系的完整性，先简单解释下**快照读**，**读提交**，**可重复读**。
  

**快照读**(Snapshot Read)

MySQL数据库，InnoDB存储引擎，为了提高并发，使用MVCC机制，在并发事务时，通过读取数据行的历史数据版本，不加锁，来提高并发的一种<span style="letter-spacing: 1px;font-size: 14px;color: rgb(255, 76, 0);">不加锁一致性读</span>(Consistent Nonlocking Read)。

  

**读提交**(Read Committed)

*   数据库领域，事务隔离级别的一种，简称RC
    
*   它解决“读脏”问题，保证读取到的数据行都是已提交事务写入的
    
*   它可能存在“读幻影行”问题，同一个事务里，连续相同的read可能读到不同的结果集
    

  

**可重复读**(Repeated Read)

*   数据库领域，事务隔离级别的一种，简称RR
    
*   它不但解决“读脏”问题，还解决了“读幻影行”问题，同一个事务里，连续相同的read读到相同的结果集
    

  

在**读提交**(<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 12px;">RC</span>)，**可重复读**(<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 12px;">RR</span>)两个不同的事务的隔离级别下，**快照读**有什么不同呢？  

  

先说**结论**：

*   事务总能够读取到，自己写入(update /insert /delete)的行记录
    
*   RC下，快照读总是能读到最新的行数据快照，当然，必须是已提交事务写入的
    
*   RR下，某个事务首次read记录的时间为T，未来不会读取到T时间之后已提交事务写入的记录，以保证连续相同的read读到相同的结果集  
    
<span style="font-size: 14px;letter-spacing: 1px;color: rgb(0, 82, 255);">
_画外音：可以看到_</span>

<span style="font-size: 14px;letter-spacing: 1px;color: rgb(0, 82, 255);">_(1)和并发事务的开始时间没关系，和事务首次read的时间有关；_</span>

<span style="font-size: 14px;letter-spacing: 1px;color: rgb(0, 82, 255);">_(2)由于不加锁，和互斥关系也不大；_</span>

  
InnoDB表：  

t(id PK, name);  
   
表中有三条记录：  
1, shenjian  
2, zhangsan  
3, lisi

  

<span style="color: rgb(255, 76, 0);font-size: 16px;"><em><strong><span style="letter-spacing: 1px;font-size: 16px;">case 1</span></strong></em></span>，两个并发事务A，B执行的时间序列如下（A先于B开始，B先于A结束）：

A1: start transaction;  
         B1: start transaction;  
A2: select * from t;  
         B2: insert into t values (4, wangwu);  
A3: select * from t;  
         B3: commit;  
A4: select * from t;

  

**提问1**：假设事务的隔离级别是<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 14px;">可重复读RR</span>，事务A中的三次查询，A2, A3, A4分别读到什么结果集？

**回答**：RR下

(1)A2读到的结果集肯定是{1, 2, 3}，这是事务A的第一个read，假设为时间T；

(2)A3读到的结果集也是{1, 2, 3}，因为B还没有提交；

(3)A4读到的结果集还是{1, 2, 3}，因为事务B是在时间T之后提交的，A4得读到和A2一样的记录；

  
**提问2**：假设事务的隔离级别是<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 14px;">读提交RC</span>，A2, A3, A4又分别读到什么结果集呢？

**回答**：RC下

(1)A2读到的结果集是{1, 2, 3}；

(2)A3读到的结果集也是{1, 2, 3}，因为B还没有提交；

(3)A4读到的结果集还是{1, 2, 3, 4}，因为事务B已经提交；

  

<span style="color: rgb(255, 76, 0);font-size: 16px;"><em><strong><span style="letter-spacing: 1px;font-size: 16px;">case 2</span></strong></em></span>，仍然是上面的两个事务，只是A和B开始时间稍有不同（B先于A开始，B先于A结束）：  

         <span style="margin: 0px;padding: 0px;color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 12px;">&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; B1: start transaction;</span>

<span style="margin: 0px;padding: 0px;color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 12px;">A1: start transaction;</span>

A2: select * from t;  
         B2: insert into t values (4, wangwu);  
A3: select * from t;  
         B3: commit;  
A4: select * from t;  

  

**提问3**：假设事务的隔离级别是<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 14px;">可重复读RR</span>，事务A中的三次查询，A2, A3, A4分别读到什么结果集？  

**提问4**：假设事务的隔离级别是<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 14px;">读提交RC</span>，A2, A3, A4的结果集又是什么呢？  
  

**回答**：事务的开始时间不一样，不会影响“快照读”的结果，所以结果集和case 1一样。

  

<span style="color: rgb(255, 76, 0);font-size: 16px;"><em><strong><span style="letter-spacing: 1px;font-size: 16px;">case 3</span></strong></em></span>，仍然是并发的事务A与B（A先于B开始，B先于A结束）：

A1: start transaction;  
         B1: start transaction;  
         B2: insert into t values (4, wangwu);  
         B3: commit;  
A2: select * from t;  

  

**提问5**：假设事务的隔离级别是<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 14px;">可重复读RR</span>，事务A中的A2查询，结果集是什么？  

**提问6**：假设事务的隔离级别是<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 14px;">读提交RC</span>，A2的结果集又是什么呢？  

  

**回答**：在RR下，

A2是事务A的第一个read，假设为时间T，它能读取到T之前提交事务写入的数据行，故结果集为{1, 2, 3, 4}。在RC下，没有疑问，一定是{1, 2, 3, 4}。

  

<span style="color: rgb(255, 76, 0);font-size: 16px;"><em><strong><span style="letter-spacing: 1px;font-size: 16px;">case 4</span></strong></em></span>，事务开始的时间再换一下（B先于A开始，B先于A结束）：

         <span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 12px;">&nbsp; &nbsp; &nbsp; &nbsp;&nbsp; B1: start transaction;</span>

<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 12px;display: inline !important;float: none;background-color: transparent;">A1: start transaction;</span>

         B2: insert into t values (4, wangwu);  

         B3: commit;  
A2: select * from t;

  

**提问7**：假设事务的隔离级别是<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 14px;">可重复读RR</span>，事务A中的A2查询，结果集是什么？  

**提问8**：假设事务的隔离级别是<span style="color: rgb(255, 76, 0);letter-spacing: 1px;font-size: 14px;">读提交RC</span>，A2的结果集又是什么呢？

  

**回答**：事务的开始时间不一样，不会影响“快照读”的结果，所以结果集和case 3一样。

  

啰嗦说了这么多，用昨天一位网友“山峰”同学的话**总结**：

*   RR下，事务在第一个Read操作时，会建立Read View
    
*   RC下，事务在每次Read操作时，都会建立Read View

  

相关推荐：  

《[InnoDB，并发如此之高的原因](https://yfzhou.coding.me/2018/08/14/InnoDB%E5%B9%B6%E5%8F%91%E5%A6%82%E6%AD%A4%E9%AB%98%EF%BC%8C%E5%8E%9F%E5%9B%A0%E7%AB%9F%E7%84%B6%E5%9C%A8%E8%BF%99%EF%BC%9F/)》