---
title: Java类加载器深入探索
copyright: true
top: 95
date: 2018-08-24 15:49:10
categories: [java]
tags: [java,反射,类加载器]
image: http://pic.58pic.com/58pic/13/17/91/75a58PICc5R_1024.jpg
---
<span>
<!--more-->

什么是.class文件？
============

&nbsp;&nbsp;&nbsp;&nbsp;class文件全名称为Java class文件，主要在平台无关性和网络移动性方面使Java更适合网络。它在平台无关性方面的任务是：为Java程序提供独立于底层主机平台的二进制形式的服务。class文件径打破了C或者C++等语言所遵循的传统，使用这些传统语言写的程序通常首先被编译，然后被连接成单独的、专门支持特定硬件平台和操作系统的二进制文件。通常情况下，一个平台上的二进制可执行文件不能在其他平台上工作。而Java class文件是可以运行在任何支持Java虚拟机的硬件平台和操作系统上的二进制文件。而这也是Java宣称的“一次编译，到处运行”的真正原因，因为各个系统上的Java文件都是被编译成.class文件，然后通过虚拟机来加载运行的。

什么是类加载器？
========

&nbsp;&nbsp;&nbsp;&nbsp;类加载器是一个用来加载类文件的类。Java源代码通过javac编译器编译成类文件。然后JVM来执行类文件中的字节码来执行程序。类加载器负责加载文件系统、网络或其他来源的类文件。有三种默认使用的类加载器：Bootstrap类加载器、Extension类加载器和System类加载器（或者叫作Application类加载器）。每种类加载器都有设定好从哪里加载类。

生成一个对象实例发生了什么事？
===============

&nbsp;&nbsp;&nbsp;&nbsp;生成一个实例，程序主要会把对应的类的java文件使用编译器生成字节码文件，然后等此类被调用静态变量或方法或生成实例时，虚拟机自动去相应目录查找字节码文件，并加载到虚拟机当中，然后生成对应的实例对象。每一个字节码文件只会被加载一次。其过程如下：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20150920142201727)  

  

类加载的方式
======

&nbsp;&nbsp;&nbsp;&nbsp;Java提供两种方法来达成动态行，一种是隐式的，另一种是显式的。这两种方式底层用到的机制完全相同，差异只有程序代码不同。隐式的就是当用到new这个Java关键字时，会让类加载器依需求载入所需的类。显式的又分为两种方法：一种是借用java.lang.Class里的forName()方法，另一种则是借用java.lang.ClassLoader里的loadClass()方法。  

类加载器的树状组织结构及加载文件目录
==================

&nbsp;&nbsp;&nbsp;&nbsp;Java 中的类加载器大致可以分成两类，一类是系统提供的，另外一类则是由 Java 应用开发人员编写的。系统提供的类加载器主要有下面三个：

(1) Bootstrap ClassLoader（引导类加载器） : 它用来加载 Java 的核心库，是用原生代码来实现的，并不继承自 java.lang.ClassLoader。将存放于<JAVA_HOME>\\lib目录中的，或者被-Xbootclasspath参数所指定的路径中的，并且是虚拟机识别的（仅按照文件名识别，如 rt.jar 名字不符合的类库即使放在lib目录中也不会被加载）类库加载到虚拟机内存中。启动类加载器无法被Java程序直接引用  
  
(2) Extension ClassLoader（扩展类加载器） : 它用来加载 Java 的扩展库。Java 虚拟机的实现会提供一个扩展库目录。该类加载器在此目录里面查找并加载 Java 类。将<JAVA_HOME>\\lib\\ext目录下的，或者被java.ext.dirs系统变量所指定的路径中的所有类库加载。开发者可以直接使用扩展类加载器。  
  
(3) Application ClassLoader或叫System Classloader （系统类加载器）: 负责加载用户类路径(ClassPath)上所指定的类库,开发者可直接使用。它根据 Java 应用的类路径（CLASSPATH）来加载 Java 类。一般来说，Java 应用的类都是由它来完成加载的。可以通过 ClassLoader.getSystemClassLoader()来获取它。

以下有两种方式来取得类加载器的组织结构：

```
package com.lin;
public class ClassLoadTest1 {
	public static void main(String[] args) {		
		 ClassLoader loader = ClassLoadTest1.class.getClassLoader(); 
		 ClassLoader loader1 = ClassLoader.getSystemClassLoader();
		 //从子到父取得加载器
	        while (loader != null) { 
	            System.out.println(loader.toString()); 
	            loader = loader.getParent(); 
	        } 
	        while (loader1 != null) { 
	            System.out.println(loader1.toString()); 
	            loader1 = loader1.getParent(); 
	        } 
	}
 
}

```

输出结果：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20150920145542249)  

  

可以看到，两种方法都是先取得 Application ClassLoader，然后再取得Extension ClassLoader。

表 1\. ClassLoader 中与加载类相关的方法

<table border='1'><tr><td>方法</td><td>说明</td><tr><tr><td>getParent()</td><td>返回该类加载器的父类加载器。</td><tr><tr><td>loadClass(String name)</td><td>加载名称为 name的类，返回的结果是 java.lang.Class类的实例。</td><tr><tr><td>findClass(String name)</td><td>查找名称为 name的类，返回的结果是 java.lang.Class类的实例。</td><tr><tr><td>findLoadedClass(String name)</td><td>查找名称为 name的已经被加载过的类，返回的结果是 java.lang.Class类的实例</td><tr><tr><td>defineClass(String name, byte[] b, int off, int len)</td><td>把字节数组 b中的内容转换成 Java 类，返回的结果是 java.lang.Class类的实例。这个方法被声明为 final的。</td><tr><tr><td>resolveClass(Class<?> c)</td><td>链接指定的 Java 类。</td><tr></table>

&nbsp;&nbsp;&nbsp;&nbsp;除了系统提供的类加载器以外，开发人员可以通过继承 java.lang.ClassLoader类的方式实现自己的类加载器，以满足一些特殊的需求。除了引导类加载器之外，所有的类加载器都有一个父类加载器。通过 表 1中给出的 getParent()方法可以得到。对于系统提供的类加载器来说，系统类加载器的父类加载器是扩展类加载器，而扩展类加载器的父类加载器是引导类加载器；对于开发人员编写的类加载器来说，其父类加载器是加载此类加载器 Java 类的类加载器。因为类加载器 Java 类如同其它的 Java 类一样，也是要由类加载器来加载的。一般来说，开发人员编写的类加载器的父类加载器是系统类加载器。类加载器通过这种方式组织起来，形成树状结构。树的根节点就是引导类加载器。下图 中给出了一个典型的类加载器树状组织结构示意图，其中的箭头指向的是父类加载器。  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20150920143136831)  

  

每次加载的具体的过程：

类加载器工作过程
========

类装载器就是寻找类的字节码文件，并构造出类在JVM内部表示的对象组件。在Java中，类装载器把一个类装入JVM中，要经过以下步骤：  
(1) 装载：查找和导入Class文件；  
(2) 链接：把类的二进制数据合并到JRE中；  
&nbsp;&nbsp;&nbsp;&nbsp;(a)校验：检查载入Class文件数据的正确性；  
&nbsp;&nbsp;&nbsp;&nbsp;(b)准备：给类的静态变量分配存储空间；  
&nbsp;&nbsp;&nbsp;&nbsp;(c)解析：将符号引用转成直接引用；

(3) 初始化：对类的静态变量，静态代码块执行初始化操作

类加载器的工作原理
=========

  
(1)委托机制  
&nbsp;&nbsp;&nbsp;&nbsp;当一个类加载和初始化的时候，类仅在有需要加载的时候被加载。假设你有一个应用需要的类叫作Abc.class，首先加载这个类的请求由Application类加载器委托给它的父类加载器Extension类加载器，然后再委托给Bootstrap类加载器。Bootstrap类加载器会先看看rt.jar中有没有这个类，因为并没有这个类，所以这个请求由回到Extension类加载器，它会查看jre/lib/ext目录下有没有这个类，如果这个类被Extension类加载器找到了，那么它将被加载，而Application类加载器不会加载这个类；而如果这个类没有被Extension类加载器找到，那么再由Application类加载器从classpath中寻找。记住classpath定义的是类文件的加载目录，而PATH是定义的是可执行程序如javac，java等的执行路径。  

工作过程：如果一个类加载器接收到了类加载的请求，它首先把这个请求委托给他的父类加载器去完成，每个层次的类加载器都是如此，因此所有的加载请求都应该传送到顶层的启动类加载器中，只有当父加载器反馈自己无法完成这个加载请求（它在搜索范围中没有找到所需的类）时，子加载器才会尝试自己去加载。

  

  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20150920154823695)

&nbsp;&nbsp;&nbsp;&nbsp;好处：java类随着它的类加载器一起具备了一种带有优先级的层次关系。例如类java.lang.Object，它存放在rt.jar中，无论哪个类加载器要加载这个类，最终都会委派给启动类加载器进行加载，因此Object类在程序的各种类加载器环境中都是同一个类。相反，如果用户自己写了一个名为java.lang.Object的类，并放在程序的Classpath中，那系统中将会出现多个不同的Object类，java类型体系中最基础的行为也无法保证，应用程序也会变得一片混乱。

&nbsp;&nbsp;&nbsp;&nbsp;首先需要说明一下 Java 虚拟机是如何判定两个 Java 类是相同的。Java 虚拟机不仅要看类的全名是否相同，还要看加载此类的类加载器是否一样。只有两者都相同的情况，才认为两个类是相同的。即便是同样的字节代码，被不同的类加载器加载之后所得到的类，也是不同的。比如一个 Java 类 com.example.Sample，编译之后生成了字节代码文件 Sample.class。两个不同的类加载器 ClassLoaderA和 ClassLoaderB分别读取了这个 Sample.class文件，并定义出两个 java.lang.Class类的实例来表示这个类。这两个实例是不相同的。对于 Java 虚拟机来说，它们是不同的类。试图对这两个类的对象进行相互赋值，会抛出运行时异常 ClassCastException。下面通过示例来具体说明。

```
package com.lin;
 
public class Sample {
	private Sample instance; 
    public void setSample(Object instance) { 
        this.instance = (Sample) instance; 
    } 
    public void say(){
    	System.out.println("Hello LinBingwen");
    }
}

```

  
然后是使用：

```
package com.lin;
 
import java.net.*;
import java.lang.reflect.*;
 
public class ClassLoadTest4{
  public static void main(String[] args) throws ClassNotFoundException, MalformedURLException, IllegalAccessException, NoSuchMethodException, InstantiationException, InvocationTargetException{
    ClassLoader pClassLoader = ClassLoader.getSystemClassLoader(); // 以System ClassLoader作为父类加载器
    URL[] baseUrls = {new URL("file:/E:/workspace/Eclipse/ClassLoadTest")}; // 搜索类库的目录
    final String binaryName = "com.lin.Sample"; // 需要加载的类的二进制名称
 
    ClassLoader userClassLoader1 = new URLClassLoader(baseUrls, pClassLoader);
    ClassLoader userClassLoader2 = new URLClassLoader(baseUrls, pClassLoader);
    Class clazz1 = userClassLoader1.loadClass(binaryName);
    Class clazz2 = userClassLoader2.loadClass(binaryName);
    Object instance1 = clazz1.newInstance();
    Object instance2 = clazz2.newInstance();
    // 调用say方法
    clazz1.getMethod("say").invoke(instance1);
    clazz2.getMethod("say").invoke(instance2);
    // 输出类的二进制名称
    System.out.println(clazz1.toString());
    System.out.println(clazz2.toString());
 
    // 比较两个类的地址是否相同
    System.out.println(clazz1 == clazz2);
    // 比较两个类是否相同或是否为继承关系
    System.out.println(clazz1.isAssignableFrom(clazz2));
    // 查看类型转换是否成功
    boolean ret = true;
    try{
       Method setSampleMethod = clazz1.getMethod("setSample", java.lang.Object.class); 
       setSampleMethod.invoke(instance1, instance2); 
    } catch (Exception e) { 
	    e.printStackTrace(); 
    } 
    System.out.println(ret);
    
  } 
}

```

输出结果：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20150920161618517)

因为都是从 ClassLoader.getSystemClassLoader(); // 以System ClassLoader作为父类加载器，所以两个加载器其实是一样的。

(2)可见性机制  
根据可见性机制，子类加载器可以看到父类加载器加载的类，而反之则不行。所以下面的例子中，当Abc.class已经被Application类加载器加载过了，然后如果想要使用Extension类加载器加载这个类，将会抛出java.lang.ClassNotFoundException异常。  

```
package com.lin;
 
import java.util.logging.Level;
import java.util.logging.Logger;
 
public class ClassLoadTest2 {
 
	public static void main(String[] args) {
		try {          
            //打印当前的类加载器
            System.out.println("ClassLoadTest2.getClass().getClassLoader() : "
                                 + ClassLoadTest2.class.getClassLoader());
 
            //使用扩展类加载器再次加载子类加载器加载过的
            Class.forName(" com.lin.ClassLoadTest1", true
                            ,  ClassLoadTest2.class.getClassLoader().getParent());
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ClassLoadTest2.class.getName()).log(Level.SEVERE, null, ex);
        }
 
	}
 
}

```

  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20150920152839964)

(3)单一性机制  
根据这个机制，父加载器加载过的类不能被子加载器加载第二次。虽然重写违反委托和单一性机制的类加载器是可能的，但这样做并不可取。你写自己的类加载器的时候应该严格遵守这三条机制。  

  

参考文章：

1、https://www.ibm.com/developerworks/cn/java/j-lo-classloader/

2、http://www.cnblogs.com/ITtangtang/p/3978102.html

3、http://www.cnblogs.com/rason2008/archive/2012/01/01/2309718.html

4、http://www.importnew.com/6581.html

<br/>
[林炳文Evankaka](http://my.csdn.net/?ref=toolbar)原创作品。转载请注明出处[http://blog.csdn.net/evankaka](http://blog.csdn.net/evankaka)