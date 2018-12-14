---
title: Mybatis开发神器 - MyBatisCodeHelper-Pro插件
copyright: true
top: 95
date: 2018-12-12 11:31:30
categories: [java]
tags: [java,mybatis,MyBatisCodeHelper-Pro]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/12433.jpg?x-oss-process=style/ys30
description: Intellij下MyBatis开发神器
---

<span></span>

<!--more-->

先声明下：该插件只支持Intellij！！！Eclipse暂时不支持！！！

> 文档地址：https://gejun123456.github.io/MyBatisCodeHelper-Pro/#/README
> github：https://github.com/gejun123456/MyBatisCodeHelper-Pro



## 功能简介

- 通过方法名(不需要方法的返回值和参数 会自动推导出来)来生成sql 可以生成大部分单表操作的sql 只需要一个方法的名字即可 会自动补全好方法的参数和返回值 和springdatajpa的语句基本一致
- sql全自动提示，sql正确性检测，插件会识别mybatis的一系列标签 如 include trim set where，在这些标签之后的sql可以自动提示数据库的字段，检测sql的正确性，从此不用担心sql写错
- 直接从Intellij自带的数据库或者配置一个数据库生成crud代码 自动检测好 useGeneratedkey 自动配置好模块的文件夹 只用添加包名就可以生成代码了
- 从java类生成mybatis crud代码 建表语句 支持生成service，建表支持生成多字段的索引
数据库添加字段后可以继续生成，不会修改之前已经在接口或xml添加的自定义的方法 无需再去进行手动的添加
- mybatis接口和xml的互相跳转 支持一个mybatis接口对应多个xml
- mybatis接口中的方法名重构支持
- xml中的 param的自动提示 if test的自动提示 resultMap refid 等的自动提示
- resultMap中的property的自动提示
- xml中refid，resultMap等的跳转到定义
- 检测没有使用的xml 可一键删除
- 检测mybatis接口中方法是否有实现，没有则报红 可创建一个空的xml
- 检测resultmap的property是否有误
- mybatis接口中一键添加param注解
- mybatis接口一键生成xml
- 支持spring 将mapper注入到spring中 intellij的spring注入不再报错 支持springboot
- 一键生成mybatis接口的testcase 无需启动spring，复杂sql可进行快速测试

## 插件未激活与激活状态的功能比较

|                                     功能点                                    | 未激活版 |  激活版  |
|:-----------------------------------------------------------------------------:|:--------:|:--------:|
| 接口与xml互相跳转 更换图标                                                    |     ✔    |     ✔    |
| 接口方法名重构                                                                |     ✔    |     ✔    |
| 一键添加param                                                                 |     ✔    |     ✔    |
| xml中的 param的自动提示 if test的自动提示 resultMap refid 等的自动提示        |     ✔    |     ✔    |
| resultMap中的property的自动提示                                               |     ✔    |     ✔    |
| 检测没有使用的xml 可一键删除                                                  |     ✔    |     ✔    |
| 检测mybatis接口中方法是否有实现，没有则报红 可创建一个空的xml方法块           |     ✔    |     ✔    |
| 检测resultmap的property是否有误                                               |     ✔    |     ✔    |
| 支持spring 将mapper注入到spring中 intellij的spring注入不再报错 支持springboot |     ✔    |     ✔    |
| 一键生成分页查询                                                              |     ✔    |     ✔    |
| 一键添加resultMap中未被使用的属性                                             |     ✔    |     ✔    |
| 一键生成mybatis接口的testcase                                                 |     ✘    |     ✔    |
| 通过方法名生成sql                                                             |     ✘    |     ✔    |
| 通过数据库生成crud代码                                                        |     ✘    |     ✔    |
| 通过java类生成crud代码                                                        |     ✘    |     ✔    |
| xml collection中的 param提示                                                  |     ✘    |     ✔    |
| 识别mybatis的标签 全自动sql补全                                               |     ✘    |     ✔    |


激活版需要购买，1RMG 10day / 3RMB 30day / 29RMG 1year，价格还是挺划算的。可以免费试用7天。

## 安装和配置

`Preferences(Settings)` > `Plugins` > `Browse repositories...` > 搜索并找到"MybatisCodeHelper-Pro" > `Install Plugin`
重启即可

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20181212settings.png)

## 功能

接口与xml互相跳转

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1544594062712_0.png)


接口方法名重构，resultMap重构 refid重构 等
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1544594087724_1.png)

一键添加param注解
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1544594093206_2.png)

xml中param的自动 提示  2.0.2版本支持添加jdbcType
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1544594096449_3.png)

xml if test的自动提示、每个param会提示是否等于null、string类型 会提示是否为null 是否为空串
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1544594100351_4.png)

resultMap中property的自动提示、refid 和 resultMap的自动提示
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1544594104046_5.png)

检测 xml是否有对应接口(没有id变灰) 检测接口方法是否有对应的xml(没有方法名变红)
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1544594118582_6.png)

一键生成查询分页操作，插件依赖pageHelper 来做分页处理（spring boot依赖pagehelper-spring-boot-starter）
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/1544594139411_9.png)












