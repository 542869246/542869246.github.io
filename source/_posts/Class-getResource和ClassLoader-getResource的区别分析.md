---
title: Class.getResource和ClassLoader.getResource的区别分析
copyright: true
top: 95
date: 2018-11-12 10:26:46
categories: [java]
tags: [java]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/15595.jpg?x-oss-process=style/ys30
description: 在Java中获取资源的时候，经常用到Class.getResource和ClassLoader.getResource，本文给大家说一下这两者方法在获取资源文件的路径差异。
---

<span></span>

<!--more-->


  
## Class.getResource(String path)
path不以'/'开头时，默认是从此类所在的包下取资源；path以'/'开头时，则是从项目的ClassPath根下获取资源。在这里'/'表示ClassPath  
JDK设置这样的规则，是很好理解的，path不以'/'开头时，我们就能获取与当前类所在的路径相同的资源文件，而以'/'开头时可以获取ClassPath根下任意路径的资源。  
如下所示的例子：

```java
public class Test {

    public static void main(String[] args) {

        System.out.println(Test.class.getResource(""));
        System.out.println(Test.class.getResource("/"));
    }
}
```

运行结果为：  
file:/D:/work_space/java/bin/net/swiftlet/  
file:/D:/work_space/java/bin/

## Class.getClassLoader().getResource(String path)
path不能以'/'开头时，path是指类加载器的加载范围，在资源加载的过程中，使用的逐级向上委托的形式加载的，'/'表示Boot ClassLoader中的加载范围，因为这个类加载器是C++实现的，所以加载范围为null。如下所示：

```java
public class Test {

    public static void main(String[] args) {

        System.out.println(Test.class.getClassLoader().getResource(""));
        System.out.println(Test.class.getClassLoader().getResource("/"));
    }
}
```

运行结果为：  
file:/D:/work_space/java/bin/  
null  
**从上面可以看出：**  
class.getResource("/") == class.getClassLoader().getResource("")  
其实，Class.getResource和ClassLoader.getResource本质上是一样的，都是使用ClassLoader.getResource加载资源的。下面请看一下jdk的Class源码:

```java
public java.net.URL getResource(String name) {

        name = resolveName(name);
        ClassLoader cl = getClassLoader0();
        if (cl==null) {
            // A system class.
            return ClassLoader.getSystemResource(name);
        }
        return cl.getResource(name);
    }
```

从上面就可以看才出来：Class.getResource和ClassLoader.getResource本质上是一样的。至于为什么Class.getResource(String path)中path可以'/'开头，是因为在name = resolveName(name);进行了处理：

```java
 private String resolveName(String name) {
        if (name == null) {
            return name;
        }
        if (!name.startsWith("/")) {
            Class c = this;
            while (c.isArray()) {
                c = c.getComponentType();
            }
            String baseName = c.getName();
            int index = baseName.lastIndexOf('.');
            if (index != -1) {
                name = baseName.substring(0, index).replace('.', '/')
                    +"/"+name;
            }
        } else {//如果是以"/"开头，则去掉
            name = name.substring(1);
        }
        return name;
    }
```

