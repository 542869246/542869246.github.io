---
title: 手写mini版本的Spring
copyright: true
top: 95
date: 2018-11-09 19:15:57
categories: [java]
tags: [java,Spring,反射]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/0e6b3e49d9cd950bc4f8db95a893f684.jpg?x-oss-process=style/ys30
description: 纯手写实现Spring基本的IOC、DI、MVC
---

<span></span>

<!--more-->

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;此篇文章面向有spring、反射机制有基础的人。

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;昨天看了个大佬的视屏，1小时手写了个简单的Spring框架，感触极深。今天特地花了一天时间，也写了个mini版的Spring框架，基本功能完整，不过离真正的Spring还差十万八千里。

首先，先来介绍一下Spring的三个阶段，配置阶段、初始化阶段和运行阶段：

- 配置阶段：主要是完成application.xml配置和Annotation配置。
- 初始化阶段：主要是加载并解析配置信息，然后，初始化IOC容器，完成容器的DI操作，已经完成HandlerMapping的初始化。
- 运行阶段：主要是完成Spring容器启动以后，完成用户请求的内部调度，并返回响应结果。

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/145547vx81m3ypcdrp3hh1.png)


项目结构(如下图)：
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20181109193035.png)

## 准备

### pom.xml需要的依赖：

```xml

        <!-- https://mvnrepository.com/artifact/javax.servlet/javax.servlet-api -->
        <dependency>
            <groupId>javax.servlet</groupId>
            <artifactId>javax.servlet-api</artifactId>
            <version>3.1.0</version>
            <!-- 编译测试期间有效 -->
            <scope>provided</scope>
        </dependency>

```

没错只需要一个servlet-api。

### controller
```java

@FFController()
@FFRequestMapping("/demo")
public class DemoController {

    @FFAutowired
    private IDemoService demoService;

    @FFRequestMapping("/query.json")
    public void query(HttpServletRequest request, HttpServletResponse response,
                      @FFRequestParam("name") String name) {
        String result = demoService.get(name);

        try {
            response.getWriter().write(result);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @FFRequestMapping("/add")
    public void add(HttpServletRequest request, HttpServletResponse response,
                    @FFRequestParam("a") String a, @FFRequestParam("b") String b) {
        try {
            response.getWriter().write(a + b);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @FFRequestMapping("/remove")
    public void remove(HttpServletRequest request, HttpServletResponse response,
                       @FFRequestParam("id") String id) {
        try {
            response.getWriter().write(id);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}


```
注解为自定义注解，可暂时不加

### service
```java
public interface IDemoService {

    String get(String name);
}
```

```java
@FFService
public class DemoService implements IDemoService{

    @Override
    public String get(String name) {
        return "Hello," + name;
    }
}
```
注解为自定义注解，可暂时不加
### application.properties

```
scanPackage=com.felix.demo
```

### web.xml
```
<!DOCTYPE web-app PUBLIC
        "-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN"
        "http://java.sun.com/dtd/web-app_2_3.dtd" >

<web-app>
    <display-name>Felix Web Application</display-name>
    <servlet>
        <servlet-name>ffmvc</servlet-name>
        <servlet-class>com.felix.mvcframework.servlet.FFDispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>application.properties</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
        <servlet-name>ffmvc</servlet-name>
        <url-pattern>/*</url-pattern>
    </servlet-mapping>

</web-app>
```


## 编写自定义注解
### FFController、FFAutowired、FFRequestMapping、FFRequestParam、FFService
```
/**
 * 创建FFController注解
 *
 * @Target说明了Annotation所修饰的对象范围：Annotation可被用于 packages、types（类、接口、枚举、Annotation类型）、
 * 类型成员（方法、构造方法、成员变量、枚举值）、方法参数和本地变量（如循环变量、catch参数）
 * @Retention定义了该Annotation被保留的时间长短：某些Annotation仅出现在源代码中， 而被编译器丢弃；
 * 而另一些却被编译在class文件中；编译在class文件中的Annotation可能会被虚拟机忽略，
 * 而另一些在class被装载时将被读取（请注意并不影响class的执行，因为Annotation与class在使用上是被分离的）。
 * @Documented用于描述其它类型的annotation应该被作为被标注的程序成员的公共API， 因此可以被例如javadoc此类的工具文档化。
 * Documented是一个标记注解，没有成员。
 */
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface FFController {
    String value() default "";
}


//FFAutowired
@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface FFAutowired {
    String value() default "";
}

//FFRequestMapping
@Target({ElementType.TYPE,ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface FFRequestMapping {
    String value() default "";
}

//FFRequestParam
@Target({ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface FFRequestParam {
    String value() default "";
}

//FFService
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface FFService {
    String value() default "";
}
```
自定义注解方面配置具体功能百度


## 初始化
创建FFDispatcherServlet，继承HttpServlet，重写init(),doGet(),doPost()

声明几个成员变量

```java
/**
 * 启动入口类
 * 继承HttpServlet，重写init()、doGet()和doPost()方法。
 *
 * @author Felix
 */
public class FFDispatcherServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    //与web.xml中param_name一致
    private static final String LOCATION = "contextConfigLocation";

    //保存所有的配置信息
    private Properties p = new Properties();

    //保存所有被扫描的相关的类名
    private List<String> classNames = new ArrayList<String>();

    //核心IOC容器，保存所有初始化bean
    private Map<String, Object> ioc = new HashMap<String, Object>();

    //保存所有的url和方法的映射关系
    private Map<String, Method> handlerMapping = new HashMap<String, Method>();

    public FFDispatcherServlet() {
        super();
    }

}


```
当Servlet容器启动时，会调用FFDispatcherServlet的init()方法，从init方法的参数中，我们可以拿到主配置文件的路径，从能够读取到配置文件中的信息。前面我们已经介绍了Spring的三个阶段，现在来完成初始化阶段的代码。在init()方法中，定义好执行步骤，如下：

```java
    /**
     * 初始化，加载配置文件
     * 当Servlet容器启动时，会调用FFDispatcherServlet的init()方法，
     * 从init方法的参数中，我们可以拿到主配置文件的路径，从能够读取到配置文件中的信息。
     *
     * @throws ServletException
     */
    @Override
    public void init(ServletConfig config) throws ServletException {

        //1.加载配置文件
        doLoadConfig(config.getInitParameter(LOCATION));

        //2.扫描所有相关类
        doScanner(p.getProperty("scanPackage"));

        //3.初始化所有相关类的实例，保存到IOC容器中
        doInstance();

        //4.依赖注入
        doAutowired();

        //5.构造HandlerMapping
        initHandlerMapping();

        //6.等待请求，匹配URL,定位方法，反射调用执行
        //调用doGet或者doPost方法


        //提示信息
        System.out.println("felix mvcframework is init");
    }

```


### doLoadConfig()方法的实现，将文件读取到Properties对象中

```java
    //将文件读取到Properties对象中
    private void doLoadConfig(String location) {
        InputStream fis = null;
        try {
            fis = this.getClass().getClassLoader().getResourceAsStream(location);
            p.load(fis);
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                fis.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
```

### doScanner()方法，递归扫描出所有的Class文件
```java
    //递归扫描出所有的Class文件
    private void doScanner(String scanPackage) {
        //将所有包路径转换为文件路径  com.felix.demo -> /com/felix/demo
        URL url = this.getClass().getClassLoader().getResource(scanPackage.replaceAll("\\.", "/"));
        File dir = new File(url.getFile());
        for (File file : dir.listFiles()) {
            //如果是文件夹，递归扫描
            if (file.isDirectory()) {
                doScanner(scanPackage + "." + file.getName());
            } else {
                classNames.add(scanPackage + "." + file.getName().replace(".class", "").trim());
            }
        }
    }
```


### doInstance()方法，初始化所有相关的类，并放入到IOC容器之中。

IOC容器的key默认是类名首字母小写，如果是自己设置类名，则优先使用自定义的。因此，要先写一个针对类名首字母处理的工具方法。
```java
public class StringUtil {


    /**
     * 首字母小写
     * @param str
     * @return
     */
    public static String lowerFirstCase(String str) {
        char[] chars = str.toCharArray();

        if (chars[0] >= 'A' && chars[0] <= 'Z') {
            chars[0] += 32;
        }

        return String.valueOf(chars);
    }
}
```
然后，再处理相关的类。
```java
    // 初始化所有相关的类，并放入到IOC容器之中。
    // IOC容器的key默认是类名首字母小写，如果是自己设置类名，则优先使用自定义的。
    private void doInstance() {
        if (classNames.size() == 0) {
            return;
        }

        try {
            for (String className : classNames) {
                Class<?> clazz = Class.forName(className);

                // isAnnotationPresent:如果指定类型的注解存在于此元素上，则返回 true，否则返回 false
                if (clazz.isAnnotationPresent(FFController.class)) {
                    //默认将首字母小写座位beanName
                    String beanName = StringUtil.lowerFirstCase(clazz.getSimpleName());
                    ioc.put(beanName, clazz.newInstance());
                } else if (clazz.isAnnotationPresent(FFService.class)) {
                    //getAnnotation:该元素如果存在指定类型的注解，则返回这些注解，否则返回 null。
                    FFService service = clazz.getAnnotation(FFService.class);
                    String beanName = service.value();
                    //若用户设置了名字，用用户设置的
                    if (!"".equals(beanName.trim())) {
                        ioc.put(beanName, clazz.newInstance());
                        continue;
                    }
                    //用户没设置，就按照接口类型创建一个实例
                    //getInterfaces返回该类所实现的接口的一个数组
                    Class<?>[] interfaces = clazz.getInterfaces();
                    for (Class<?> anInterface : interfaces) {
                        ioc.put(anInterface.getName(), clazz.newInstance());
                    }

                } else {
                    continue;
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
```

### doAutowired()方法，将初始化到IOC容器中的类，需要赋值的字段进行赋值

```java
    //将初始化到IOC容器中的类，需要赋值的字段进行赋值
    private void doAutowired() {
        if (ioc.isEmpty()) {
            return;
        }

        for (Map.Entry<String, Object> entry : ioc.entrySet()) {
            //拿到实例对象中所有属性
            Field[] fields = entry.getValue().getClass().getDeclaredFields();
            for (Field field : fields) {

                if (!field.isAnnotationPresent(FFAutowired.class)) {
                    continue;
                }
                FFAutowired autowired = field.getAnnotation(FFAutowired.class);
                String beanName = autowired.value().trim();
                //默认就用字段名
                if ("".equals(beanName)) {
                    beanName = field.getType().getName();

                }
                //设置私有属性访问权
                field.setAccessible(true);
                try {
                    //赋值
                    field.set(entry.getValue(), ioc.get(beanName));
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

        }
    }

```

### initHandlerMapping()方法，将FFRequestMapping中配置的信息和Method进行关联，并保存这些关系。

```java

    //将FFRequestMapping中配置的信息和Method进行关联，并保存这些关系。
    private void initHandlerMapping() {
        if (ioc.isEmpty()) {
            return;
        }

        for (Map.Entry<String, Object> entry : ioc.entrySet()) {
            Class<?> clazz = entry.getValue().getClass();
            if (!clazz.isAnnotationPresent(FFController.class)) {
                continue;
            }
            String baseUrl = "";
            //读取Controller的url值
            if (clazz.isAnnotationPresent(FFRequestMapping.class)) {
                FFRequestMapping mapping = clazz.getAnnotation(FFRequestMapping.class);
                baseUrl = mapping.value();
            }

            //读取method的url
            Method[] methods = clazz.getMethods();
            for (Method method : methods) {

                //没FFRequestMapping注解的忽略
                if (!method.isAnnotationPresent(FFRequestMapping.class)) {
                    continue;
                }

                FFRequestMapping mapping = method.getAnnotation(FFRequestMapping.class);
                //吧多个/替换成一个/
                String url = ("/" + baseUrl + "/" + mapping.value()).replaceAll("/+", "/");
                handlerMapping.put(url, method);

                System.out.println("mapped" + url + "," + method);
            }

        }

    }

```

到此，初始化阶段的所有代码全部写完。

## 运行阶段

来到运行阶段，当用户发送请求被Servlet接受时，都会统一调用doPost方法，我先在doPost方法中再调用doDispach()方法，代码如下：

```java

    /**
     * 执行业务逻辑
     *
     * @param req
     * @param resp
     * @throws ServletException
     * @throws IOException
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        try {
            doDispatch(req, resp);
        } catch (Exception e) {
            e.printStackTrace();
            resp.getWriter().write("500 Exception,Details:\r\n" + Arrays.toString(e.getStackTrace())
                    .replaceAll("\\[|\\]", "").replaceAll("\\s", "\r\n"));
        }

    }
```

### doDispatch()

```java

    private void doDispatch(HttpServletRequest req, HttpServletResponse resp) throws Exception {

        if (this.handlerMapping.isEmpty()) {
            return;
        }

        String url = req.getRequestURI();
        String contextPath = req.getContextPath();
        url = url.replaceAll(contextPath, "")
                .replaceAll("/+", "/");

        if (!this.handlerMapping.containsKey(url)) {
            resp.getWriter().write("404 Not Found！！！！！！");
            return;
        }

        Map<String, String[]> params = req.getParameterMap();
        Method method = this.handlerMapping.get(url);
        //获取方法的参数列表
        Class<?>[] parameterTypes = method.getParameterTypes();
        //获取请求的参数
        Map<String, String[]> parameterMap = req.getParameterMap();
        //保存参数
        Object[] paramValues = new Object[parameterTypes.length];
        //方法的参数列表
        for (int i = 0; i < parameterTypes.length; i++) {
            //根据参数名称，做某些处理
            Class parameterType = parameterTypes[i];
            if (parameterType == HttpServletRequest.class) {
                //参数类型已明确，强转
                paramValues[i] = req;
                continue;
            } else if (parameterType == HttpServletResponse.class) {
                paramValues[i] = resp;
                continue;
            } else if (parameterType == String.class) {
                for (Map.Entry<String, String[]> param : parameterMap.entrySet()) {
                    String value = Arrays.toString(param.getValue())
                            .replaceAll("\\[|\\]", "")
                            .replaceAll(",\\s", ",");

                    paramValues[i] = value;
                }
            }
        }

        try {
            String beanName = StringUtil.lowerFirstCase(method.getDeclaringClass().getSimpleName());
            //利用反射机制调用
            method.invoke(this.ioc.get(beanName), paramValues);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }
```


到此，我们完成了一个mini版本的Spring，麻雀虽小，五脏俱全。我们把服务发布到web容器中，然后，在浏览器输入：[http://localhost:8080/ffmvc/demo/query.json?name=felix](http://localhost:8080/ffmvc/demo/query.json?name=felix)，就会得到下面的结果：


![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/3211e612dea72bc7d6761b5c273efcf.png)



当然，真正的Spring要复杂很多，但核心设计思路基本如此。


代码已上传至我的github： [https://github.com/542869246/felix-mvcframework](https://github.com/542869246/felix-mvcframework)