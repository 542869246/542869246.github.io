---
title: Spring+Quartz的版本问题
copyright: true
top: 95
date: 2018-08-21 08:35:58
categories: [java]
tags: [java,Spring,Quartz]
image: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535736996648&di=f4862c3d53b6e554d3d7c136ac62bfac&imgtype=0&src=http%3A%2F%2Fwww.ggeye.com%2Fpic%2Fbig%2F5%2F3282647757.jpg
---

```
Caused by: java.lang.IncompatibleClassChangeError: class org.springframework.scheduling.quartz.CronTriggerBean has interface org.quartz.CronTrigger as superclass
```

<!--more-->

原因是Spring 3.0版本中内置的Quartz版本是<2.0的，在使用最新的Quartz包(>2.0)之后，接口不兼容。

解决办法有三种：

1.降低Quartz版本，降到1.X去。

2.升级Spring版本到3.1+，根据Spring的建议，将原来的**TriggerBean替换成**TriggerFactoryBean，例如CronTriggerBean 就可以替换成 CronTriggerFactoryBean。替换之后问题解决。

3.如果不在xml配置文件中引用 Spring 3.0 是支持 Quartz2.2.1(目前最新版本)，直接在程序中调用即可。