---
title: 使用Python自动生成报表以邮件发送
copyright: true
top: 95
date: 2018-09-03 19:13:56
categories: [Python]
tags: [Python]
image: http://pic1.win4000.com/wallpaper/2018-01-15/5a5c745031e8b.jpg
description: 数据分析师肯定每天都被各种各样的数据数据报表搞得焦头烂额，老板的，运营的、产品的等等。而且大部分报表都是重复性的工作，这篇文章就是帮助大家如何用Python来实现报表的自动发送，解放你的劳动力，可以让你有时间去做更有意思的事情。
---

<span></span>

<!--more-->

数据分析师肯定每天都被各种各样的数据数据报表搞得焦头烂额，老板的，运营的、产品的等等。而且大部分报表都是重复性的工作，这篇文章就是帮助大家如何用Python来实现报表的自动发送，解放你的劳动力，可以让你有时间去做更有意思的事情。

首先来介绍下实现自动报表要使用到的Python库：

*   pymysql 一个可以连接MySQL实例并且实现增删改查功能的库
    
*   datetime Python标准库中自带的关于时间的库
    
*   openpyxl 一个可以读写07版以后的Excel文档（.xlsx格式也支持）的库
    
*   smtplib SMTP即简单邮件传输协议，Python简单封装成了一个库
    
*   email 一个用来处理邮件消息的库
    

为什么使用openpyxl库来处理Excel呢？因为它支持每个sheet的行数为100W+，也是支持xlsx格式的文件。如果你接受xls文件，并且每个sheet的行数小于6W，也是可以使用xlwt库，它对大文件的读取速度要大于openpyxl。

接下来我们就进入实战部分，来正式实现这个过程。我把整个实现过程分成几个函数的方式来实现，这样看着会比较有结构感。

## 一、首先导入所有要用到的库

```py
# encoding=utf-8
import pymysql as pms
import openpyxl
import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.header import Header
import smtplib
```

## 二、 编写一个传入sql就返回数据的函数get_datas(sql)

```py
def get_datas(sql):
    # 一个传入sql导出数据的函数
    # 跟数据库建立连接
    conn = pms.connect(host='实例地址', user='用户',
                       passwd='密码', database='库名', port=3306, charset="utf8")
    # 使用 cursor() 方法创建一个游标对象 cursor
    cur = conn.cursor()
    # 使用 execute() 方法执行 SQL
    cur.execute(sql)
    # 获取所需要的数据
    datas = cur.fetchall()
    #关闭连接
    cur.close()
    #返回所需的数据
    return datas
```

## 三、 编写一个传入sql就返回数据的字段名称的函数get_datas(sql)，因为一个函数只能返回一个值，这边就用2个函数来分别返回数据和字段名称（也就是excel里的表头）

```py
def get_fields(sql):
    # 一个传入sql导出字段的函数
    conn = pms.connect(host='rm-rj91p2yhl9dm2xmbixo.mysql.rds.aliyuncs.com', user='bi-analyzer',
                       passwd='pcNzcKPnn', database='kikuu', port=3306, charset="utf8")
    cur = conn.cursor()
    cur.execute(sql)
    # 获取所需要的字段名称
    fields = cur.description
    cur.close()
    return fields
```

## 四、 编写一个传入数据、字段名称、存储地址返回一个excel 的函数et_excel(data, field, file)

```py
def get_excel(data, field, file):
    # 将数据和字段名写入excel的函数
    #新建一个工作薄对象
    new = openpyxl.Workbook()
    #激活一个新的sheet
    sheet = new.active
    #给sheet命名
    sheet.title = '数据展示'
    #将字段名称循环写入excel第一行，因为字段格式列表里包含列表，每个列表的第一元素才是字段名称
    for col in range(len(field)):
        #row代表行数，column代表列数，value代表单元格输入的值，行数和列数都是从1开始，这点于python不同要注意
        _ = sheet.cell(row=1, column=col+1, value=u'%s' % field[col][0])
     #将数据循环写入excel的每个单元格中   
    for row in range(len(data)):
        for col in range(len(field)):
            #因为第一行写了字段名称，所以要从第二行开始写入
            _ = sheet.cell(row=row+2, column=col + 1, value=u'%s' % data[row][col])
            #将生成的excel保存，这步是必不可少的
    newworkbook = new.save(file)
    #返回生成的excel
    return newworkbook
```

## 五、 编写一个自动获取昨天日期字符串格式的函数getYesterday()
```py
def getYesterday():
    # 获取昨天日期的字符串格式的函数
    #获取今天的日期
    today = datetime.date.today()
    #获取一天的日期格式数据
    oneday = datetime.timedelta(days=1)
    #昨天等于今天减去一天
    yesterday = today - oneday
    #获取昨天日期的格式化字符串
    yesterdaystr = yesterday.strftime('%Y-%m-%d')
    #返回昨天的字符串
    return yesterdaystr
```
## 六、编写一个生成邮件的函数create\_email(email\_from, email\_to, email\_Subject, email\_text, annex\_path, annex_name)
```py
def create_email(email_from, email_to, email_Subject, email_text, annex_path, annex_name):
    # 输入发件人昵称、收件人昵称、主题，正文，附件地址,附件名称生成一封邮件
    #生成一个空的带附件的邮件实例
    message = MIMEMultipart()
    #将正文以text的形式插入邮件中
    message.attach(MIMEText(email_text, 'plain', 'utf-8'))
    #生成发件人名称（这个跟发送的邮件没有关系）
    message['From'] = Header(email_from, 'utf-8')
    #生成收件人名称（这个跟接收的邮件也没有关系）
    message['To'] = Header(email_to, 'utf-8')
    #生成邮件主题
    message['Subject'] = Header(email_Subject, 'utf-8')
    #读取附件的内容
    att1 = MIMEText(open(annex_path, 'rb').read(), 'base64', 'utf-8')
    att1["Content-Type"] = 'application/octet-stream'
    #生成附件的名称
    att1["Content-Disposition"] = 'attachment; filename=' + annex_name
    #将附件内容插入邮件中
    message.attach(att1)
    #返回邮件
    return message
```

## 七、 生成一个发送邮件的函数send_email(sender, password, receiver, msg)
```py
def send_email(sender, password, receiver, msg):
    # 一个输入邮箱、密码、收件人、邮件内容发送邮件的函数
    try:
        #找到你的发送邮箱的服务器地址，已加密的形式发送
        server = smtplib.SMTP_SSL("smtp.mxhichina.com", 465)  # 发件人邮箱中的SMTP服务器
        server.ehlo()
        #登录你的账号
        server.login(sender, password)  # 括号中对应的是发件人邮箱账号、邮箱密码
        #发送邮件
        server.sendmail(sender, receiver, msg.as_string())  # 括号中对应的是发件人邮箱账号、收件人邮箱账号（是一个列表）、邮件内容
        print("邮件发送成功")
        server.quit()  # 关闭连接
    except Exception:
        print(traceback.print_exc())
        print("邮件发送失败")
```
## 八、建立一个main函数，把所有的自定义内容输入进去，最后执行main函数
```py
def main():
    print(datetime.datetime.now())
    my_sql = sql = "SELECT a.id '用户ID',\
           a.gmtCreate '用户注册时间',\
           af.lastLoginTime '最后登录时间',\
           af.totalBuyCount '历史付款子单数',\
           af.paidmountUSD '历史付款金额',\
           af.lastPayTime '用户最后支付时间'\
          FROM table a\
      LEFT JOIN tableb af ON a.id= af.accountId ;"
    # 生成数据
    my_data = get_datas(my_sql)
    # 生成字段名称
    my_field = get_fields(my_sql)
    # 得到昨天的日期
    yesterdaystr = getYesterday()
    # 文件名称
    my_file_name = 'user attribute' + yesterdaystr + '.xlsx'
    # 文件路径
    file_path = 'D:/work/report/' + my_file_name
    # 生成excel
    get_excel(my_data, my_field, file_path)

    my_email_from = 'BI部门自动报表机器人'
    my_email_to = '运营部'
    # 邮件标题
    my_email_Subject = 'user' + yesterdaystr
    # 邮件正文
    my_email_text = "Dear all,\n\t附件为每周数据，请查收！\n\nBI团队 "
    #附件地址
    my_annex_path = file_path
    #附件名称
    my_annex_name = my_file_name
    # 生成邮件
    my_msg = create_email(my_email_from, my_email_to, my_email_Subject,
                          my_email_text, my_annex_path, my_annex_name)
    my_sender = '阿里云邮箱'
    my_password = '我的密码'
    my_receiver = [10001@qq.com']#接收人邮箱列表
    # 发送邮件
    send_email(my_sender, my_password, my_receiver, my_msg)
    print(datetime.datetime.now())

if __name__ == "__main__":
    main();
```