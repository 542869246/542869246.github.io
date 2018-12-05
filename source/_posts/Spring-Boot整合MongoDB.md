---
title: Spring Boot整合MongoDB
copyright: true
top: 95
date: 2018-12-01 11:40:53
categories: [java]
tags: [java,Spring Boot,MongoDB]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/9874.jpg?x-oss-process=style/ys30
description: 
---

<span></span>

<!--more-->

前阵子有朋友问我java整合MongoDB方面的问题，之前也没用java整合过MongoDB，顺便研究下，在此记录下来

## MongoDB 简介

- MongoDB 是一个基于分布式文件存储的数据库，由 C++ 语言编写，旨在为 WEB 应用提供可扩展的高性能数据存储解决方案。
- MongoDB 是一个介于关系数据库和非关系数据库之间的产品，是非关系数据库当中功能最丰富，最像关系数据库的。
- MongoDB 将数据存储在类似JSON的灵活文档中，这意味着字段可能因文档而异，并且数据结构可能会随时间而变化
- 文档模型映射到应用程序代码中的对象，使数据易于使用
- 即席查询，索引和实时聚合提供了访问和分析数据的强大方法

还没接触过MongoDB的小伙伴，可以去看看我之前写的文章 [MongoDB学习笔记（增删改查、聚合、索引、连接、备份与恢复、监控等）](https://542869246.github.io/2018/11/06/MongoDB%E5%AD%A6%E4%B9%A0%E7%AC%94%E8%AE%B0%EF%BC%88%E5%A2%9E%E5%88%A0%E6%94%B9%E6%9F%A5%E3%80%81%E8%81%9A%E5%90%88%E3%80%81%E7%B4%A2%E5%BC%95%E3%80%81%E8%BF%9E%E6%8E%A5%E3%80%81%E5%A4%87%E4%BB%BD%E4%B8%8E%E6%81%A2%E5%A4%8D%E3%80%81%E7%9B%91%E6%8E%A7%E7%AD%89%EF%BC%89/)

## 运行环境
IntelliJ IDEA 2017
JDK 1.8
Spring Boot 2.1
maven 4.0.0

## 项目结构
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20181201120711.png)

## 添加Spring Boot和MongoDB依赖。

```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-data-mongodb</artifactId>
</dependency>
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-web</artifactId>
</dependency>

<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-test</artifactId>
	<scope>test</scope>
</dependency>
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-devtools</artifactId>
	<optional>true</optional>
</dependency>
<!-- https://mvnrepository.com/artifact/org.projectlombok/lombok -->
<dependency>
	<groupId>org.projectlombok</groupId>
	<artifactId>lombok</artifactId>
	<version>1.18.4</version>
</dependency>

```

## application.properties

```properties
# IP地址
spring.data.mongodb.host=127.0.0.1
# MongoDB的端口号
spring.data.mongodb.port=27017
# 要连接到MongoDB的test数据库中。
spring.data.mongodb.database=test
```

## 编写User实体
```java
package com.example.mongodemo.model;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.io.Serializable;

@Data
@NoArgsConstructor
@AllArgsConstructor
//Document指定数据插入到MongoDB数据库里的名字为textCollection的集合中
@Document(collection = "user")
public class User implements Serializable {
    private static final long serialVersionUID = -1L;
	//id属性是给mongodb用的，用@Id注解修饰
    @Id
    private Long id;
    private String userName;
    private Integer age;


}

```
注：此处实体类使用的`@Data、@NoArgsConstructor、@AllArgsConstructor`注解，分别表示自动生成该实体类字段的get/set/toString/equals/hashCode方法、无参构造，有参构造。此为idea使用lombok插件，方法自行百度，此处不累赘。

## 编写UserRepository

通过继承MongoRepository接口，我们可以非常方便地实现对一个对象的增删改查，要使用Repository的功能，先继承MongoRepository<T, TD>接口，其中T为`仓库保存的bean类`，TD为`该bean的唯一标识的类型`，一般为ObjectId。之后在service中注入该接口就可以使用，无需实现里面的方法，spring会根据定义的规则自动生成。

但是MongoRepository实现了的只是最基本的增删改查的功能，要想增加额外的查询方法，可以按照以下规则定义接口的方法。自定义查询方法，格式为`“findBy+字段名+方法后缀”`，方法传进的参数即字段的值，此外还支持分页查询，通过传进一个Pageable对象，返回Page集合。


```java
package com.example.mongodemo.dao;

import com.example.mongodemo.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

import java.util.List;

public interface UserRepository extends MongoRepository<User, Long> {

    /**
     * Like（模糊查询）
     * {"username" : name} ( name as regex)
     */
    List<User> findByUserNameLike(String username);

    /**
     * Like（模糊查询）
     * {"username" : name}
     */
    List<User> findByUserName(String username);

    /**
     * GreaterThan(大于)
     * {"age" : {"$gt" : age}}
     */
    List<User> findByAgeGreaterThan(int age);

    /**
     * LessThan（小于）
     * {"age" : {"$lt" : age}}
     */
    List<User> findByAgeLessThan(int age);

    /**
     * Between（在...之间）
     * {{"age" : {"$gt" : from, "$lt" : to}}
     */
    List<User> findByAgeBetween(int from, int to);

    /**
     * IsNotNull, NotNull（是否非空）
     * {"username" : {"$ne" : null}}
     */
    List<User> findByUserNameNotNull();

    /**
     * IsNull, Null（是否为空）
     * {"username" : null}
     */
    List<User> findByUserNameNull();


    /**
     * Not（不包含）
     * {"username" : {"$ne" : name}}
     */
    List<User> findByUserNameNot(String name);


    /**
     *  Near（查询地理位置相近的）
     *  {"location" : {"$near" : [x,y]}}
     * */
    // findByLocationNear(Point point)


    /**
     * Within（在地理位置范围内的）
     *   {"location" : {"$within" : {"$center" : [ [x, y], distance]}}}
     * */
    //findByLocationWithin(Circle circle)


    /**
     * Within（在地理位置范围内的）
     * {"location" : {"$within" : {"$box" : [ [x1, y1], x2, y2]}}}
     */
    // findByLocationWithin(Box box)


    /**
     * 自定义SQl查询
     */
    @Query("{\"userName\":{\"$regex\":?0}, \"age\": ?1}")
    Page<User> findByNameAndAgeRange(String name, int age, Pageable page);

    @Query(value = "{\"userName\":{\"$regex\":?0},\"age\":{\"$gte\":?1,\"$lte\": ?2}}")
    Page<User> findByNameAndAgeRange2(String name, int ageFrom, int ageTo, Pageable page);

    @Query(value = "{\"userName\":{\"$regex\":?0},\"age\":{\"$gte\":?1,\"$lte\": ?2}}", fields = "{\"userName\" : 1, \"age\" : 1}")
    Page<User> findByNameAndAgeRange3(String name, int ageFrom, int ageTo, Pageable page);


}

```

## 编写测试类

### 添加测试数据
```java
package com.example.mongodemo;


import com.example.mongodemo.dao.UserRepository;
import com.example.mongodemo.model.User;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import javax.annotation.Resource;
import java.util.List;

@RunWith(SpringJUnit4ClassRunner.class)
@SpringBootTest(classes = MongodemoApplication.class)
public class UserRepositoryTest {
    private final Logger logger = LoggerFactory.getLogger(getClass());

    @Resource
    private UserRepository userRepository;


    @Test
    public void testAdd() throws Exception {
        // 创建多个User，并验证User总数
        userRepository.save(new User(1L, "felix", 22));
        userRepository.save(new User(2L, "tim", 23));
        userRepository.save(new User(3L, "cc", 23));
        userRepository.save(new User(4L, "pyh", 22));
        userRepository.save(new User(5L, "simba", 28));
        userRepository.save(new User(6L, "felix2", 10));
        userRepository.save(new User(7L, "felix3", 20));
        userRepository.save(new User(8L, "felixfelix", 30));
        userRepository.save(new User(9L, "felix4", 40));
        userRepository.save(new User(10L, "felix5", 50));
        userRepository.save(new User(11L, "felix6", 60));
        userRepository.save(new User(12L, "felix7", 70));
        userRepository.save(new User(13L, "felix8", 80));
        userRepository.save(new User(14L, "felix9", 90));
        userRepository.save(new User(15L, "felix10", 100));
        userRepository.save(new User(16L, "", 50));
        userRepository.save(new User(17L, null, 50));
        this.logger.info(String.valueOf(userRepository.findAll().size()));

    }

}


```

运行结果：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20181201135523.png)
打开Navicat查看：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20181201135209.png)

### 删除
```java

@Test
    public void testDel() throws Exception {
        // 删除一个User，再验证User总数
        User u = userRepository.findById(1L).orElse(null);
        this.logger.info(u.toString());
        userRepository.delete(u);
        this.logger.info(String.valueOf(userRepository.findAll().size()));
    }

```
运行结果：
总数变为16
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20181201135942.png)

## 条件查询

```java
@Test
    public void testFindMore() throws Exception {

        List<User> u1 = userRepository.findByUserNameLike("felix");
        this.logger.info(u1.toString());
        List<User> u2 = userRepository.findByUserName("felix");
        this.logger.info(u2.toString());
        List<User> u3 = userRepository.findByAgeGreaterThan(40);
        this.logger.info(u3.toString());
        List<User> u4 = userRepository.findByAgeLessThan(40);
        this.logger.info(u4.toString());
        List<User> u5 = userRepository.findByAgeBetween(20, 30);
        this.logger.info(u5.toString());
        List<User> u6 = userRepository.findByUserNameNotNull();
        this.logger.info(u6.toString());
        List<User> u7 = userRepository.findByUserNameNull();
        this.logger.info(u7.toString());
        List<User> u8 = userRepository.findByUserNameNot("felix");
        this.logger.info(u8.toString());


    }
```
运行结果：
可以看到8条集合，数据超出部分就不贴图了
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20181201141437.png)

### 自定义查询
```java
    @Test
    public void test3() throws Exception {

        Pageable pageable = PageRequest.of(0, 10);
        Page<User> u1 = userRepository.findByNameAndAgeRange("felix", 50, pageable);
        this.logger.info(u1.toString());
        u1.getContent().stream().forEach(n -> System.out.println(n.toString()));
        Page<User> u2 = userRepository.findByNameAndAgeRange2("felix", 0, 50, pageable);
        this.logger.info(u2.toString());
        u2.getContent().stream().forEach(n -> System.out.println(n.toString()));
        Page<User> u3 = userRepository.findByNameAndAgeRange3("felix", 0, 50, pageable);
        this.logger.info(u3.toString());
        u3.getContent().stream().forEach(n -> System.out.println(n.toString()));

    }
```
运行结果：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20181201141807.png)



## 遇到的一些坑

### findOne和findById
因为这次我用的Spring Boot版本是2.1，之前是1.4.1。改版之后将findOne 更名为 findById，但是findById并不仅仅是将findOne改名，它返回的对象变成了Optional。如果想让findById和findOne有同样的功能，可以用下面这个函数：
```java
User u = userRepository.findById(1L).orElse(null);
```

### insert()和save()
insert:当主键"_id"在集合中存在时，不做任何处理。 将会抛以下异常：
```
org.springframework.dao.DuplicateKeyException: E11000 duplicate key error collection
```

save:当主键"_id"在集合中存在时，进行更新。 数据整体都会更新 ，新数据会替换掉原数据 ID 以外的所有数据。如ID 不存在就新增一条数据

来看看 MongoRepository  接口的具体实现类`SimpleMongoRepository<T, ID extends Serializable>`的save 方法到底怎么写的。
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM截图20181201143157.png)
判断一下主键的值是否存在,存在返回false,存正为true.通过  处理类 设置主键Id的,就会走save,而不是insert了