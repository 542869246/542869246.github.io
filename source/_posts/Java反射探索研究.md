---
title: Java反射探索研究
copyright: true
top: 95
date: 2018-08-24 15:48:59
categories: [java]
tags: [java,反射]
image: http://img18.3lian.com/d/file/201708/31/e6817e04fd2ea8b480b329a9199fc9d4.jpg
---

&nbsp;&nbsp;&nbsp;&nbsp;摘要：本文详细深入讲解是Java中反射的机制，并介绍了如何通过反射来生成对象、调用函数、取得字段、设置字段的方法。最后，给出了一些反射常用到的实例。

<!--more-->

一、反射
====

（1）概念
&nbsp;&nbsp;&nbsp;&nbsp;反射含义：可以获取正在运行的Java对象。  
（2）功能  
&nbsp;&nbsp;&nbsp;&nbsp;1)在运行时判断任意一个对象所属的类  
&nbsp;&nbsp;&nbsp;&nbsp;2)在运行时构造任意一个类的对象  
&nbsp;&nbsp;&nbsp;&nbsp;3) 在运行时判断任意一个类所具有的成员变量和方法  
&nbsp;&nbsp;&nbsp;&nbsp;4)在运行时调用任意一个对象的方法  
（3）实现Java反射的类  
&nbsp;&nbsp;&nbsp;&nbsp;1)Class：它表示正在运行的Java应用程序中的类和接口  
&nbsp;&nbsp;&nbsp;&nbsp;2)Field：提供有关类或接口的属性信息，以及对它的动态访问权限  
&nbsp;&nbsp;&nbsp;&nbsp;3)Constructor：提供关于类的单个构造方法的信息以及对它的访问权限  
&nbsp;&nbsp;&nbsp;&nbsp;4)Method：提供关于类或接口中某个方法信息  
&nbsp;&nbsp;&nbsp;&nbsp;注意：<span style='color:red'>Class类是Java反射中最重要的一个功能类，所有获取对象的信息(包括：方法/属性/构造方法/访问权限)都需要它来实现  </span>

（4）取得class的三种方法

```
Dog dog = new Dog();				 
Class<?> dogClass = dog.getClass();
Class<?> dogClass1 = Dog.class;
Class<?> dogClass2 = Class.forName("com.lin.Dog");//注意要添加异常抛出

```

（5）关键方法

<table border='1'><tr><td>方法关键字</td><td>含义</td></tr><tr><td>getDeclaredMethods()</td><td>获取所有的方法</td></tr><tr><td>getReturnType()</td><td>获得方法的放回类型</td></tr><tr><td>getParameterTypes()</td><td>获得方法的传入参数类型</td></tr><tr><td>getDeclaredMethod("方法名",参数类型.class,……)</td><td>获得特定的方法</td></tr><tr><td></td><td></td></tr><tr><td>构造方法关键字</td><td>含义</td></tr><tr><td>getDeclaredConstructors()</td><td>获取所有的构造方法</td></tr><tr><td>getDeclaredConstructor(参数类型.class,……)</td><td>获取特定的构造方法</td></tr><tr><td></td><td></td></tr><tr><td>父类和父接口</td><td>含义</td></tr><tr><td>getSuperclass()</td><td>获取某类的父类</td></tr><tr><td>getInterfaces()</td><td>获取某类实现的接口</td></tr></table>


（6）一些区别函数

public Method\[\] getMethods()返回某个类的所有公用（public）方法包括其继承类的公用方法，当然也包括它所实现接口的方法。

public Method\[\] getDeclaredMethods()对象表示的类或接口声明的所有方法，包括公共、保护、默认（包）访问和私有方法，但不包括继承的方法。当然也包括它所实现接口的方法。

getFields()获得某个类的所有的公共（public）的字段，包括父类。  
  
getDeclaredFields()获得某个类的所有申明的字段，即包括public、private和proteced，  
但是不包括父类的申明字段。  

下面来看一个例子说明：

动物接口

```
package com.lin;
 
public interface Aminal {
	
	public String eat(String obj);
	
	public int run(int obj);
 
}

```

  
实现类：

```
package com.lin;  
  
import java.util.jar.Attributes.Name;  
  
public class Dog implements Aminal {  
      
    private String name;  
      
    private int age;  
      
    public Dog() {  
        // TODO 自动生成的构造函数存根  
    }  
      
    public Dog(String name,int age) {  
        this.name = name;  
        this.age = age;  
    }     
      
    public Dog(String name) {  
        this.name = name;  
        this.age = 10;  
    }  
      
    private void sleep(int x) {  
        System.out.println(name + "睡觉" + x + "分钟");  
    }  
      
    public String getName() {  
        return name;  
    }  
  
    public void setName(String name) {  
        this.name = name;  
    }  
  
    public int getAge() {  
        return age;  
    }  
  
    public void setAge(int age) {  
        this.age = age;  
    }  
  
    @Override  
    public String eat(String obj) {  
        System.out.println(name + "吃"+ obj);  
        return ;  
    }  
  
    @Override  
    public int run(int obj) {  
        System.out.println("跑，速度："+ obj);  
        return 0;  
    }  
      
    @Override  
    public String toString() {  
        return "狗名：" + name + "  狗的年纪：" + age;  
    }  
      
    private static void play() {  
        System.out.println("狗狗自己玩啊玩");  
    }  
}  
```

  
来看看各自的调用：

```
package com.lin;
 
import java.lang.reflect.Method;
 
public class ReflectLearning {
 
	public static void main(String[] args) throws ClassNotFoundException {
		Dog dog = new Dog();		
		 System.out.println(dog.getClass()); 
		 System.out.println(dog.getClass().getName()); 
		 
		 Class<?> dogClass = dog.getClass();
		 Class<?> dogClass1 = Dog.class;
		 Class<?> dogClass2 = Class.forName("com.lin.Dog");
		 
		 Method[] methods1 = dogClass.getMethods();
		 System.out.println("====================通过getMethods取得方法开始====================");
		 for (Method method : methods1) {
			 System.out.println(method); 
		}
		 System.out.println("====================通过getMethods取得方法结束====================");
		 
		 
		 Method[] methods2 = dogClass.getDeclaredMethods();
		 System.out.println("====================通过getDeclaredMethods取得方法开始====================");
		 for (Method method : methods2) {
			 System.out.println(method); 
		}
		 System.out.println("====================通过getDeclaredMethods取得方法结束====================");
 
 
 
	}
	
 
}

```

  
来看下结果：

getMethods方法

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151122162709709)

getDeclareMethos方法：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151122194430541)  

从上面可以看出getMethods()返回某个类的所有公用（public）方法包括其继承类的公用方法，当然也包括它所实现接口的方法。getDeclaredMethods()对象表示的类或接口声明的所有方法，包括公共、保护、默认（包）访问和私有方法，但不包括继承的方法。当然也包括它所实现接口的方法。

二、通过反射调用构造函数
============

（1）、列出所有的构造函数：

```
Constructor<?>[] constructors = dogClass.getConstructors();
		
System.out.println("====================列出所有的构造函数结束====================");
for (Constructor<?> constructor : constructors) {			
    System.out.println(constructor);
}
System.out.println("====================列出所有的构造函数结束====================");

```

输出结果：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151122164012549)

（2）、通过反射生成对象

```
System.out.println("====================通过newInstance()来生成对象，一定在有默认构造函数====================");
Dog dog1 = (Dog) dogClass.newInstance();
dog1.setName("狗狗1号");
dog1.setAge(7);
System.out.println(dog1);
		 
System.out.println("====================通过newInstance(参数)方法一来生成对象====================");
Dog dog2 = (Dog)constructors[0].newInstance("狗狗2号");
System.out.println(dog2);
 
System.out.println("====================通过newInstance(参数)方法二来生成对象====================");
Constructor con1 = dogClass.getConstructor(new  Class[]{String.class,int.class});     //主要就是这句了
Dog dog3 = (Dog) con1.newInstance(new Object[]{"狗狗3号",14});
System.out.println(dog3);

```

输出结果：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151122165743286)  

从上面可以看出，先通过getConstructor(new  Class\[\]{xxxx.class,yyy.class}),再通过con1.newInstance(new Object\[\]{"xxxxx",...});的方式是最灵活的，可以自动根据输入的参数类型和个数，找到对应的构造函数来调用。第二种方法需要得到构造函数的数组，并且需要知道对应哪一个构造函数。第一种就只能调用无参构造函数。

三、通过反射调用普通函数、静态函数
=================

（1）取得函数的一些基本信息

```
		Class<?> dogClass = Dog.class;
		Method[] methods = dogClass.getDeclaredMethods();
		for (Method method : methods) {
			System.out.println("函数名："+method.getName() +"        函数类型："+ method.getModifiers() + "         函数返回： "+ method.getReturnType() + "        函数参数个数：" + method.getParameterCount());
			
		}

```

输出结果：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151122171525947)  

其中函数类型对应表如下：  
PUBLIC: 1  
PRIVATE: 2  
PROTECTED: 4  
STATIC: 8  
FINAL: 16  
SYNCHRONIZED: 32  
VOLATILE: 64  
TRANSIENT: 128  
NATIVE: 256  
INTERFACE: 512  
ABSTRACT: 1024  
STRICT: 2048  

（2）方法调用

这是当前狗类的方法：

```
package com.lin;
 
import java.util.jar.Attributes.Name;
 
public class Dog implements Aminal {
	
	private String name;
	
	private int age;
	
	public Dog() {
		// TODO 自动生成的构造函数存根
	}
	
	public Dog(String name,int age) {
		this.name = name;
		this.age = age;
	}	
	
	public Dog(String name) {
		this.name = name;
		this.age = 10;
	}
	
	private void sleep(int x) {
		System.out.println(name + "睡觉" + x + "分钟");
	}
	
	public String getName() {
		return name;
	}
 
	public void setName(String name) {
		this.name = name;
	}
 
	public int getAge() {
		return age;
	}
 
	public void setAge(int age) {
		this.age = age;
	}
 
	@Override
	public String eat(String obj) {
		System.out.println(name + "吃"+ obj);
		return null;
	}
 
	@Override
	public int run(int obj) {
		System.out.println("跑，速度："+ obj);
		return 0;
	}
	
	@Override
	public String toString() {
		return "狗名：" + name + "  狗的年纪：" + age;
	}
	
	private static void play() {
		System.out.println("狗狗自己玩啊玩");
	}
	
	
 
}

```

  
不同方法的调用过程：

```
		//调用私有方法
		Method method1 = dogClass.getDeclaredMethod("sleep", int.class);//不要用getMethod，它只能取到public方法
		Dog dog1 = (Dog) dogClass.getConstructor(new Class[] {String.class}).newInstance(new Object[]{"狗狗1号"});
		method1.setAccessible(true);//私有方法一定要加这句
		method1.invoke(dog1, 12);
		
		//调用私有静态方法
                Method method2 = dogClass.getDeclaredMethod("play");//不要用getMethod，它只能取到public方法 
                method2.setAccessible(true);//私有方法一定要加这句
               method2.invoke(dogClass.newInstance()); 
        
               //调用公共方法
		Method method3 = dogClass.getMethod("eat", String.class);//这里也可以用getDeclaredMethod
		Dog dog3 = new Dog("狗狗3号", 45);
		method3.invoke(dog3, "苹果～");

```

  
输出结果：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151122173757753)  

方法调用这里一定要记住getMethod和getDeclaredMethod的区别，并且在调用私有的方法之前一定要加setAccessible（true）这一句，要不会报错！

四、通过反射取得字段、设置字段值
================

(1)怎么通过反射获取类的属性  
&nbsp;&nbsp;&nbsp;&nbsp;a)Class.getDeclaredField(String name);  
返回一个 Field 对象，该对象反映此 Class 对象所表示的类或接口的指定已声明字段。  
&nbsp;&nbsp;&nbsp;&nbsp;b)Class.getDeclaredFields();  
返回 Field 对象的一个数组，这些对象反映此 Class 对象所表示的类或接口所声明的所有字段。  
&nbsp;&nbsp;&nbsp;&nbsp;c)Class.getField(String name);  
返回一个 Field 对象，它反映此 Class 对象所表示的类或接口的指定公共成员字段。  
&nbsp;&nbsp;&nbsp;&nbsp;d)Class.getField();  
返回一个包含某些 Field 对象的数组，这些对象反映此 Class 对象所表示的类或接口的所有可访问公共字段。  

(2)进行属性获取更改  

```
		Dog dog1 = new Dog("狗狗1号", 12);
		System.out.println(dog1);
		
		Class<?> dogClass = dog1.getClass();
		Field field1 = dogClass.getDeclaredField("name");//注意，getField只能取得public的字段
		field1.setAccessible(true);//私有变量必须先设置Accessible为true
	    System.out.println("原本狗名：" + field1.get(dog1));
		
		field1.set(dog1,"狗狗2号");
		
		System.out.println(dog1);	

```

  
输出结果：

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151122194146554)  

值得注意的是获取私有属性的时候必须先设置Accessible为true，然后才能获取。  

  

五、反射常用工具类
=========

（1）bean复制工具
&nbsp;&nbsp;&nbsp;&nbsp;这里可以使用commons-beanutils中的copyProperties()方法，自己写是为了加深对反射的理解。

1、toString的基类

```
package com.lin;
 
import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.Date;
 
/**
 * bean基類
 * @author lin
 *
 */
public class BaseBean {
 
	public String toString() { 
	  StringBuffer sb = new StringBuffer();  
	  SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");  
      Class<?> cls = this.getClass();
      Field[] fields = cls.getDeclaredFields();
	  sb.append(cls.getName() + "{");
      for (Field field : fields) {
	       try {  
          field.setAccessible(true);  
          sb.append(field.getName());  
          sb.append("=");  
          sb.append(field.get(this));  
          sb.append(" ");  
      } catch (Exception e) {  
          e.printStackTrace();  
      } 
	  }
      sb.append("}");
	  return sb.toString();
	}
}

```

  
2、bean复制工具

```
package com.lin;
 
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
 
/**
 * 将一个JavaBean风格对象的属性值拷贝到另一个对象的同名属性中 (如果不存在同名属性的就不拷贝）
 **/
 
public class BeanCopy {
	private static String GET = "get";
	private static String SET = "set";
	
    /**
     * 
     * @param source
     * @param target
     * @throws Exception
     */
	public static void copy(Object source,Object target){
		Class<?> sourceClz = source.getClass();
		Class<?> targetClz = target.getClass();
		// 得到Class对象所表征的类的所有属性(包括私有属性)
		Field[] sourceFields = sourceClz.getDeclaredFields();
		if (sourceFields.length == 0) {
			sourceFields = sourceClz.getSuperclass().getDeclaredFields();
		}
		
		int len = sourceFields.length;
		for (int i = 0; i < len; i++) {
			String fieldName = sourceFields[i].getName();
			Field targetField = null;
			// 得到targetClz对象所表征的类的名为fieldName的属性，不存在就进入下次循环
			try {
				targetField = targetClz.getDeclaredField(fieldName);
			} catch (NoSuchFieldException e) {
				try {
					targetField = targetClz.getSuperclass().getDeclaredField(fieldName);
				} catch (NoSuchFieldException e1) {
					e1.printStackTrace();
				} catch (SecurityException e1) {
					e1.printStackTrace();
				}
			}
			
			if (targetField == null) {
				continue;
			}
			
			// 判断sourceClz字段类型和targetClz同名字段类型是否相同
			if (sourceFields[i].getType() == targetField.getType()) {
				// 由属性名字得到对应get和set方法的名字
				String getMethodName = GET + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1);
				String setMethodName = SET + fieldName.substring(0, 1).toUpperCase() + fieldName.substring(1);
				// 由方法的名字得到get和set方法的Method对象
				Method getMethod;
				Method setMethod;
				try {
					try {
						getMethod = sourceClz.getDeclaredMethod(getMethodName,new Class[] {});//get方法入參為空
					} catch (NoSuchMethodException e) {
						getMethod = sourceClz.getSuperclass().getDeclaredMethod(getMethodName,new Class[] {});
					}
					try {
						setMethod = targetClz.getDeclaredMethod(setMethodName,sourceFields[i].getType());//set方法入參不為空
 
					} catch (NoSuchMethodException e) {
						setMethod = targetClz.getSuperclass().getDeclaredMethod(setMethodName,sourceFields[i].getType());
					}
					// 调用source对象的getMethod方法
					Object result = getMethod.invoke(source, new Object[] {});
					// 调用target对象的setMethod方法
					setMethod.invoke(target, result);
 
				} catch (SecurityException e) {
					e.printStackTrace();
 
				} catch (NoSuchMethodException e) {
					e.printStackTrace();
 
				} catch (IllegalArgumentException e) {
					e.printStackTrace();
 
				} catch (IllegalAccessException e) {
					e.printStackTrace();
 
				} catch (InvocationTargetException e) {
					e.printStackTrace();
 
				}
			} else {
				continue;
 
			}
 
		}
 
	}
 
}

```

使用：

新建两个类：

```
package com.lin;
 
import java.util.Date;
 
public class Car extends BaseBean{
	
	private String name;
	
	private String id;
	 
	private Boolean sellFlag;
	
	private int age;
	
	private double maxSpeed;
	
	private double minSpeed;
	
	private int driverPeople;
	
	private Date date;
 
	public String getName() {
		return name;
	}
 
	public void setName(String name) {
		this.name = name;
	}
 
	public String getId() {
		return id;
	}
 
	public void setId(String id) {
		this.id = id;
	}
 
	public Boolean getSellFlag() {
		return sellFlag;
	}
 
	public void setSellFlag(Boolean sellFlag) {
		this.sellFlag = sellFlag;
	}
 
	public int getAge() {
		return age;
	}
 
	public void setAge(int age) {
		this.age = age;
	}
 
	public double getMaxSpeed() {
		return maxSpeed;
	}
 
	public void setMaxSpeed(double maxSpeed) {
		this.maxSpeed = maxSpeed;
	}
 
	public double getMinSpeed() {
		return minSpeed;
	}
 
	public void setMinSpeed(double minSpeed) {
		this.minSpeed = minSpeed;
	}
 
	public int getDriverPeople() {
		return driverPeople;
	}
 
	public void setDriverPeople(int driverPeople) {
		this.driverPeople = driverPeople;
	}
 
	public Date getDate() {
		return date;
	}
 
	public void setDate(Date date) {
		this.date = date;
	}
	
	
	
 
}

```

  
另一个：

```
package com.lin;
 
import java.util.Date;
 
public class Bus extends BaseBean{
	private String name;
	
	private String id;
	 
	private Boolean sellFlag;
	
	private int age;
	
	private double maxSpeed;
	
	private double minSpeed;
	
	private long driverPeople;//和car類型不同
	
	private int driverYear;//car沒有這個
	
	private Date date;
 
	public String getName() {
		return name;
	}
 
	public void setName(String name) {
		this.name = name;
	}
 
	public String getId() {
		return id;
	}
 
	public void setId(String id) {
		this.id = id;
	}
 
	public Boolean getSellFlag() {
		return sellFlag;
	}
 
	public void setSellFlag(Boolean sellFlag) {
		this.sellFlag = sellFlag;
	}
 
	public int getAge() {
		return age;
	}
 
	public void setAge(int age) {
		this.age = age;
	}
 
	public double getMaxSpeed() {
		return maxSpeed;
	}
 
	public void setMaxSpeed(double maxSpeed) {
		this.maxSpeed = maxSpeed;
	}
 
	public double getMinSpeed() {
		return minSpeed;
	}
 
	public void setMinSpeed(double minSpeed) {
		this.minSpeed = minSpeed;
	}
 
	public long getDriverPeople() {
		return driverPeople;
	}
 
	public void setDriverPeople(long driverPeople) {
		this.driverPeople = driverPeople;
	}
 
	public int getDriverYear() {
		return driverYear;
	}
 
	public void setDriverYear(int driverYear) {
		this.driverYear = driverYear;
	}
 
	public Date getDate() {
		return date;
	}
 
	public void setDate(Date date) {
		this.date = date;
	}
	
	
 
}

```

  
调用：

```
	public static void test5() {
		Car car = new Car();
		car.setAge(12);
		car.setDriverPeople(4);
		car.setId("YU1234");
		car.setMaxSpeed(13.66);
		car.setMinSpeed(1.09);
		car.setName("小车");
		car.setSellFlag(false);
		car.setDate(new Date());
		
		
		Bus bus = new Bus();
		BeanCopy.copy(car,bus);
		System.out.println(car);
		System.out.println(bus);
		
		
	}

```

  

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20151122205834415)

除了两个不同的字段外，其它的都复制过去了，这在DTO、VO、DOMAIN对象转换时经常用到。

<br/>
[林炳文Evankaka](http://my.csdn.net/?ref=toolbar)原创作品。转载请注明出处[http://blog.csdn.net/evankaka](http://blog.csdn.net/evankaka)