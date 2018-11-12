---
title: Nginx快速入门
copyright: true
top: 95
date: 2018-10-25 16:14:14
categories: [Nginx]
tags: [Nginx]
image: https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/14765.jpg?x-oss-process=style/ys30
description: 本文主要介绍Nginx的基本配置和操作，并介绍了一些可以完成的简单任务
---

<span></span>

<!--more-->
 
假设您已经学习过并已经安装好了nginx服务器。 如果没有，请参阅安装nginx页面([http://www.yiibai.com/nginx/nginx-install.html](http://www.yiibai.com/nginx/nginx-install.html) )。 本指南介绍如何启动和停止nginx，并重新加载其配置，解释配置文件的结构，并介绍如何设置nginx以提供静态内容，如何配置nginx作为代理服务器，以及如何将其连接到 一个FastCGI应用程序。

nginx有一个主进程和几个工作进程。 主进程的主要目的是读取和评估配置，并维护工作进程。 工作进程对请求进行实际处理。 nginx采用基于事件的模型和依赖于操作系统的机制来有效地在工作进程之间分配请求。 工作进程的数量可在配置文件中定义，并且可以针对给定的配置进行修改，或者自动调整到可用CPU内核的数量(请参阅[worker_processes](http://nginx.org/en/docs/ngx_core_module.html#worker_processes "worker_processes"))。

在配置文件中确定nginx及其模块的工作方式。 默认情况下，配置文件名为`nginx.conf`，并放在目录：`/usr/local/nginx/conf`, `/etc/nginx`, 或 `/usr/local/etc/nginx` 中。

在前面安装文章配置中，使用的安装配置目录是：`/usr/local/nginx/conf` 。所以可以在这个目录下找到这个配置文件。

1\. 启动，停止和重新加载Nginx配置
---------------------

要启动nginx，请运行可执行文件。 当nginx启动后，可以通过使用`-s`参数调用可执行文件来控制它。 使用以下语法：

    nginx -s signal
    

信号(`signal`)的值可能是以下之一：

*   `stop` \- 快速关闭服务
*   `quit` \- 正常关闭服务
*   `reload` \- 重新加载配置文件
*   `reopen` \- 重新打开日志文件

例如，要通过等待工作进程完成服务当前请求来停止`nginx`进程，可以执行以下命令：

    nginx -s quit
    

> 注：该命令应该在启动nginx的同一用户下执行。

在将重新配置命令的命令发送到nginx或重新启动之前，配置文件中的更改将不会被应用。 要重新加载配置文件，请执行：

    nginx -s reload
    

当主进程收到要重新加载配置的信号，它将检查新配置文件的语法有效性，并尝试应用其中提供的配置。 如果这是成功的，主进程将启动新的工作进程，并向旧的工作进程发送消息，请求它们关闭。 否则，主进程回滚更改，并继续使用旧配置。 老工作进程，接收关闭命令，停止接受新连接，并继续维护当前请求，直到所有这些请求得到维护。 之后，旧的工作进程退出。

还可以借助Unix工具(如kill utility)将信号发送到nginx进程。 在这种情况下，信号直接发送到具有给定进程ID的进程。 默认情况下，nginx主进程的进程ID写入目录`/usr/local/nginx/logs`或`/var/run`中的nginx.pid。 例如，如果主进程ID为`1628`，则发送QUIT信号导致nginx的正常关闭，请执行：

    kill -s QUIT 1628
    

要获取所有运行的nginx进程的列表，可以使用`ps`命令，例如，以下列方式：

    ps -ax | grep nginx
    

2\. 配置文件的结构
-----------

nginx由配置文件中指定的指令控制的模块组成。 指令分为简单指令和块指令。 一个简单的指令由空格分隔的名称和参数组成，并以分号(`;`)结尾。 块指令具有与简单指令相同的结构，但不是以分号结尾，而是以大括号(`{`和`}`)包围的一组附加指令结束。 如果块指令可以在大括号内部有其他指令，则称为上下文(例如：`events`，`http`，`server`和`location`)。

配置文件中放置在任何上下文之外的伪指令都被认为是**主上下文**。 `events` 和`http`指令驻留在**主上下文**中，`server`在`http`中的，而`location`在`http`块中。

`#`号之后的一行的部分被视为注释。

3\. 提供静态内容服务(静态网站)
------------------

一个重要的Web服务器任务是提供文件(如图像或静态HTML页面)。这里我们来学习如何实现一个示例，根据请求，文件将从不同的本地目录提供：`/data/www`(可能包含HTML文件)和/ `data/images`(包含图像)。这将需要编辑配置文件，并使用两个位置块在http块内设置服务器块。

首先，创建`/data/www`目录，并将一个包含任何文本内容的`index.html`文件放入其中，并创建`/data/images`目录并在其中放置一些图像。创建两个目录 -

    [root@localhost ~]# mkdir -p /data/www
    [root@localhost ~]# mkdir -p /data/images
    [root@localhost ~]#
    

分别在上面创建的两个目录中放入两个文件：`/data/www/index.html` 和 `/data/images/logo.png`，`/data/www/index.html`文件的内容就一行，如下 -

    <h2> New Static WebSite Demo.</h2>
    

接下来，打开配置文件(`/usr/local/nginx/conf/nginx.conf`)。 默认的配置文件已经包含了服务器块的几个示例，大部分是注释掉的。 现在注释掉所有这样的块，并启动一个新的服务器块：
```
    http {
        server {
        }
    }
```

通常，配置文件可以包括服务器监听的端口和服务器名称区分的几个`server`块。当nginx决定哪个服务器处理请求后，它会根据服务器块内部定义的`location`指令的参数测试请求头中指定的URI。

将以下`location`块添加到服务器(`server`)块：
```
    http {
        server {
            location / {
                root /data/www;
            }
        }
    }
```

该`location`块指定与请求中的URI相比较的“`/`”前缀。 对于匹配请求，URI将被添加到`root`指令中指定的路径(即`/data/www`)，以形成本地文件系统上所请求文件的路径。 如果有几个匹配的`location`块，nginx将选择具有最长前缀来匹配`location`块。 上面的`location`块提供最短的前缀长度为`1`，因此只有当所有其他`location`块不能提供匹配时，才会使用该块。

接下来，添加第二个`location`块：
```
    http {
        server {
            location / {
                root /data/www;
            }
            location /images/ {
                root /data;
            }
        }
    }
```

它将是以`/images/`(位置`/`也匹配这样的请求，但具有较短前缀，也就是“`/images/`”比“`/`”长)的请求来匹配。

`server`块的最终配置应如下所示：
```
    server {
        location / {
            root /data/www;
        }
    
        location /images/ {
            root /data;
        }
    }
```

这已经是一个在标准端口`80`上侦听并且可以在本地机器上访问的服务器( `http://localhost/` )的工作配置。 响应以`/images/`开头的URI的请求，服务器将从`/data/images`目录发送文件。 例如，响应`http://localhost/images/logo.png`请求，nginx将发送服务上的`/data/images/logo.png`文件。 如果文件不存在，nginx将发送一个指示`404`错误的响应。 不以`/images/`开头的URI的请求将映射到`/data/www`目录。 例如，响应`http://localhost/about/example.html`请求时，nginx将发送`/data/www/about/example.html`文件。

要应用新配置，如果尚未启动nginx或者通过执行以下命令将重载信号发送到nginx的主进程：

    [root@localhost ~]# /usr/local/nginx/sbin/nginx -t
    nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
    nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
    [root@localhost ~]# /usr/local/nginx/sbin/nginx -s reload
    

> 如果错误或异常导致无法正常工作，可以尝试查看目录`/usr/local/nginx/logs`或`/var/log/nginx`中的`access.log`和`error.log`文件中查找原因。

打开浏览器或使用CURL访问Nginx服务器如下所示 -

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/974100427_64766.png)

完整的`nginx.conf`文件配置内容如下：
```
    #user  nobody;
    worker_processes  1;
    
    #error_log  logs/error.log;
    #error_log  logs/error.log  notice;
    #error_log  logs/error.log  info;
    
    #pid        logs/nginx.pid;
    
    events {
        worker_connections  1024;
    }
    
    http {
        include       mime.types;
        default_type  application/octet-stream;
    
        #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
        # '$status $body_bytes_sent "$http_referer" '
        # '"$http_user_agent" "$http_x_forwarded_for"';
        #access_log  logs/access.log  main;
        sendfile        on;
        #tcp_nopush     on;
        #keepalive_timeout  0;
        keepalive_timeout  65;
        #gzip  on;
    
        ## 新服务(静态网站)
        server {
            location / {
                root /data/www;
            }
            location /images/ {
                root /data;
            }
        }
    }
```

4\. 设置简单的代理服务器
--------------

nginx的一个常见用途是将其设置为代理服务器，这意味着它可作为一个接收请求的服务器，将其传递给代理服务器，从代理服务器中检索响应，并将其发送给客户端。

我们将配置一个基本的代理服务器，它为来自本地目录的文件提供图像请求，并将所有其他请求发送到代理的服务器。 在此示例中，两个服务器将在单个`nginx`实例上定义。

首先，通过向nginx配置文件添加一个`server`块来定义代理服务器，其中包含以下内容：
```
    server {
        listen 8080;
        root /data/up1;
    
        location / {
        }
    }
```

这将是一个监听端口`8080`的简单服务器(以前，由于使用了标准端口`80`，所以没有指定`listen`指令)，并将所有请求映射到本地文件系统上的`/data/up1`目录。 创建此目录并将`index.html`文件放入其中。 请注意，`root`指令位于`server`块上下文中。 当选择用于服务请求的`location`块不包含自己的`root`指令时，将使用此`root`指令。

在上面创建的目录`/data/up1`中放入一个文件：`/data/www/demo.html`，文件的内容就一行，如下 -

    <h2>About proxy_pass Page at port 8080</h2>
    

接下来，使用上一节中的服务器配置进行修改，使其成为代理服务器配置。 在第一个位置块中，将`proxy_pass`指令与参数中指定的代理服务器的协议，名称和端口(在本例中为`http://localhost:8080`)：
```
    server {
        location / {
            proxy_pass http://localhost:8080;
        }
    
        location /images/ {
            root /data;
        }
    }
```

我们将修改当前使用`/images/prefix`将请求映射到`/data/images`目录下的文件的第二个`location`块，使其与典型文件扩展名的图像请求相匹配。 修改后的位置块如下所示：
```
    location ~ \.(gif|jpg|png)$ {
        root /data/images;
    }
```

该参数是一个正则表达式，匹配所有以`.gif`，`.jpg`或`.png`结尾的URI。正则表达式之前应该是`~`字符。 相应的请求将映射到`/data/images`目录。

当nginx选择一个`location`块来提供请求时，它首先检查指定前缀的`location`指令，记住具有最长前缀的`location`，然后检查正则表达式。 如果与正则表达式匹配，nginx会选择此`location`，否则选择之前记住的那一个。

代理服务器的最终配置将如下所示：
```
    server {
        location / {
            proxy_pass http://localhost:8080/;
        }
    
        location ~ \.(gif|jpg|png)$ {
            root /data/images;
        }
    }
```

此服务器将过滤以`.gif`，`.jpg`或`.png`结尾的请求，并将它们映射到`/data/images`目录(通过向`root`指令的参数添加URI)，并将所有其他请求传递到上面配置的代理服务器。

要应用新配置，如果尚未启动nginx或者通过执行以下命令将重载信号发送到nginx的主进程：

    [root@localhost ~]# /usr/local/nginx/sbin/nginx -t
    nginx: the configuration file /usr/local/nginx/conf/nginx.conf syntax is ok
    nginx: configuration file /usr/local/nginx/conf/nginx.conf test is successful
    [root@localhost ~]# /usr/local/nginx/sbin/nginx -s reload
    

首先测试上面配置的 `8080` 端口的服务，访问服务的`8080`端口，得到以下结果：  
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/183100431_95557.png) 
再次访问 `80` 端口(这里只是一个代理，它会把请求转发给`8080`的服务，由`8080`端口这这个服务处理并返回结果到客户端)，得到以下结果 -  
![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/127100435_72363.png)

完整的配置`nginx.conf`文件内容如下 -

```
    #user  nobody;
    worker_processes  1;
    
    #error_log  logs/error.log;
    #error_log  logs/error.log  notice;
    #error_log  logs/error.log  info;
    
    #pid        logs/nginx.pid;
    
    events {
        worker_connections  1024;
    }
    
    http {
        include       mime.types;
        default_type  application/octet-stream;
    
        #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
        #                  '$status $body_bytes_sent "$http_referer" '
        #                  '"$http_user_agent" "$http_x_forwarded_for"';
    
        #access_log  logs/access.log  main;
    
        sendfile        on;
        #tcp_nopush     on;
    
        #keepalive_timeout  0;
        keepalive_timeout  65;
    
        #gzip  on;
    
        ## 新服务(服务处理)
        server {
            listen 8080;
            root /data/up1;
    
            location / {
            }
        }
    
        ## 代理配置，数据转发
        server {
            location / {
                proxy_pass http://localhost:8080/;
            }
    
            location ~ \.(gif|jpg|png)$ {
                root /data/images;
            }
        }
    }
```

5\. 设置FastCGI代理
---------------

nginx可用于将请求路由到运行使用各种框架和PHP等编程语言构建的应用程序的FastCGI服务器。  
使用FastCGI服务器的最基本nginx配置包括使用`fastcgi_pass`指令(而不是`proxy_pass`指令)，以及`fastcgi_param`指令来设置传递给`FastCGI`服务器的参数。 假设`FastCGI`服务器可以在`localhost:9000`上访问。 以上一节的代理配置为基础，用`fastcgi_pass`指令替换`proxy_pass`指令，并将参数更改为`localhost:9000`。 在PHP中，`SCRIPT_FILENAME`参数用于确定脚本名称，`QUERY_STRING`参数用于传递请求参数。 最终的配置将是：

```
    server {
        location / {
            fastcgi_pass  localhost:9000;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param QUERY_STRING    $query_string;
        }
    
        location ~ \.(gif|jpg|png)$ {
            root /data/images;
        }
    }
```

这将设置一个服务器，将除静态图像请求之外的所有请求路由到通过FastCGI协议在`localhost:9000`上运行的代理服务器。

<div class="note info"><p>作者：初生不惑
出处：[https://www.yiibai.com/nginx/beginners_guide.html](https://www.yiibai.com/nginx/beginners_guide.html)</p></div>

