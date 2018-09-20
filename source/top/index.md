---
title: TopX
comments: false
keywords: top,文章阅读量排行榜
description: 博客文章阅读量排行榜
---
<div id="top"></div>
<script src="https://cdn1.lncld.net/static/js/av-core-mini-0.6.4.js"></script>
<script>AV.initialize("4DkhRkq5CadWFisToA3zFrop-gzGzoHsz", "xihAA2ETGTdekJFloguCmmgq");</script>
<script type="text/javascript">
  var time=0
  var title=""
  var url=""
  var query = new AV.Query('Counter');
  query.notEqualTo('id',0);
  query.descending('time');
  query.limit(1000);
  query.find().then(function (todo) {
    for (var i=0;i<1000;i++){
      var result=todo[i].attributes;
      time=result.time;
      title=result.title;
      url=result.url;
      var r = parseInt(Math.random()*255,10)+1
      var g = parseInt(Math.random()*255,10)+1
      var b = parseInt(Math.random()*255,10)+1
      
      var content="<span style='background-color:rgb("+r+", "+g+", "+b+",0.5)' id='inline-toc'>"+(1+i)+".</span>"+"<a href='"+"https://yfzhou.coding.me"+url+"'>"+title+"</a>"+"<br />"+"<font color='#555'>"+"阅读次数：<sapn style='border-radius: 11px;padding: 1px 7px;background-image: linear-gradient(120deg, rgba(247, 149, 51, 0.5) 0%, rgba(243, 112, 85, 0.5) 21%, rgba(239, 78, 123, 0.5) 30%, rgba(161, 102, 171, 0.5) 44%, rgba(80, 115, 184, 0.5) 58%, rgba(16, 152, 173, 0.5) 72%, rgba(7, 179, 155, 0.5) 86%, rgba(109, 186, 130, 0.5) 100%);color: black;'>"+time+"</span></font>"+"<br /><br />";
      document.getElementById("top").innerHTML+=content
    }
  }, function (error) {
    console.log("error");
  });
</script>

<style>.post-description { display: none; }<style>