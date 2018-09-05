---
title: Oracle 分组统计，按照天、月份周和自然周、月、季度和年
copyright: true
top: 95
date: 2018-08-21 18:11:20
categories: [数据库]
tags: [数据库,Oracle,SQL]
image: https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1535736919024&di=e16df4d6b012c06cb45eeb9af6b17d48&imgtype=0&src=http%3A%2F%2Fattachments.gfan.com%2Fforum%2Fattachments2%2F201304%2F24%2F134256oe4lamvbxm7bb2hq.jpg
---


做报表统计时会经常用到 周，月，季度，年进行分组统计，所以结合网络搜索推荐的sql，总结如下

<!--more-->

```
-- 按天统计
select to_char(t.CREATED+15/24, 'YYYY-MM-DD') as 天,sum(1) as 数量
from TB_EXT_TRADE t
WHERE
	t.TID LIKE 'SC%' OR t.TID LIKE 'WSC%'
group by to_char(t.CREATED+15/24, 'YYYY-MM-DD') --trunc(t.CREATED, 'DD')

```

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20160822152940276.jpg)

```
-- 按自然周的日期统计 
select to_char(next_day(t.CREATED+15/24 - 7,2),'YYYY-MM-DD') AS 周,sum(1) as 数量
from TB_EXT_TRADE t
WHERE
	t.TID LIKE 'SC%' OR t.TID LIKE 'WSC%'
group by to_char(next_day(t.CREATED+15/24 - 7,2),'YYYY-MM-DD')
ORDER BY 周;
```

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20160822153822139.jpg)  

```
-- 按自然周统计 
select to_char(t.CREATED,'iw') AS 周,sum(1) as 数量
from TB_EXT_TRADE t
WHERE
	t.TID LIKE 'SC%' OR t.TID LIKE 'WSC%'
group by to_char(t.CREATED,'iw')
ORDER BY 周;

```

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20160822153043617.jpg)

```
-- 按自然月统计 
select to_char(t.CREATED,'YYYY-MM') as 月份,sum(1) as 数量
from TB_EXT_TRADE t
WHERE
	t.TID LIKE 'SC%' OR t.TID LIKE 'WSC%'
GROUP BY
	to_char(t.CREATED,'YYYY-MM') -- to_char(t.CREATED+15/24,'yyyy-mm') 不大准确
ORDER BY 月份;
```


![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20160822153206494.jpg)

```
-- 按季统计 
select to_char(t.CREATED,'q') 季度,sum(1) as 数量
from TB_EXT_TRADE t
WHERE
	t.TID LIKE 'SC%' OR t.TID LIKE 'WSC%'
group by to_char(t.CREATED,'q')
ORDER BY 季度 NULLS  LAST;
```

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20160822153233106.jpg)

```
--按年统计 
select to_char(t.CREATED,'yyyy') AS 年度,sum(1) as 数量
from TB_EXT_TRADE t
WHERE
	t.TID LIKE 'SC%' OR t.TID LIKE 'WSC%'
group by to_char(t.CREATED,'yyyy')
ORDER BY 年度;

```

![](https://yfzhou.oss-cn-beijing.aliyuncs.com/blog/img/20160822153258464.jpg)