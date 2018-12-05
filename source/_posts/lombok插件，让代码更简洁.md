---
title: lombok插件，让代码更简洁
copyright: true
top: 95
date: 2018-12-03 14:17:01
categories: [java]
tags: [java,lombok]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/0e6b3e49d9cd950bc4f8db95a893f684.jpg?x-oss-process=style/ys30
description: 
---

<span></span>

<!--more-->


是否厌倦了写一个实体类就要重复使用快捷键生成该类的getter，setter，无参有参构造？那么lombok插件可以帮你解决这些重复性劳动。之前文章中，也有说到lombok插件，此篇文章就详细介绍下lombok插件的使用。

## lombok简介

Lombok想要解决了的是在我们实体Bean中大量的Getter/Setter方法，以及toString, hashCode等可能不会用到，但是某些时候仍然需要复写，以期方便使用的方法；在使用Lombok之后，将由其来自动帮你实现代码生成，注意，其是 在运行过程中，帮你自动生成的 。就是说，将极大减少你的代码总量。

> 官网：[https://projectlombok.org](https://projectlombok.org/)


## IntelliJ IDEA安装

菜单栏File > Settings > Plugins > Browse repositories > 搜索lombok > install > 重启
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20181203141021.png)

## pom依赖

```xml
<!-- https://mvnrepository.com/artifact/org.projectlombok/lombok -->
<dependency>
	<groupId>org.projectlombok</groupId>
	<artifactId>lombok</artifactId>
	<version>1.18.4</version>
</dependency>
```
## 快速使用

编写一个实体类 Person，使用`@Data`注解
```java
package com.example.mongodemo.model;

import lombok.Data;

@Data
public class Person {
    private Integer id;
    private String name;
    private Integer age;

}

```

编写测试方法，测试@Data的作用

```java
package com.example.mongodemo;

import com.example.mongodemo.model.Person;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
public class MongodemoApplicationTests {

	@Test
	public void contextLoads() {
		Person p = new Person();
		p.setId(1);
		p.setName("Felix");
		p.setAge(22);
		System.out.println(p.toString());
	}

}

```
可以看到，我们并没有编写getter、setter方法，这里却可以正常使用，并且还重写了toString、hashCode、equals方法
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20181203144328.png)

## lombok的注解介绍

@NonNull : 让你不在担忧并且爱上NullPointerException 
@CleanUp : 自动资源管理：不用再在finally中添加资源的close方法 
@Setter/@Getter : 自动生成set和get方法 
@ToString : 自动生成toString方法 
@EqualsAndHashcode : 从对象的字段中生成hashCode和equals的实现 
@Data : 自动生成set/get方法，toString方法，equals方法，hashCode方法，不带参数的构造方法 
@Value : 用于注解final类 
@Builder : 产生复杂的构建器api类 
@SneakyThrows : 异常处理（谨慎使用） 
@Synchronized : 同步方法安全的转化 
@Getter(lazy=true) : 它将在第一次调用该getter时计算一次值，并从那时起缓存它。
@Log : 支持各种logger对象，使用时用对应的注解，如：@Log4j
@NoArgsConstructor/@RequiredArgsConstructor /@AllArgsConstructor：
这三个注解都是用在类上的，第一个和第三个都很好理解，就是为该类产生无参的构造方法和包含所有参数的构造方法， 
第二个注解则使用类中所有带有`@NonNull`注解的或者带有`final`修饰的成员变量生成对应的构造方法，当然，和前面几个注解一样，成员变量都是非静态的， 
另外，如果类中含有final修饰的成员变量，是无法使用`@NoArgsConstructor`注解的。

三个注解都可以指定生成的构造方法的访问权限，同时，第二个注解还可以用`@RequiredArgsConstructor(staticName="methodName")`的形式生成一个指定名称的静态方法，返回一个调用相应的构造方法产生的对象，下面来看一个例子

```java
@RequiredArgsConstructor(staticName = "sunsfan")
@AllArgsConstructor(access = AccessLevel.PROTECTED)
@NoArgsConstructor
public class Shape {
    private int x;
    @NonNull
    private double y;
    @NonNull
    private String name;
}
```
实际效果相当于：
```java

public class Shape {
    private int x;
    private double y;
    private String name;

    public Shape(){
    }

    protected Shape(int x,double y,String name){
        this.x = x;
        this.y = y;
        this.name = name;
    }

    public Shape(double y,String name){
        this.y = y;
        this.name = name;
    }

    public static Shape sunsfan(double y,String name){
        return new Shape(y,name);
    }
}
```

