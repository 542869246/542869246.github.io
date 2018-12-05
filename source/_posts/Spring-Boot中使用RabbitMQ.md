---
title: Spring Boot中使用RabbitMQ
copyright: true
top: 95
date: 2018-11-26 19:29:06
categories: [java]
tags: [java,RabbitMQ,Spring Boot]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/acce07daa9975b03e3fd2ad460c1ffa.jpg
description:
---

<span></span>

<!--more-->


## RabbitMQ介绍

RabbitMQ是实现AMQP（高级消息队列协议）的消息中间件的一种，最初起源于金融系统，用于在分布式系统中存储转发消息，在易用性、扩展性、高可用性等方面表现不俗。RabbitMQ主要是为了实现系统之间的双向解耦而实现的。当生产者大量产生数据时，消费者无法快速消费，那么需要一个中间层。保存这个数据。

AMQP，即Advanced Message Queuing Protocol，高级消息队列协议，是应用层协议的一个开放标准，为面向消息的中间件设计。消息中间件主要用于组件之间的解耦，消息的发送者无需知道消息使用者的存在，反之亦然。AMQP的主要特征是面向消息、队列、路由（包括点对点和发布/订阅）、可靠性、安全。

RabbitMQ是一个开源的AMQP实现，服务器端用Erlang语言编写，支持多种客户端，如：Python、Ruby、.NET、Java、JMS、C、PHP、ActionScript、XMPP、STOMP等，支持AJAX。用于在分布式系统中存储转发消息，在易用性、扩展性、高可用性等方面表现不俗。

## 安装

在RabbitMQ官网的[https://www.rabbitmq.com/download.html](https://www.rabbitmq.com/download.html)中，我们可以获取到针对各种不同操作系统的安装包和说明文档。这里，就用windows版来做说明。

- Erlang/OTP 21.1
- RabbitMQ Server 3.7.9

### 安装Erland
1. 通过官方下载页面[http://www.erlang.org/downloads](http://www.erlang.org/downloads) 获取exe安装包，直接打开并完成安装。
2. 添加系统变量 `ERLANG_HOME=D:\erl10.1`
3. 系统变量Path下加入`%ERLANG_HOME%\bin;`

### 安装RabbitMQ

安装RabbitMQ，通过官方下载页面[https://www.rabbitmq.com/download.html](https://www.rabbitmq.com/download.html)获取exe安装包。

需要注意：默认安装的RabbitMQ 监听端口是5672

### 运行
我的目录是：`D:\RabbitMQ Server\rabbitmq_server-3.7.9\sbin`

cmd进入该目录,在后面输入`rabbitmq-plugins enable rabbitmq_management`命令进行安装

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20181126195119.png)

访问[http://localhost:15672](http://localhost:15672)
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20181126195657.png)

默认账号密码都是guest,登录即可
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20181126195722.png)

## RabbitMQ用户创建、密码、绑定角色、修改密码等
cmd进入`D:\RabbitMQ Server\rabbitmq_server-3.7.9\sbin`

查看已有用户及用户的角色：
```
rabbitmqctl.bat list_users
```
新增一个用户：
```
rabbitmqctl.bat add_user username password
```
给用户添加角色
```
rabbitmqctl.bat set_user_tags username administrator
```
rabbitmq用户角色可分为五类：超级管理员, 监控者, 策略制定者, 普通管理者以及其他。
(1) 超级管理员(administrator)
可登陆管理控制台(启用management plugin的情况下)，可查看所有的信息，并且可以对用户，策略(policy)进行操作。
(2) 监控者(monitoring)
可登陆管理控制台(启用management plugin的情况下)，同时可以查看rabbitmq节点的相关信息(进程数，内存使用情况，磁盘使用情况等) 
(3) 策略制定者(policymaker)
可登陆管理控制台(启用management plugin的情况下), 同时可以对policy进行管理。
(4) 普通管理者(management)
仅可登陆管理控制台(启用management plugin的情况下)，无法看到节点信息，也无法对策略进行管理。
(5) 其他的
无法登陆管理控制台，通常就是普通的生产者和消费者。

用户也可以同时具有多个角色,设置方式:
```
rabbitmqctl.bat  set_user_tags  username tag1 tag2 ...
```
更改密码:
```
rabbitmqctl change_password userName newPassword
```
删除用户：
```
rabbitmqctl.bat delete_user username
```

当然，不想敲命令的话可以进管理页面直接操作：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20181126200654.png)


## Spring Boot整合
下面，我们通过在Spring Boot应用中整合RabbitMQ，并实现一个简单的发送、接收消息的例子来对RabbitMQ有一个直观的感受和理解。

在Spring Boot中整合RabbitMQ是一件非常容易的事，因为之前我们已经介绍过Starter POMs，其中的AMQP模块就可以很好的支持RabbitMQ，下面我们就来详细说说整合过程：

- 在`pom.xml`中引入如下依赖内容，其中`spring-boot-starter-amqp`用于支持RabbitMQ。
```
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-amqp</artifactId>
    </dependency>
```
- 在`application.properties`中配置关于RabbitMQ的连接和用户信息，用户可以回到上面的安装内容，在管理页面中创建用户。
```
spring.rabbitmq.host=127.0.0.1
spring.rabbitmq.port=5672
spring.rabbitmq.username=felix
spring.rabbitmq.password=123456
```
- 创建消息生产者`Sender`。通过注入`AmqpTemplate`接口的实例来实现消息的发送，`AmqpTemplate`接口定义了一套针对AMQP协议的基础操作。在Spring Boot中会根据配置来注入其具体实现。在该生产者，我们会产生一个字符串，并发送到名为`hello`的队列中。
```java
@Component
public class Sender {

    @Autowired
    private AmqpTemplate rabbitTemplate;

    public void send() {
        String context = "hello " + new Date();
        System.out.println("Sender : " + context);
        this.rabbitTemplate.convertAndSend("hello", context);
    }

}
```
- 创建消息消费者`Receiver`。通过@RabbitListener注解定义该类对`hello`队列的监听，并用`@RabbitHandler`注解来指定对消息的处理方法。所以，该消费者实现了对`hello`队列的消费，消费操作为输出消息的字符串内容。
```java
@Component
@RabbitListener(queues = "hello")
public class Receiver {

    @RabbitHandler
    public void process(String hello) {
        System.out.println("Receiver : " + hello);
    }

}
```
- 创建RabbitMQ的配置类`RabbitConfig`，用来配置队列、交换器、路由等高级信息。这里我们以入门为主，先以最小化的配置来定义，以完成一个基本的生产和消费过程。
```java
@Configuration
public class RabbitConfig {

    @Bean
    public Queue helloQueue() {
        return new Queue("hello");
    }

}
```
- 创建应用主类
```java
@SpringBootApplication
public class HelloApplication {

    public static void main(String[] args) {
        SpringApplication.run(HelloApplication.class, args);
    }

}
```
- 创建单元测试类，用来调用消息生产
```java
@RunWith(SpringJUnit4ClassRunner.class)
@SpringApplicationConfiguration(classes = HelloApplication.class)
public class HelloApplicationTests {

    @Autowired
    private Sender sender;

    @Test
    public void hello() throws Exception {
        sender.send();
    }

}
```
完成程序编写之后，下面开始尝试运行。首先确保RabbitMQ Server已经开始，然后进行下面的操作：

- 启动应用主类，从控制台中，我们看到如下内容，程序创建了一个访问`127.0.0.1:5672`中springcloud的连接。

```java
2018-11-26 17:47:33.495  INFO 9728 --- [cTaskExecutor-1] o.s.a.r.c.CachingConnectionFactory : 
Created new connection: SimpleConnection@15ed453c [delegate=amqp://felix@127.0.0.1:5672/, localPort= 5202]
```
同时，我们通过RabbitMQ的控制面板，可以看到Connection和Channels中包含当前连接的条目
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/TIM%E6%88%AA%E5%9B%BE20181126202249.png)

- 运行单元测试类，我们可以看到控制台中输出下面的内容，消息被发送到了RabbitMQ Server的`hello队`列中。
```java
Sender : hello Mon Nov 26 20:25:10 CST 2018
```
- 切换到应用主类的控制台，我们可以看到类似如下输出，消费者对`hello`队列的监听程序执行了，并输出了接受到的消息信息。
```java
Receiver  : hello Mon Nov 26 20:25:10 CST 2018
```

通过上面的示例，我们在Spring Boot应用中引入spring-boot-starter-amqp模块，进行简单配置就完成了对RabbitMQ的消息生产和消费的开发内容。然而在实际应用中，我们还有很多内容没有演示，这里不做更多的讲解，读者可以自行查阅[RabbitMQ的官方教程](https://www.rabbitmq.com/getstarted.html)，有更全面的了解。





















