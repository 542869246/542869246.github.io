---
title: Java反射探索-----从类加载说起
copyright: true
top: 95
date: 2018-08-24 14:29:49
categories: [java]
tags: [java,反射,类加载]
image: http://pic1.win4000.com/wallpaper/3/52e249408d6a6.jpg
description: 摘要：本文主要讲了Java类加载的机制，这是学习反射的入门基础。
---
<span>
<!--more-->
&nbsp;&nbsp;&nbsp;&nbsp;摘要：本文主要讲了Java类加载的机制，这是学习反射的入门基础。


一、类加载
=====

**JVM和类**  
 
&nbsp;&nbsp;&nbsp;&nbsp;当我们调用Java命令运行某个Java程序时，该命令将会启动一条Java虚拟机进程，不管该Java程序有多么复杂，该程序启动了多少个线程，它们都处于该Java虚拟机进程里。正如前面介绍的，同一个JVM的所有线程、所有变量都处于同一个进程里，它们都使用该JVM进程的内存区。当系统出现以下几种情况时，JVM进程将被终止:  
  
1、程序运行到最后正常结束。  
2、程序运行到使用System.exit()或Runtime.getRuntime().exit()代码结束程序。  
3、程序执行过程中遇到未捕获的异常或错误而结束。  
3、程序所在平台强制结束了JVM进程。  
从上面的介绍可以看出，当Java程序运行结束时，JVM进程结束，该进程在内存中状态将会丢失。

**类的生命周期**

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151021091611555)

**类的加载/类初始化**  
  
&nbsp;&nbsp;&nbsp;&nbsp;当程序主动使用某个类时，如果该类还未被加载到内存中，系统会通过加载、连接、初始化三个步骤来对该类进行初始化，如果没有意外，JVM将会连续完成这三个步骤，所以有时也把这三个步骤统称为类加载或类初始化。

**加载：查找并加载类的二进制数据**

1、通过一个类的全限定名来获取定义此类的二进制字节流。  
2、将这个字节流所代表的静态存储结构转化为方法区的运行时数据结构。  
3、在java堆中生成一个代表这个类的java.lang.Class对象，作为方法区这些数据的访问入口。

<span style='color:red'>**注意：将编译后的java类文件（也就是.class文件）中的二进制数据读入内存，并将其放在运行时数据区的方法区内，然后再堆区创建一个Java.lang.Class对象，用来封装类在方法区的数据结构。即加载后最终得到的是Class对象，并且更加值得注意的是：该Java.lang.Class对象是单实例的，无论这个类创建了多少个对象，他的Class对象时唯一的！**  </span>
**连接：**  
&nbsp;&nbsp;&nbsp;&nbsp;1、验证：确保被加载的类的正确性  
&nbsp;&nbsp;&nbsp;&nbsp;2、准备：为类的静态变量分配内存，并将其初始化为默认值  
&nbsp;&nbsp;&nbsp;&nbsp;3、解析：把类中的符号引用转换为直接引用。  
**初始化：为类的静态变量赋予正确的初始值。**

**<span style='color:red'>注意：连接和初始化阶段，其实静态变量经过了两次赋值：第一次是静态变量类型的默认值；第二次是我们真正赋给静态变量的值。</span>**

我简单画了个图，其过程如下：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151021091656155)  

**<span style='color:red'>类加载指的是将类的class文件读入内存，并为之创建一个java.lang.Class对象，也就是说当程序中使用任何类时，系统都会为之建立一个java.lang.Class对象。事实上，每个类是一批具有相同特征的对象的抽象(或者说概念)，而系统中所有的类，它们实际上也是对象，它们都是java.lang.Class的实例。</span>**  
  
&nbsp;&nbsp;&nbsp;&nbsp;**加载由类加载器完成，类加载器通常由JVM提供，这些类加载器也是我们前面所有程序运行的基础，JVM提供的这些类加载器通常被称为系统类加载器。除此之外，开发者可以通过继承ClassLoader基类来创建自己的类加载器。**  
  
通过使用不同的类加载器，可以从不同来源加载类的二进制数据，通常有如下几种来源:  
  
** 1、从本地文件系统来加载class文件，这是绝大部分示例程序的类加载方式。  **  
**  2、从JAR包中加载class文件，这种方式也是很常见的，前面介绍JDBC编程时用到的数据库驱动类就是放在JAR文件中，JVM可以从JAR文件中直接加载该class文件。  **  
**  3、通过网络加载class文件。  **  
**  4、把一个Java源文件动态编译、并执行加载。**  
  
类加载器通常无须等到“首次使用”该类时才加载该类，Java虚拟机规范允许系统预先加载某些类。

**Java程序对类的使用方式  **  
**  主动使用**  
1、创建类的实例  
2、方法某个类或接口的静态变量，或者对该静态变量赋值  
3、调用类的静态方法  
4、反射（如 Class.forName(“com.itzhai.Test”)）  
5、初始化一个类的子类  
6、Java虚拟机启动时被标明为启动类的类（Main Class）  
  
**被动使用**  
除了以上6中方式，其他对类的使用都是被动使用，都不会导致类的初始化。类的初始化时机正是java程序对类的首次主动使用，  
所有的Java虚拟机实现必须在每个类或接口被Java程序“首次主动使用”时才初始化它们。

**对象初始化**  
在类被装载、连接和初始化，这个类就随时都可能使用了。对象实例化和初始化是就是对象生命的起始阶段的活动，在这里我们主要讨论对象的初始化工作的相关特点。  
Java 编译器在编译每个类时都会为该类至少生成一个实例初始化方法--即"<init>()" 方法。此方法与源代码中的每个构造方法相对应，如果类没有明确地声明任何构造方法，编译器则为该类生成一个默认的无参构造方法，这个默认的构造器仅仅调用父类的无参构造器，与此同时也会生成一个与默认构造方法对应的 "<init>()" 方法.  
通常来说，<init>() 方法内包括的代码内容大概为：调用另一个 <init>() 方法；对实例变量初始化；与其对应的构造方法内的代码。  
如果构造方法是明确地从调用同一个类中的另一个构造方法开始，那它对应的 <init>() 方法体内包括的内容为：一个对本类的 <init>() 方法的调用；对应用构造方法内的所有字节码。  
如果构造方法不是通过调用自身类的其它构造方法开始，并且该对象不是 Object 对象，那 <init>() 法内则包括的内容为：一个对父类 <init>() 方法的调用；对实例变量初始化方法的字节码；最后是对应构造子的方法体字节码。  
如果这个类是 Object，那么它的 <init>() 方法则不包括对父类 <init>() 方法的调用。

  

二、Class.forName、实例对象.class(属性)、实例对象getClass()的区别
================================================

1、相同点：  
通过这几种方式，得到的都是Java.lang.Class对象（这个是上面讲到的类在加载时获得的最终产物）  
例如：

```
package com.lin;
 
/**
 * 功能概要：
 * 
 * @author linbingwen
 * @since  2015年10月20日 
 */
public class people {
 
	/**
	 * @author linbingwen
	 * @since  2015年10月20日 
	 * @param args    
	 */
	public static void main(String[] args) throws Exception {
		System.out.println("..............使用不同的方式加载类...................");
		System.out.println(people.class);//通过类.class获得Class对象
		people a = new people();
		System.out.println(a.getClass());//通过 实例名.getClass()获得Class对象
		System.out.println(Class.forName("com.lin.people"));//通过Class.forName(全路径)获得Class对象
		System.out.println("..............使用不同的方式创建对象...................");
		System.out.println(a);//使用不同的方式创建对象
		System.out.println(people.class.newInstance());
		System.out.println(a.getClass().newInstance());
		System.out.println(Class.forName("com.lin.people").newInstance()); 
 
	}
 
}

```

结果：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151021091837350)

  
从上面可以看到不同的方式加载类。其实这一过程只发生一次！

2、区别：

下面用一个实例来说说它们的区别

如下新建一个类

```
package com.lin;
 
/**
 * 功能概要：
 * 
 * @author linbingwen
 * @since  2015年10月20日 
 */
public class Cat {
	static {
		System.out.println("生成了一只猫");
	}
 
}

```

  

然后开始使用：

```
package com.lin;
 
/**
 * 功能概要：
 * 
 * @author linbingwen
 * @since  2015年10月20日 
 */
public class CatTest {
 
	/**
	 * @author linbingwen
	 * @since  2015年10月20日 
	 * @param args    
	 */
	public static void main(String[] args) throws Exception{
		System.out.println("---------------Cat.class开始------------------");
		System.out.println(Cat.class);//通过类.class获得Class对象
		System.out.println("---------------Cat.class结束------------------");
		
		System.out.println("---------------Class.forName开始------------------");
		System.out.println(Class.forName("com.lin.Cat"));//通过Class.forName(全路径)获得Class对象
		System.out.println("---------------Class.forName结束------------------");
		
		System.out.println("---------------cat.getClass()开始------------------");
		Cat cat = new Cat();
		System.out.println(cat.getClass());//通过Class.forName(全路径)获得Class对象
		System.out.println("---------------cat.getClass()结束------------------");
		
	}
 
}

```

输出结果：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151021092000170)

如果，将Class.forName()去掉：

如下：

```
package com.lin;
 
/**
 * 功能概要：
 * 
 * @author linbingwen
 * @since  2015年10月20日 
 */
public class CatTest {
 
	/**
	 * @author linbingwen
	 * @since  2015年10月20日 
	 * @param args    
	 */
	public static void main(String[] args) throws Exception{
		System.out.println("---------------Cat.class开始------------------");
		System.out.println(Cat.class);//通过类.class获得Class对象
		System.out.println("---------------Cat.class结束------------------");
		
//		System.out.println("---------------Class.forName开始------------------");
//		System.out.println(Class.forName("com.lin.Cat"));//通过Class.forName(全路径)获得Class对象
//		System.out.println("---------------Class.forName结束------------------");
		
		System.out.println("---------------cat.getClass()开始------------------");
		Cat cat = new Cat();
		System.out.println(cat.getClass());//通过Class.forName(全路径)获得Class对象
		System.out.println("---------------cat.getClass()结束------------------");
		
	}
 
}

```

结果又变成：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151021092344220)

  

所以，可以得出以下结论：

1)Class cl=Cat.class; **JVM将使用类Cat的类装载器,将类A装入内存(前提是:类A还没有装入内存),不对类A做类的初始化工作.**返回类A的Class的对象  
2)Class cl=对象引用o.getClass();**返回引用o运行时真正所指的对象(因为:儿子对象的引用可能会赋给父对象的引用变量中)所属的类的Class的对象 ,如果还没装载过，会进行装载。**  
3)Class.forName("类名"); **装入类A,并做类的初始化(前提是:类A还没有装入内存)**  
  

三、new和newInstance()
===================

从JVM的角度看，我们使用关键字new创建一个类的时候，这个类可以没有被加载。但是使用Class对象的newInstance()方法的时候，就必须保证：

1、这个类已经加载；

2、这个类已经连接了。而完成上面两个步骤的正是Class的静态方法forName()所完成的，这个静态方法调用了启动类加载器，即加载 java API的那个加载器。   
  
现在可以看出，Class对象的newInstance()（这种用法和Java中的工厂模式有着异曲同工之妙）实际上是把new这个方式分解为两步，即首先调用Class加载方法加载某个类，然后实例化。这样分步的好处是显而易见的。我们可以在调用class的静态加载方法forName时获得更好的灵活性，提供给了一种降耦的手段。 

Class.forName().newInstance()和通过new得到对象的区别

  
1、使用newInstance可以解耦。使用newInstance的前提是，类已加载并且这个类已连接，这是正是class的静态方法forName（）完成的工作。newInstance实际上是把new 这个方式分解为两步，即，首先调用class的加载方法加载某个类，然后实例化。  
  
2、newInstance: 弱类型。低效率。只能调用无参构造。 new: 强类型。相对高效。能调用任何public构造。   
  
3、newInstance()是实现IOC、反射、面对接口编程和依赖倒置等技术方法的必然选择，new只能实现具体类的实例化，不适合于接口编程。   
  
4、 newInstance() 一般用于动态加载类。  
  

5、Class.forName(“”).newInstance()返回的是object 。

6、newInstance( )是一个方法，而new是一个关键字；

注:一般在通用框架里面用的就是class.forName来加载类,然后再通过反射来调用其中的方法,譬如Tomcat源码里面,这样就避免了new关键字的耦合度,还有让不同的类加载器来加载不同的类,方便提高类之间的安全性和隔离性.


[林炳文Evankaka](http://my.csdn.net/Evankaka)原创作品。转载请注明出处[http://blog.csdn.net/evankaka](http://blog.csdn.net/evankaka)