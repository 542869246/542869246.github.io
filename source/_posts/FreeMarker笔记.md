---
title: FreeMarker笔记
date: 2018-08-01 09:24:56
copyright: true
categories: java
tags: [java,FreeMarker,模板引擎]
top: 90
image: http://pic1.win4000.com/wallpaper/2018-05-03/5aeabbe4313a2.jpg
description: FreeMarker是一个很值得去学习的模版引擎。它是基于模板文件生成其他文本的通用工具。
---
<span>
<!--more-->

##### FreeMarker是一个很值得去学习的模版引擎。它是基于模板文件生成其他文本的通用工具。本章内容通过如何使用FreeMarker生成Html web 页面 和 代码自动生成工具来快速了解FreeMarker。

### 简介
FreeMarker是一款用java语言编写的模版引擎，它虽然不是web应用框架，但它很合适作为web应用框架的一个组件。


##### 特点
1. ==轻量级==模版引擎，不需要Servlet环境就可以很轻松的嵌入到应用程序中
2. 能生成各种文本，如html，xml，java，等
3. 入门==简单==，它是用java编写的，很多语法和java相似

### FreeMarker 程序
这里通过模拟简单的代码自动生产工具来感受第一个FreeMarker程序。


###### 项目目录结构

![image](https://note.youdao.com/yws/api/personal/file/7F3E305ECC7C4D43B3723E432DABD9F5?method=download&shareKey=871330817cb4fa023023ff95f9c3a3de)


###### eclipse安装freemarker插件
<div class="note default no-icon"><p>Help –> Install New Software
点add，再出来的对话框中的Location中输入：http://download.jboss.org/jbosstools/updates/stable/indigo/
name随便取一个即可。然后会列出来所有可用的插件，
JBoss Application Development 下找到 FreeMarker IDE选中 点击Next 
安装好重启eclipse就可以了。
过程可能有点慢，请==耐心等待==。</p></div>

###### maven依赖

```
<dependency>
	<groupId>org.freemarker</groupId>
	<artifactId>freemarker</artifactId>
	<version>2.3.23</version>
</dependency>
```

hello.ftl模板(部分)
![image](https://note.youdao.com/yws/api/personal/file/65DD084F98E647AB86F1D08C5440559F?method=download&shareKey=78c42c5bd58a114675064cd0e0386924)

FreeMarkerDemo.java 核心方法，使用 FreeMarker 模版引擎。
```
package com.freemarker.hello.templates;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.freemarker.hello.pojo.User;

import freemarker.template.Configuration;
import freemarker.template.Template;

/**
 * 最常见的问题： java.io.FileNotFoundException: xxx does not exist. 解决方法：要有耐心
 * FreeMarker jar 最新的版本（2.3.23）提示 Configuration 方法被弃用 代码自动生产基本原理： 数据填充
 * freeMarker 占位符
 */
public class FreeMarkerDemo {

	private static final String TEMPLATE_PATH = "src/main/java/com/freemarker/hello/templates";
	private static final String CLASS_PATH = "src/main/java/com/freemarker/hello";
	private static List<User> users = new ArrayList<User>();

	static {
		User u1 = new User("1", 22, "迟到峰");
		User u2 = new User("2", 23, "要饭楚");
		User u3 = new User("3", 27, "BUG李");
		User u4 = new User("4", 25, "删库冬");
		User u5 = new User("5", 29, "瓜子军");
		User u6 = new User("6", 28, "老韩");
		User u7 = new User(null, 25, null);
		users.add(u1);
		users.add(u2);
		users.add(u3);
		users.add(u4);
		users.add(u5);
//		users.add(null);
		users.add(u6);
//		users.add(u7);
//		users.clear();
	}

	public static void main(String[] args) {
		// step1 创建freeMarker配置实例
		Configuration configuration = new Configuration(Configuration.VERSION_2_3_23);
		Writer out = null;
		try {
			// step2 获取模版路径
			configuration.setDirectoryForTemplateLoading(new File(TEMPLATE_PATH));
			// step3 创建数据模型
			Map<String, Object> dataMap = new HashMap<String, Object>();
			dataMap.put("classPath", "com.freemarker.hello");
			dataMap.put("htmlName", "使用FreeMarker生成html模板");
			dataMap.put("helloWorld", "通过简单的 <代码自动生产程序> 演示 FreeMarker的HelloWorld！");
			dataMap.put("author", "周宇峰");
			dataMap.put("github", "github.com/542869246");
			dataMap.put("name", "abcdefg");
			dataMap.put("dateTime",new Date());
			dataMap.put("users", users);
			
			// step4 加载模版文件
			Template template = configuration.getTemplate("hello.ftl");
			// step5 生成数据
			File docFile = new File(CLASS_PATH + "\\" + "hello.html");
			out = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(docFile)));
			// step6 输出文件
			template.process(dataMap, out);
			System.out.println("文件创建成功 !");
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				if (null != out) {
					out.flush();
				}
			} catch (Exception e2) {
				e2.printStackTrace();
			}
		}
	}

}
```

运行程序后刷新项目，会发现多了一个hello.html文件。

## 语法详解


### 数据类型
###### 和java不同，FreeMarker不需要定义变量的类型，直接赋值即可。

字符串： value = "xxxx" 。 单引号和双引号是一样的。字符串中可以使用转义字符”\"。如果字符串内有大量的特殊字符，则可以在引号的前面加上一个字母r，则字符串内的所有字符都将直接输出。string = r"xxxx"。

数值：value = 1.2。数值可以直接等于，但是不能用科学计数法。

布尔值：true or false。

List集合：list = [1,2,3] ; list=[1..100] 表示 1 到 100 的集合，反之亦然。

Map集合：map = {"key" : "value" , "key2" : "value2"}，key 必须是字符串

时间对象:

```
root.put("date1",new Date());
${date1?string("yyyy-MM-dd HH:mm:ss")}
```
JaveBean：Freemarker中对于javabean的处理跟EL表达式一致，类型可自动转化！非常方便！

###### 注释：<#-- abcd -->

### 字符串操作


###### 声明变量和输出:


```
<#assign name="zyf">         //声明一个变量值为zyf的变量name
${name}                      //输出name  结果为zyf
<#assign cname=r"特殊字符完成输出(https://github.com/542869246)">
${cname}
```


##### 字符串连接：
```
//使用嵌套或者+ 进行字符串连接操作
${"Hello ${name} !"} / ${"Hello " + name + " !"}
//输出：Hello zyf ! / Hello zyf ! 
```

##### 字符串截取：

```
<#assign a="abcdefg">
${a[1]}                     //b
${a[1..5]}                  //bcdef
${a?substring(3)}           //efg
${a?substring(3,2)}         //ef
```
<div class="note default"><p>string[index]。index 可以是一个值，也可以是形如 0..2 表示下标从0开始，到下标为2结束。一共是三个数。
substring（start,end）从一个字符串中截取子串。
start:截取子串开始的索引，start必须大于等于0，小于等于end。
end: 截取子串的长度，end必须大于等于0，小于等于字符串长度，如果省略该参数，默认为字符串长度。</p></div>

### 算数运算：
支持"+"、"－"、"*"、"/"、"%"运算符

```
<#assign number1=10 number2=5 >
"+":${number1 + number2 }       //15
"-":${number1 - number2 }       //5
"*":${number1 * number2 }       //50
"/":${number1 / number2 }       //2
"%":${number1 % number2 }       //0
```


### 比较运算符
表达式中支持的比较运算符有如下几种：
1. =（或者==）：判断两个值是否相等；
2. !=：判断两个值是否不相等；
注： =和!=可以用作字符串、数值和日期的比较，但两边的数据类型必须相同。而且FreeMarker的比较是精确比较，==不会忽略大小写及空格==。
3. \>（或者gt）：大于
4. \>=（或者gte）：大于等于
5. <（或者lt）：小于
6. <=（或者lte）：小于等于
7. 
```
<#if number1 + number2 gte 12 || number1 - number2 lt 6>
"*" : ${number1 * number2}
<#else>
"/" : ${number1 / number2}
</#if>
```

<div class="note info"><p>上面这些比较运算符可以用于数字和日期，但不能用于字符串。大部分时候，使用==gt比>有更好的效果==，因为FreeMarker会把>解释成标签的结束字符。可以使用括号来避免这种情况，如：<#if (x>y)>。</p></div>

### 逻辑运算符
1. &&：逻辑与；
2. ||：逻辑或；
3. !：逻辑非
<div class="note info"><p>逻辑运算符只能用于布尔值。</p></div>

### 内建函数
<div class="note info"><p>FreeMarker还提供了一些内建函数来转换输出,可以在任何变量后紧跟?,?后紧跟内建函数,就可以通过内建函数来轮换输出变量.下面是常用的内建的字符串函数</p></div>

##### 字符串相关常用的内建函数：
```
<#assign data = "abcd1234">
html：对字符串进行HTML编码，将字符串中的<、>、&和“替换为对应得&lt;&gt;&quot:&amp

cap_first：使字符串第一个字母大写 ${data?cap_first}

lower_case：将字符串转成小写 ${data?lower_case}

upper_case：将字符串转成大写 ${data?upper_case}

trim:去掉字符串前后的空白字符 ${data?trim}

length:返回字符串的长度 ${"string"?length}

index_of(substring,start)在字符串中查找某个子串，返回找到子串的第一个字符的索引，如果没有找到子串，则返回-1。
Start参数用于指定从字符串的那个索引处开始搜索，start为数字值。
如果start大于字符串长度，则start取值等于字符串长度，如果start小于0， 则start取值为0。
${"string"?index_of("in") 结果为3
${"string"?index_of("ab") 结果为-1

replace用于将字符串中的一部分从左到右替换为另外的字符串。
${"strabg"?replace("ab","in")} 结果为string

split使用指定的分隔符将一个字符串拆分为一组字符串
<#list "This|is|split"?split("|"") as s>
${s}
</#list>
结果为:
This
is
split

```

##### 集合相关常用的内建函数：
```
size：获得集合中元素的个数 ${users?size}
```


##### 数字值相关常用的内建函数：
```
<#assign floatData = 12.34>
int：取得数字的整数部分 ${floatData?int}
```

### 三元运算符
```
${(users?size gt 15)?string('a','b') }
<#assign theValue = (temp == "default")?string('true','false') />
```



### 空值处理运算符
<div class="note default no-icon"><p>FreeMarker对空值的处理非常严格,==FreeMarker的变量必须有值==,没有被赋值的变量就会抛出异常,因为FreeMarker未赋值的变量强制出错可以杜绝很多潜在的错误,如缺失潜在的变量命名,或者其他变量错误.这里所说的空值,实际上也包括那些并不存在的变量,对于一个Java的 null值而言,我们认为这个变量是存在的,只是它的值为null,但对于FreeMarker模板而言,它无法理解null值,null值和不存在的变量完全相同。</p></div>

###### FreeMarker提供两个运算符来避免空值
1. !：指定缺失变量的默认值
2. ??：判断变量是否存在

<div class="note default no-icon"><p>!运算符有两种用法：variable!或variable!defaultValue。第一种用法不给变量指定默认值，表明默认值是空字符串、长度为0的集合、或长度为0的Map对象。==使用!运算符指定默认值并不要求默认值的类型和变量类型相同==。</p></div>

<div class="note default no-icon"><p>??运算符返回布尔值，如：variable??，如果变量存在，返回true，否则返回false。</p></div>

```
<#if user??>
    ${user.name!"变量为空则给一个默认值"}
<#else>
    users为空
</#if>
```

### 常用指令
<div class="note default no-icon"><p>FreeMarker的FTL指令也是模板的重要组成部分,这些指令可实现对数据模型所包含数据的抚今迭代,分支控制.除此之外,还有一些重要的功能,也是通过FTL指令来实现的. </p></div>


#### if指令
这是一个典型的分支控制指令,该指令的作用完全类似于Java语言中的if,if指令的语法格式如下
```
<#assign age=23> 
<#if (age>60)>老年人 
<#elseif (age>40)>中年人 
<#elseif (age>20)>青年人 
<#else> 少年人 
</#if> 
```
#### switch case指令
switch（expr）,其中expr只能是字符串、基本类型int或者包装类Integer，也包括不同的长度整型，例如short
```
<#switch being.size>  
  <#case "small">  
          This will be processed if it is small  
          <#break>  
  <#case "medium">  
          This will be processed if it is medium  
          <#break>  
  <#case "large">  
          This will be processed if it is large  
          <#break>  
  <#default>  
          This will be processed if it is neither  
</#switch>
```
#### list指令
<div class="note default no-icon"><p>list指令是一个迭代输出指令,用于迭代输出数据模型中的集合
sequence是集合(collection)的表达式，item是循环变量的名字，不能是表达式。
当在遍历sequence时，会将遍历变量的值保存到item中</p></div>

```
//格式
<#list sequence as item>    
  ${item}   
</#list>

//遍历users集合 获取user对象属性
<#list users as user>    
  ${user.id}--${user.age}--{user.name}
</#list>
```

###### List指令还隐含了两个循环变量：
item_index:当前迭代项在所有迭代项中的位置，是数字值。

item_has_next:用于判断当前迭代项是否是所有迭代项中的最后一项。

```
<#list users as user>    
  ${user_index}--${user.id}--${user.age}--{user.name}
    <#if !user_has_next>
        共有${users?size}最后一个用户是:${user.name}
    </#if>
</#list>
```

###### 对List进行排序
<div class="note default no-icon"><p>通常我们的排序操作都是通过DAO层来实现的，如果我们想随时更改我们的排序，那么就必须修改我们的DAO层代码，确实不方便。但Freemarker为我们提供了这样的排序方法，解决了这个问题。</p></div>

1.  sort升序排序函数
sort对序列(sequence)进行排序，要求序列中的变量必须是：字符串（按首字母排序）,数字，日期值。

```
<#list list?sort as l>…</#list>
```

2.  sort_by函数
sort_by有一个参数,该参数用于指定想要排序的子变量，排序是按照变量对应的值进行排序,如：

```
<#list users?sort_by("age") as user>…</#list>
```

age是User对象的属性，排序是按age的值进行的。
3.  reverse降序排序函数
    
```
<#list list? reverse as l>…</#list>。
```

reverse使用同sort相同。reverse还可以同sort_by一起使用
如：想让用户按年龄降序排序，那么可以这个样写

```
<#list users?sort_by("age")?reverse as user>…</#list>
```

##### 使用list指令遍历map

```
//创建一个map,注意在freemarker中,map的key只能是字符串来作为key
<#assign userMap={"1","刘德华","2":"张学友"}/>

//获取map中的值
${userMap["1"]}

//获取map的keys
<#assign  keys=userMap?keys/>

//遍历map 首选获取key的集合
<#list keys as key>
  key:${key}-value:${userMap["${key}"]}
</#list>

//直接遍历map的第二种方式
<#list userMap?keys as key>
  key:${key}--value:${userMap["${key}"]}
</#list>

//直接遍历map的values
<#list userMap?values as value>
 ${value}
</#list>
```

#### include指令
include指令的作用类似于JSP的包含指令,用于包含指定页

```
现在有hello.ftl、inc1.ftl与inc2.ftl 3个模板
在inc1.ftl与inc2.ftl中的内容分别是:
<#assign username="刘德华">与<#assign username="张学友">

接着在hello.ftl模版中用include将inc1.ftl包含进来
<#include "/inc/inc1.ftl">
${username}
此刻获取的结果是:刘德华

接着我们在hello.ftl用include将inc1.ftl与inc2.ftl同时进行包含进来

<#include "/inc/inc1.ftl">
<#include "/inc/inc2.ftl">
${username}

此刻获取的值是:张学友
```
###### 总结：出现这种情况，在==两个模版中都分别存在变量名都相同的变量的时候，include包含进来，会进行覆盖==，include只时候将其公共的静态文件进行包含，而里面不涉及到内部函数以及变量声明之类的，当涉及到这种问题，我们就要用import进行导入

#### import指令
该指令用于导入FreeMarker模板中的所有变量,并将该变量放置在指定的Map对象中

```
接着上面
在hello.ftl用import指令将inc1.ftl与inc2.ftll模板文件中的所有变量,同时导入进来
<#import "/inc/inc1.ftl" as inc1>
<#import "/inc/inc2.ftl" as inc2>

${inc1.username}    //刘德华
${inc2.username}    //张学友

```

#### noparse指令
noparse指令指定FreeMarker不处理该指定里包含的内容,该指令的语法格式如下

```
<#noparse>...</#noparse>

看如下的例子: 
<#noparse> 
<#list books as book> 
   <tr><td>${book.name}<td>作者:${book.author} 
</#list> 
</#noparse> 
输出如下: 
<#list books as book> 
   <tr><td>${book.name}<td>作者:${book.author} 
</#list> 

```
#### assign指令
<div class="note default no-icon"><p>assign指令在前面已经使用了多次,它用于为该模板页面创建或替换一个顶层变量,assign指令的用法有多种,包含创建或替换一个顶层变量, 或者创建或替换多个变量等,它的最简单的语法如下:<#assign name=value [in namespacehash]>,这个用法用于指定一个名为name的变量,该变量的值为value,此外,FreeMarker允许在使用 assign指令里增加in子句,in子句用于将创建的name变量放入namespacehash命名空间中
assign指令还有如下用法:</p></div>

```
<#assign name1=value1 name2=value2 ... nameN=valueN [in namespacehash]>
这个语法可以同时创建或替换多个顶层变量,此外,还有一种复杂的用法,如果需要创建或替换的变量值是一个复杂的表达式,则可以使用如下语法格式:
<#assign name [in namespacehash]>capture this</#assign>
在这个语法中,是指将assign指令的内容赋值给name变量.如下例子:
<#assign x> 
<#list ["星期一", "星期二", "星期三", "星期四", "星期五", "星期六", "星期天"] as n> 
${n} 
</#list> 
</#assign> 
${x} 
上面的代码将产生如下输出:星期一 星期二 星期三 星期四 星期五 星期六 星期天 

```
###### 虽然assign指定了这种复杂变量值的用法,但是我们也不要滥用这种用法,如下例子:

```
<#assign x>Hello ${user}!</#assign>
以上代码改为如下写法更合适:
<#assign x="Hello ${user}!">
```
#### setting指令
该指令用于设置FreeMarker的运行环境,该指令的语法格式如下:

```
<#setting name=value>
```
在这个格式中,name的取值范围包含如下几个：

locale:该选项指定该模板所用的国家/语言选项 

number_format:指定格式化输出数字的格式

boolean_format:指定两个布尔值的语法格式,默认值是true,false 

date_format,time_format,datetime_format:指定格式化输出日期的格式 

time_zone:设置格式化输出日期时所使用的时区

#### 自定义指令(macro指令)(宏)
语法：

```
<#macro name param1 param2 ... paramN>
...
<#nested loopvar1, loopvar2, ..., loopvarN>
...
<#return>
...
</#macro>
```
用例：

```
//定义名为test的指令
<#macro test foo bar="Bar" baaz=-1>
这是自定义指令: ${foo}, ${bar}, ${baaz}
</#macro>

//调用test指令
<@test foo="a" bar="b" baaz=5*5-2/> //这是自定义指令: a, b, 23
<@test foo="a" bar="b"/>            //这是自定义指令: a, b, -1
<@test foo="a" baaz=5*5-2/>         //这是自定义指令: a, Bar, 23
<@test foo="a"/>                    //这是自定义指令: a, Bar, -1
```
<div class="note default no-icon"><p>可以提前返回，比如<#return/> 但是不能<#return 1>， ==A macro cannot return a value== 
==宏主要作用是拼接内容，把宏内部的字符串展示出来，return返回值没有意义==。</p></div>

#### function指令(函数)
用例：

```
 <#function buildPageUrl url pageNum data>

    <#assign pageUrl = "${url}?pageNum=${pageNum}&pageSize=${data.pageSize}">

    <#return pageUrl/>

</#function>

${buildPageUrl(url2,page.pageNum+1,page)}

```

<div class="note default no-icon"><p>与宏的调用方式不同，直接 ${buildPageUrl(url2,page.pageNum+1,page)}执行函数。==返回值才是最关键的结果，不是为了显示函数内部的字符串内容==。</p></div>


### 参考文章（特别鸣谢）：
[https://blog.csdn.net/qq_34129814/article/details/76218863](https://blog.csdn.net/qq_34129814/article/details/76218863)

[https://segmentfault.com/a/1190000011768799](https://segmentfault.com/a/1190000011768799)

[https://blog.csdn.net/fhx007/article/details/7902040/](https://blog.csdn.net/fhx007/article/details/7902040/)

[https://www.cnblogs.com/qitian1/p/6463098.html](https://www.cnblogs.com/qitian1/p/6463098.html)

----

#### 源码地址：
###### github: [https://github.com/542869246/myfreemarker](https://github.com/542869246/myfreemarker)
###### 码云: [https://gitee.com/zyf542869246/myfreemarker](https://gitee.com/zyf542869246/myfreemarker)

---

###### Author:周宇峰
###### Github:[https://github.com/542869246](https://github.com/542869246)
###### 码云:[https://gitee.com/zyf542869246](https://gitee.com/zyf542869246)
###### Time:2018/5/14 1:45:11