---
title: SQL执行效率总结
copyright: true
top: 95
date: 2018-08-22 11:14:58
categories: [数据库]
tags: [数据库,SQL]
image: http://wx3.sinaimg.cn/large/00603tm4gy1fdu6w78b8tj31hc0u04qr.jpg
---
<span></span>
<!--more-->

1.关于SQL查询效率，100w数据，查询只要1秒，与您分享:

机器情况 p4: 2.4 内存: 1 G os: windows 2003 数据库: ms sql server 2000 目的: 查询性能测试,比较两种查询的性能

SQL查询效率 step by step

\-\- setp 1. -- 建表 `create table t_userinfo ( userid int identity(1,1) primary key nonclustered, nick varchar(50) not null default '', classid int not null default 0, writetime datetime not null default getdate() ) go`

\-\- 建索引 `create clustered index ix_userinfo_classid on t_userinfo(classid) go`

\-\- step 2.
`
declare @i int declare @k int declare @nick varchar(10) set @i = 1 while @i<1000000 begin set @k = @i % 10 set @nick = convert(varchar,@i) insert into t_userinfo(nick,classid,writetime) values(@nick,@k,getdate()) set @i = @i + 1 end` 

\-\- 耗时 08:27 ，需要耐心等待

\-\- step 3. `select top 20 userid,nick,classid,writetime from t_userinfo where userid not in ( select top 900000 userid from t_userinfoorder by userid asc )`

\-\- 耗时 8 秒 ,够长的

\-\- step 4. `select a.userid,b.nick,b.classid,b.writetime from ( select top 20 a.userid from ( select top 900020 userid from t_userinfo order by userid asc ) a order by a.userid desc ) a inner join t_userinfo b on a.userid = b.userid order by a.userid asc`

\-\- 耗时 1 秒，太快了吧，不可以思议

\-\- step 5 where 查询 `select top 20 userid,nick,classid,writetime from t_userinfo where classid = 1 and userid not in ( select top 90000 userid from t_userinfo where classid = 1 order by userid asc )` -- 耗时 2 秒

\-\- step 6 where 查询 `select a.userid,b.nick,b.classid,b.writetime from ( select top 20 a.userid from ( select top 90000 userid from t_userinfo where classid = 1 order by userid asc ) a order by a.userid desc ) a inner join t_userinfo b on a.userid = b.userid order by a.userid asc`

\-\- 查询分析器显示不到 1 秒.

查询效率分析： 子查询为确保消除重复值，必须为外部查询的每个结果都处理嵌套查询。在这种情况下可以考虑用联接查询来取代。 如果要用子查询，那就用EXISTS替代IN、用NOT EXISTS替代NOT IN。因为EXISTS引入的子查询只是测试是否存在符合子查询中指定条件的行，效率较高。无论在哪种情况下,NOT IN都是最低效的。因为它对子查询中的表执行了一个全表遍历。

建立合理的索引,避免扫描多余数据，避免表扫描！ 几百万条数据，照样几十毫秒完成查询,对查询进行优化，应尽量避免全表扫描，首先应考虑在 where 及 order by 涉及的列上建立索引。

2.应尽量避免在 where 子句中对字段进行 null 值判断，否则将导致引擎放弃使用索引而进行全表扫描，如： `select id from t where num is null` 可以在num上设置默认值0，确保表中num列没有null值，然后这样查询： `select id from t where num=0`

3.应尽量避免在 where 子句中使用!=或<>操作符，否则将引擎放弃使用索引而进行全表扫描。

4.应尽量避免在 where 子句中使用 or 来连接条件，否则将导致引擎放弃使用索引而进行全表扫描，如： `select id from t where num=10 or num=20` 可以这样查询： `select id from t where num=10 union all select id from t where num=20`

5.in 和 not in 也要慎用，否则会导致全表扫描，如： `select id from t where num in(1,2,3)` 对于连续的数值，能用 between 就不要用 in 了： `select id from t where num between 1 and 3`

6.下面的查询也将导致全表扫描： `select id from t where name like '%c%'` 若要提高效率，可以考虑全文检索。

7.如果在 where 子句中使用参数，也会导致全表扫描。因为SQL只有在运行时才会解析局部变量，但优化程序不能将访问计划的选择推迟到运行时；它必须在编译时进行选择。然 而，如果在编译时建立访问计划，变量的值还是未知的，因而无法作为索引选择的输入项。如下面语句将进行全表扫描： `select id from t where[num=@num](mailto:num=@num)` 可以改为强制查询使用索引： `select id from t with(index(索引名)) where[num=@num](mailto:num=@num)`

8.应尽量避免在 where 子句中对字段进行表达式操作，这将导致引擎放弃使用索引而进行全表扫描。如： `select id from t where num/2=100` 应改为: `select id from t where num=100*2`

9.应尽量避免在where子句中对字段进行函数操作，这将导致引擎放弃使用索引而进行全表扫描。如： `select id from t where substring(name,1,3)='abc'--name以abc开头的id select id from t where datediff(day,createdate,'2005-11-30')=0--‘2005-11-30’`生成的id 应改为: `select id from t where name like 'abc%' select id from t where createdate>='2005-11-30' and createdate<'2005-12-1'`

10.不要在 where 子句中的“=”左边进行函数、算术运算或其他表达式运算，否则系统将可能无法正确使用索引。

11.在使用索引字段作为条件时，如果该索引是复合索引，那么必须使用到该索引中的第一个字段作为条件时才能保证系统使用该索引，否则该索引将不会被使用，并且应尽可能的让字段顺序与索引顺序相一致。

12.不要写一些没有意义的查询，如需要生成一个空表结构： `select col1,col2 into #t from t where 1=0` 这类代码不会返回任何结果集，但是会消耗系统资源的，应改成这样：` create table #t(...)`

13.很多时候用 exists 代替 in 是一个好的选择： `select num from a where num in(select num from b)` 用下面的语句替换： `select num from a where exists(select 1 from b where num=a.num)`

14.并不是所有索引对查询都有效，SQL是根据表中数据来进行查询优化的，当索引列有大量数据重复时，SQL查询可能不会去利用索引，如一表中有字段sex，male、female几乎各一半，那么即使在sex上建了索引也对查询效率起不了作用。

15.索引并不是越多越好，索引固然可以提高相应的 select 的效率，但同时也降低了 insert 及 update 的效率，因为 insert 或 update 时有可能会重建索引，所以怎样建索引需要慎重考虑，视具体情况而定。一个表的索引数最好不要超过6个，若太多则应考虑一些不常使用到的列上建的索引是否有 必要。

16.应尽可能的避免更新 clustered 索引数据列，因为 clustered 索引数据列的顺序就是表记录的物理存储顺序，一旦该列值改变将导致整个表记录的顺序的调整，会耗费相当大的资源。若应用系统需要频繁更新 clustered 索引数据列，那么需要考虑是否应将该索引建为 clustered 索引。

17.尽量使用数字型字段，若只含数值信息的字段尽量不要设计为字符型，这会降低查询和连接的性能，并会增加存储开销。这是因为引擎在处理查询和连接时会逐个比较字符串中每一个字符，而对于数字型而言只需要比较一次就够了。

18.尽可能的使用 varchar/nvarchar 代替 char/nchar ，因为首先变长字段存储空间小，可以节省存储空间，其次对于查询来说，在一个相对较小的字段内搜索效率显然要高些。

19.任何地方都不要使用 `select * from t` ，用具体的字段列表代替“*”，不要返回用不到的任何字段。

20.尽量使用表变量来代替临时表。如果表变量包含大量数据，请注意索引非常有限（只有主键索引）。

21.避免频繁创建和删除临时表，以减少系统表资源的消耗。

22.临时表并不是不可使用，适当地使用它们可以使某些例程更有效，例如，当需要重复引用大型表或常用表中的某个数据集时。但是，对于一次性事件，最好使用导出表。

23.在新建临时表时，如果一次性插入数据量很大，那么可以使用 select into 代替 create table，避免造成大量 log ，以提高速度；如果数据量不大，为了缓和系统表的资源，应先create table，然后insert。

24.如果使用到了临时表，在存储过程的最后务必将所有的临时表显式删除，先 truncate table ，然后 drop table ，这样可以避免系统表的较长时间锁定。

25.尽量避免使用游标，因为游标的效率较差，如果游标操作的数据超过1万行，那么就应该考虑改写。

26.使用基于游标的方法或临时表方法之前，应先寻找基于集的解决方案来解决问题，基于集的方法通常更有效。

27.与临时表一样，游标并不是不可使用。对小型数据集使用 FAST_FORWARD 游标通常要优于其他逐行处理方法，尤其是在必须引用几个表才能获得所需的数据时。在结果集中包括“合计”的例程通常要比使用游标执行的速度快。如果开发时 间允许，基于游标的方法和基于集的方法都可以尝试一下，看哪一种方法的效果更好。

28.在所有的存储过程和触发器的开始处设置 SET NOCOUNT ON ，在结束时设置 SET NOCOUNT OFF 。无需在执行存储过程和触发器的每个语句后向客户端发送 DONE_IN_PROC 消息。

29.尽量避免大事务操作，提高系统并发能力。

30.尽量避免向客户端返回大数据量，若数据量过大，应该考虑相应需求是否合理
<div class="note info no-icon"><p>1、避免将字段设为“允许为空” 
2、数据表设计要规范 
3、深入分析数据操作所要对数据库进行的操作 
4、尽量不要使用临时表 
5、多多使用事务 
6、尽量不要使用游标 
7、避免死锁 
8、要注意读写锁的使用 
9、不要打开大的数据集 
10、不要使用服务器端游标 
11、在程序编码时使用大数据量的数据库 
12、不要给“性别”列创建索引 
13、注意超时问题 
14、不要使用Select * 
15、在细节表中插入纪录时，不要在主表执行Select MAX(ID) 
16、尽量不要使用TEXT数据类型 
17、使用参数查询 
18、不要使用Insert导入大批的数据 
19、学会分析查询 
20、使用参照完整性 
21、用INNER JOIN 和LEFT JOIN代替Where </p></div>

### 提高SQL查询效率（要点与技巧）： 
#### 技巧一
问题类型：ACCESS数据库字段中含有日文片假名或其它不明字符时查询会提示内存溢出。 解决方法：修改查询语句 `sql="select * from tablename where column like '%"&word&"%'" 改为 sql="select * from tablename" rs.filter = " column like '%"&word&"%'"` 

#### 技巧二
问题类型：如何用简易的办法实现类似百度的多关键词查询（多关键词用空格或其它符号间隔）。 解决方法： 
```
//用空格分割查询字符串 
ck=split(word," ")
//得到分割后的数量 
sck=UBound(ck) 
sql="select * tablename where" 在一个字段中查询 For i = 0 To sck SQL = SQL & tempJoinWord & "(" & _ "column like '"&ck(i)&"%')" tempJoinWord = " and " Next 在二个字段中同时查询 For i = 0 To sck SQL = SQL & tempJoinWord & "(" & _ "column like '"&ck(i)&"%' or " & _ "column1 like '"&ck(i)&"%')" tempJoinWord = " and " Next
```

#### 技巧三
大大提高查询效率的几种技巧
1. 尽量不要使用 or，使用or会引起全表扫描，将大大降低查询效率。  
2. 经过实践验证，charindex()并不比前面加%的like更能提高查询效率，并且charindex()会使索引失去作用（指sqlserver数据库）  
3. column like '%"&word&"%' 会使索引不起作用  
column like '"&word&"%' 会使索引起作用（去掉前面的%符号）  
（指sqlserver数据库）  
4. '%"&word&"%' 与'"&word&"%' 在查询时的区别：  
比如你的字段内容为 一个容易受伤的女人  
'%"&word&"%' ：会通配所有字符串，不论查“受伤”还是查“一个”，都会显示结果。  
'"&word&"%' ：只通配前面的字符串，例如查“受伤”是没有结果的，只有查“一个”，才会显示结果。  
5. 字段提取要按照“需多少、提多少”的原则，避免“select *”，尽量使用“select 字段1,字段2,字段3........”。实践证明：每少提取一个字段，数据的提取速度就会有相应的提升。提升的速度还要看您舍弃的字段的大小来判断。  
6. order by按聚集索引列排序效率最高。一个sqlserver数据表只能建立一个聚集索引，一般默认为ID，也可以改为其它的字段。  
7. 为你的表建立适当的索引，建立索引可以使你的查询速度提高几十几百倍。（指sqlserver数据库）  

### 以下是建立索引与不建立索引的一个查询效率分析：  
Sqlserver索引与查询效率分析。  
表 News  
字段  
Id：自动编号  
Title：文章标题  
Author：作者  
Content：内容  
Star：优先级  
Addtime：时间  
记录：100万条  
测试机器：P4 2.8/1G内存/IDE硬盘  

#### 方案1：  
主键Id，默认为聚集索引，不建立其它非聚集索引  
`select * from News where Title like '%"&word&"%' or Author like '%"&word&"%' order by Id desc  `
从字段Title和Author中模糊检索，按Id排序  
查询时间：50秒  
 
#### 方案2：  
主键Id，默认为聚集索引  
在Title、Author、Star上建立非聚集索引  
`select * from News where Title like '"&word&"%' or Author like '"&word&"%' order by Id desc  `
从字段Title和Author中模糊检索，按Id排序  
查询时间：2 - 2.5秒 

#### 方案3：  
主键Id，默认为聚集索引  
在Title、Author、Star上建立非聚集索引  
`select * from News where Title like '"&word&"%' or Author like '"&word&"%' order by Star desc  `
从字段Title和Author中模糊检索，按Star排序  
查询时间：2 秒  

#### 方案4：  
主键Id，默认为聚集索引  
在Title、Author、Star上建立非聚集索引  
`select * from News where Title like '"&word&"%' or Author like '"&word&"%'`  
从字段Title和Author中模糊检索，不排序  
查询时间：1.8 - 2 秒  

#### 方案5：  
主键Id，默认为聚集索引  
在Title、Author、Star上建立非聚集索引  
`select * from News where Title like '"&word&"%'  `
或  
`select * from News where Author like '"&word&"%'  `
从字段Title 或 Author中检索，不排序  
查询时间：1秒  

### 如何提高SQL语言的查询效率?  
问：请问我如何才能提高SQL语言的查询效率呢？  
答：这得从头说起：  
由于SQL是面向结果而不是面向过程的查询语言，所以一般支持SQL语言的大型关系型数据库都使用一个基于查询成本的优化器，为即时查询提供一个最佳的执行策略。对于优化器，输入是一条查询语句，输出是一个执行策略。  
一条SQL查询语句可以有多种执行策略，优化器将估计出全部执行方法中所需时间最少的所谓成本最低的那一种方法。所有优化都是基于用记所使用的查询语句中的where子句，优化器对where子句中的优化主要用搜索参数(Serach Argument)。  
搜索参数的核心思想就是数据库使用表中字段的索引来查询数据，而不必直接查询记录中的数据。  
带有 =、<、<=、>、>= 等操作符的条件语句可以直接使用索引，如下列是搜索参数：  
emp_id = "10001" 或 salary > 3000 或 a =1 and c = 7  
而下列则不是搜索参数：  
salary = emp_salary 或 dep_id != 10 或 salary * 12 >= 3000 或 a=1 or c=7  
应当尽可能提供一些冗余的搜索参数，使优化器有更多的选择余地。请看以下3种方法：  
#### 第一种方法：  
```
select employee.emp_name,department.dep_name from department,employee 
where (employee.dep_id = department.dep_id) 
and (department.dep_code="01") 
and (employee.dep_code="01"); 
 
```

它的搜索分析结果如下：  
Estimate 2 I/O operations  
Scan department using primary key  
for rows where dep_code equals "01"  
Estimate getting here 1 times  
Scan employee sequentially  
Estimate getting here 5 times  
#### 第二种方法： 

``` 
select employee.emp_name,department.dep_name from department,employee
where (employee.dep_id=department.dep_id) 
and (department.dep_code="01"); 
```

它的搜索分析结果如下：  
Estimate 2 I/O operations  
Scan department using primary key  
for rows where dep_code equals "01"  
Estimate getting here 1 times  
Scan employee sequentially  
Estimate getting here 5 times  

第一种方法与第二种运行效率相同，但第一种方法最好，因为它为优化器提供了更多的选择机会。
  
#### 第三种方法：
 
``` 
select employee.emp_name,department.dep_name from department,employee 
where (employee.dep_id = department.dep_id) 
and (employee.dep_code="01");  

```

这种方法最不好，因为它无法使用索引，也就是无法优化……
  
使用SQL语句时应注意以下几点：  
1、避免使用不兼容的数据类型。例如，Float和Integer，Char和Varchar，Binary和Long Binary不兼容的。数据类型的不兼容可能使优化器无法执行一些本可以进行的优化操作。例如：  
select emp_name form employee where salary > 3000;  
在此语句中若salary是Float类型的，则优化器很难对其进行优化，因为3000是个整数，我们应在编程时使用3000.0而不要等运行时让DBMS进行转化。  
2、尽量不要使用表达式，因它在编绎时是无法得到的，所以SQL只能使用其平均密度来估计将要命中的记录数。  
3、避免对搜索参数使用其他的数学操作符。如：
`select emp_name from employee where salary * 12 > 3000;``  
应改为：  
`select emp_name from employee where salary > 250;`

4、避免使用 != 或 <> 等这样的操作符，因为它会使系统无法使用索引，而只能直接搜索表中的数据。  

### ORACAL中的应用  
一个1600万数据表－－短信上行表TBL_SMS_MO  
结构： 
``` 
CREATE TABLE TBL_SMS_MO  
(  
SMS_ID NUMBER,  
MO_ID VARCHAR2(50),  
MOBILE VARCHAR2(11),  
SPNUMBER VARCHAR2(20),  
MESSAGE VARCHAR2(150),  
TRADE_CODE VARCHAR2(20),  
LINK_ID VARCHAR2(50),  
GATEWAY_ID NUMBER,  
GATEWAY_PORT NUMBER,  
MO_TIME DATE DEFAULT SYSDATE  
);  
CREATE INDEX IDX_MO_DATE ON TBL_SMS_MO (MO_TIME)  
PCTFREE 10  
INITRANS 2  
MAXTRANS 255  
STORAGE  
(  
INITIAL 1M  
NEXT 1M  
MINEXTENTS 1  
MAXEXTENTS UNLIMITED  
PCTINCREASE 0  
);  
CREATE INDEX IDX_MO_MOBILE ON TBL_SMS_MO (MOBILE)  
PCTFREE 10  
INITRANS 2  
MAXTRANS 255  
STORAGE  
(  
INITIAL 64K  
NEXT 1M  
MINEXTENTS 1  
MAXEXTENTS UNLIMITED  
PCTINCREASE 0  
);  
```
　　问题：从表中查询某时间段内某手机发送的短消息，如下SQL语句： 
``` 
SELECT MOBILE,MESSAGE,TRADE_CODE,MO_TIME  
FROM TBL_SMS_MO  
WHERE MOBILE='130XXXXXXXX'  
AND MO_TIME BETWEEN TO_DATE('2006-04-01','YYYY-MM-DD HH24:MI:SS') AND TO_DATE('2006-04-07','YYYY-MM-DD HH24:MI:SS')  
ORDER BY MO_TIME DESC  
```
返回结果大约需要10分钟，应用于网页查询，简直难以忍受。  
分析：  
在PL/SQL Developer，点击“Explain Plan”按钮（或F5键），对SQL进行分析，发现缺省使用的索引是IDX_MO_DATE。问题可能出在这里，因为相对于总数量1600万数据来说， 都mobile的数据是很少的，如果使用ID_MO_MOBILE比较容易锁定数据。  
如下优化：
```  
SELECT MOBILE,MESSAGE,TRADE_CODE,MO_TIME  
FROM TBL_SMS_MO  
WHERE MOBILE='130XXXXXXXX'  
AND MO_TIME BETWEEN TO_DATE('2006-04-01','YYYY-MM-DD HH24:MI:SS') AND TO_DATE('2006-04-07','YYYY-MM-DD HH24:MI:SS')  
ORDER BY MO_TIME DESC  
```
测试：  
按F8运行这个SQL，哇～... ... 2.360s，这就是差别。  
用索引提高SQL Server性能  
特别说明  
　　在微软的SQL Server系统中通过有效的使用索引可以提高数据库的查询性能，但是性能的提高取决于数据库的实现。在本文中将会告诉你如何实现索引并有效的提高数据库的性能。　  
  
　 　在关系型数据库中使用索引能够提高数据库性能，这一点是非常明显的。用的索引越多，从数据库系统中得到数据的速度就越快。然而，需要注意的是，用的索引 越多，向数据库系统中插入新数据所花费的时间就越多。在本文中，你将了解到微软的SQL Server数据库所支持的各种不同类型的索引，在这里你将了解到如何使用不同的方法来实现索引，通过这些不同的实现方法，你在数据库的读性能方面得到的 远比在数据库的整体性能方面的损失要多得多。  
  
　　索引的定义  
　　索引是数据库的工具，通过使用索引，在数据库中获取数据的时 候，就可以不用扫描数据库中的所有数据记录，这样能够提高系统获取数据的性能。使用索引可以改变数据的组织方式，使得所有的数据都是按照相似的结构来组织 的，这样就可以很容易地实现数据的检索访问。索引是按照列来创建的，这样就可以根据索引列中的值来帮助数据库找到相应的数据。  
  
　　索引的类型  
　 　微软的SQL Server 支持两种类型的索引：clustered 索引和nonclustered索引。Clustered 索引在数据表中按照物理顺序存储数据。因为在表中只有一个物理顺序，所以在每个表中只能有一个clustered索引。在查找某个范围内的数据 时，Clustered索引是一种非常有效的索引，因为这些数据在存储的时候已经按照物理顺序排好序了。  
  
　　 Nonclustered索引不会影响到下面的物理存储，但是它是由数据行指针构成的。如果已经存在一个clustered索引，在 nonclustered中的索引指针将包含clustered索引的位置参考。这些索引比数据更紧促，而且对这些索引的扫描速度比对实际的数据表扫描要 快得多。  
  
　　如何实现索引  
　　数据库可以自动创建某些索引。例如，微软的SQL Server系统通过自动创建唯一索引来强制实现UNIQUE约束，这样可以确保在数据库中不会插入重复数据。也可以使用CREATE INDEX语句或者通过SQL Server Enterprise Manager来创建其他索引，SQL Server Enterprise Manager还有一个索引创建模板来指导你如何创建索引。  
  
　　得到更好的性能  
　　虽然索引可以带来性能上的优势，但是同时 也将带来一定的代价。虽然SQL Server系统允许你在每个数据表中创建多达256个nonclustered索引，但是建议不要使用这么多的索引。因为索引需要在内存和物理磁盘驱动 器上使用更多的存储空间。在执行插入声明的过程中可能会在一定程度上导致系统性能的下降，因为在插入数据的时候是需要根据索引的顺序插入，而不是在第一个 可用的位置直接插入数据，这样一来，存在的索引越多将导致插入或者更新声明所需要的时间就越多。  
  
　　在使用SQL Server系统创建索引的时候，建议参照下面的创建准则来实现：  
  
　　正确的选择数据类型  
　 　在索引中使用某些数据类型可以提高数据库系统的效率，例如，Int，bigint， smallint，和tinyint等这些数据类型都非常适合于用在索引中，因为他们都占用相同大小的空间并且可以很容易地实现比较操作。其他的数据类型 如char和varchar的效率都非常低，因为这些数据类型都不适合于执行数学操作，并且执行比较操作的时间都比上面提到数据类型要长。  
  
　　确保在使用的过程中正确的利用索引值  
　 　在执行查询操作时，可能所使用的列只是clustered的一部分，这时尤其要注意的是如何使用这些数据。当用这些数据列作为参数调用函数时，这些函数 可能会使现有的排序优势失效。例如，使用日期值作为索引，而为了实现比较操作，可能需要将这个日期值转换为字符串，这样将导致在查询过程中无法用到这个日 期索引值。  
  
　　在创建多列索引时，需要注意列的顺序  
　　数据库将根据第一列索引的值来排列记录，然后进一步根据第二列的值来排序，依次排序直到最后一个索引排序完毕。哪一列唯一数据值较少，哪一列就应该为第一个索引，这样可以确保数据可以通过索引进一步交叉排序。  
  
　　在clustered索引中限制列的数量  
　　在clustered索引中用到的列越多，在nonclustered索引中包含的clustered索引参考位置就越多，需要存储的数据也就越多。这样将增加包含索引的数据表的大小，并且将增加基于索引的搜索时间。  
  
　　避免频繁更新clustered索引数据列  
　 　由于nonclustered 索引依赖于clustered 索引，所以如果构成clustered 索引的数据列频繁更新，将导致在nonclustered中存储的行定位器也将随之频繁更新。对于所有与这些列相关的查询来说，如果发生记录被锁定的情况 时，这将可能导致性能成本的增加。  
  
　　分开操作（如果可能的话）  
　　对于一个表来说，如果需要进行频繁的执行插入、更新操作，同时还有大量读操作的话，在可能的情况下尝试将这个表分开操作。所有的插入和更新操作可以在一个没有索引的表中操作，然后将其复制到另外一个表中，在这个表里有大量的索引可以优化读数据的能力。  
  
　　适当的重建索引  
　 　Nonclustered索引包含clustered索引的指针，这样一来Nonclustered索引将从属于clustered 索引。当重建clustered索引时，首先是丢弃原来的索引，然后再使用CREATE INDEX 来创建索引，或者在使用CREATE INDEX 声明的同时将DROP_EXISTING 子句作为重建索引的一部分。将丢弃和创建分为几步将会导致多次重建nonclustered 索引，而不象使用DROP_EXISTING 子句那样，只重建一次nonclustered 索引。  
  
　　明智的使用填充因子  
　 　数据存储在那些具有固定大小的连续内存页面内。随着新的记录行的加入，数据内存页将逐渐被填满，系统就必须执行数据页的拆分工作，通过这个拆分工作将部 分数据转移到下一个新的页面当中。这样的拆分之后，将加重系统的负担，并且会导致存储的数据支离破碎。填充因子可以维护数据之间的缺口，一般在创建索引的 时候，该索引的填充因子就已经被设置好了。这样一来，可以减少插入数据所引起的页面分裂的次数。因为只是在创建索引的时候才维护空间的大小，在增加数据或 者更新数据时不会去维护空间的大小。因此，要想能够充分的利用填充因子，就必须周期性的重建索引。由填充因子所造成的缺口将导致读性能的下降，因为随着数 据库的扩张，越来越多的磁盘存取工作需要读取数据。所以，在读的次数超过写的次数的时候，很重要的一点是考虑使用填充因子还是使用缺省方式合适。  
  
　　管理层的决策  
　 　通过有效的使用索引，可以在微软的SQL Server系统中实现很好的查询功能，但是使用索引的效率取决于几种不同的实现决策。在索引的性能平衡方面，要做出正确的数据库管理决策意味着需要在良 好的性能和困境中抉择。在特定的情况下，本文给出的一些建议将有助于你做出正确的决策