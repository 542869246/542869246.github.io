---
title: Spring任务调度之Quartz
copyright: true
top: 95
date: 2018-08-21 08:47:21
categories: [java]
tags: [java,Spring,Quartz]
image: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535736989079&di=3a69a220e9137dcf77907b0e023d68b6&imgtype=0&src=http%3A%2F%2Fp15.qhimg.com%2Fbdr%2F__%2Ft015f052f044d1d96fe.jpg
---

`Quartz`是`OpenSymphony`开源组织在`Job scheduling`领域又一个开源项目，是完全由java开发的一个开源的任务日程管理系统，“任务进度管理器”就是一个在预先确定（被纳入日程）的时间到达时，负责执行（或者通知）其他软件组件的系统。 
<!--more-->
`Quartz`用一个小Java库发布文件（.jar文件），这个库文件包含了所有Quartz核心功能。这些功能的主要接口(API)是`Scheduler`接口。它提供了简单的操作，例如：将任务纳入日程或者从日程中取消，开始/停止/暂停日程进度。 
* * *


#### 一、Quartz作业类的继承方式来讲，可以分为两类：

1.  作业类需要继承自特定的作业类基类，如Quartz中需要继承自`org.springframework.scheduling.quartz.QuartzJobBean`；`java.util.Time`r中需要继承自`java.util.TimerTask`。
2.  作业类即普通的java类，不需要继承自任何基类。

注:推荐使用第二种方式，因为这样所以的类都是普通类，不需要事先区别对待。

*   ##### 从任务调度的触发时机来分，这里主要是针对作业使用的触发器，主要有以下两种：
    

1.  每隔指定时间则触发一次，在`Quartz`中对应的触发器为：`org.springframework.scheduling.quartz.SimpleTriggerBean`
2.  每到指定时间则触发一次，在`Quartz`中对应的调度器为：`org.springframework.scheduling.quartz.CronTriggerBean`

注：并非每种任务都可以使用这两种触发器，如`java.util.TimerTask`任务就只能使用第一种。`Quartz`和`spring tas`k都可以支持这两种触发条件。

* * *

#### 第一种，作业类继承自特定的基类：org.springframework.scheduling.quartz.QuartzJobBean

##### 第一步：定义作业类

```java
import org.quartz.JobExecutionContext;  
import org.quartz.JobExecutionException;  
import org.springframework.scheduling.quartz.QuartzJobBean;  
public class Job1 extends QuartzJobBean {  

  private int timeout;  
  private static int i = 0;  
  //调度工厂实例化后，经过timeout时间开始执行调度  
  public void setTimeout(int timeout) {  
  this.timeout = timeout;  
  }  
  
  /** 
  * 要调度的具体任务 
  */ 
  @Override 
  protected void executeInternal(JobExecutionContext context)  
  throws JobExecutionException {  
  System.out.println("定时任务执行中…");  
  } 

}  
```

##### 第二步：spring配置文件中配置作业类JobDetailBean

```
<bean name="job1" class="org.springframework.scheduling.quartz.JobDetailBean">  
<property name="jobClass" value="com.gy.Job1" />  
<property name="jobDataAsMap">  
  <map>  
    <entry key="timeout" value="0" />  
  </map>  
</property>  
</bean>  
```

<div class="note info"><p>说明：org.springframework.scheduling.quartz.JobDetailBean有两个属性，jobClass属性即我们在java代码中定义的任务类，jobDataAsMap属性即该任务类中需要注入的属性值。</p></div>

##### 第三步：配置作业调度的触发方式（触发器）

   Quartz的作业触发器有两种，分别是

   `org.springframework.scheduling.quartz.SimpleTriggerBean`

   `org.springframework.scheduling.quartz.CronTriggerBean`

###### 第一种 SimpleTriggerBean，只支持按照一定频度调用任务，如每隔30分钟运行一次。配置方式如下：

```
<bean id="simpleTrigger" class="org.springframework.scheduling.quartz.SimpleTriggerBean">  
  <property name="jobDetail" ref="job1" />  
  <property name="startDelay" value="0" /><!--调度工厂实例化后，经过0秒开始执行调度 -->  
  <property name="repeatInterval" value="2000" /><!--每2秒调度一次 -->  
</bean>  
```
###### 第二种 CronTriggerBean，支持到指定时间运行一次，如每天12:00运行一次等。配置方式如下：

```
<bean id="cronTrigger" class="org.springframework.scheduling.quartz.CronTriggerBean">  
  <property name="jobDetail" ref="job1" />  
  <!--每天12:00运行一次-->  
  <property name="cronExpression" value="0 0 12 * * ?" />  
</bean>  
```
##### 第四步：配置调度工厂

```
<bean class="org.springframework.scheduling.quartz.SchedulerFactoryBean">  
  <property name="triggers">  
    <list>  
      <ref bean="cronTrigger" />  
    </list>  
  </property>  
</bean>  
```
*说明：该参数指定的就是之前配置的触发器的名字。*

##### 第五步：启动你的应用即可，即将工程部署至tomcat或其他容器。

* * *

#### 第二种，作业类不继承特定基类。

Spring能够支持这种方式，归功于两个类：

`org.springframework.scheduling.timer.MethodInvokingTimerTaskFactoryBean`

`org.springframework.scheduling.quartz.MethodInvokingJobDetailFactoryBean`

这两个类分别对应spring支持的两种实现任务调度的方式，即前文提到到java自带的timer task方式和Quartz方式。这里我只写MethodInvokingJobDetailFactoryBean的用法，使用该类的好处是,我们的任务类不再需要继承自任何类，而是普通的pojo。

##### 第一步：编写任务类
```
public class Job2 {  
  public void doJob2() {  
    System.out.println("不继承QuartzJobBean方式-调度进行中…");  
  }  
}
```
**说明：可以看出，这就是一个普通的类，并且有一个方法。**

##### 第二步：配置作业类

```
<bean id="job2" class="org.springframework.scheduling.quartz.MethodInvokingJobDetailFactoryBean">  
  <property name="targetObject">  
    <bean class="com.gy.Job2" />  
  </property>  
  <property name="targetMethod" value="doJob2" />  
  <property name="concurrent" value="false" /><!-- 作业不并发调度 -->  
</bean>  
```
*说明：这一步是关键步骤，声明一个MethodInvokingJobDetailFactoryBean，有两个关键属性：targetObject指定任务类，targetMethod指定运行的方法。往下的步骤就与方法一相同了，为了完整，同样贴出。*

##### 第三步：配置作业调度的触发方式（触发器）

   Quartz的作业触发器有两种，分别是

   `org.springframework.scheduling.quartz.SimpleTriggerBean`

   `org.springframework.scheduling.quartz.CronTriggerBean`

###### 第一种SimpleTriggerBean，只支持按照一定频度调用任务，如每隔30分钟运行一次。配置方式如下：

```
<bean id="simpleTrigger" class="org.springframework.scheduling.quartz.SimpleTriggerBean">  
  <property name="jobDetail" ref="job2" />  
  <property name="startDelay" value="0" /><!-- 调度工厂实例化后，经过0秒开始执行调度 -->  
  <property name="repeatInterval" value="2000" /><!-- 每2秒调度一次 -->  
</bean>  
```
###### 第二种CronTriggerBean，支持到指定时间运行一次，如每天12:00运行一次等。配置方式如下：

```
<bean id="cronTrigger" class="org.springframework.scheduling.quartz.CronTriggerBean">  
  <property name="jobDetail" ref="job2" />  
  <!--每天12:00运行一次 -->  
  <property name="cronExpression" value="0 0 12 * * ?" />  
</bean>  
```
**以上两种调度方式根据实际情况，任选一种即可。**

##### 第四步：配置调度工厂

```
<bean class="org.springframework.scheduling.quartz.SchedulerFactoryBean">  
  <property name="triggers">  
    <list>  
      <ref bean="cronTrigger" />  
    </list>  
  </property>  
</bean>  
```
*说明：该参数指定的就是之前配置的触发器的名字。*

##### 第五步：启动你的应用即可，即将工程部署至tomcat或其他容器。

**到此，spring中Quartz的基本配置就介绍完了，当然了，使用之前，要导入相应的spring的包与Quartz的包，这些就不消多说了。**

#### 参考

[《官网》](http://www.quartz-scheduler.org/)
[《Quartz任务调度快速入门》](http://sishuok.com/forum/posts/list/405.html )
[《深入解读Quartz的原理》](http://lavasoft.blog.51cto.com/62575/181907/ )
[《Quartz学习-阿飞(dufyun)》](https://blog.csdn.net/u010648555/article/category/6601767)
[《Spring任务调度之Quartz-独具匠心》](https://www.cnblogs.com/hongwz/p/5642429.html)
[《基于Quartz开发企业级任务调度应用》](http://www.ibm.com/developerworks/cn/opensource/os-cn-quartz/ )
[《Quartz 数据库表含义解释》](http://blog.csdn.net/tengdazhang770960436/article/details/51019291 )
[《Quartz源码分析》](https://my.oschina.net/chengxiaoyuan/blog/664833 )
[《Quartz系列》](http://blog.csdn.net/Evankaka/article/category/3155529)
