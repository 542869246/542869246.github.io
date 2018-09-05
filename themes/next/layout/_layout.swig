<!DOCTYPE html>

{% set html_class = 'theme-next ' + theme.scheme %}
{% if theme.motion.enable %}
  {% set html_class = html_class + ' use-motion' %}
{% endif %}

<html class="{{ html_class | lower }}" lang="{{ config.language }}">
<head>
<!--<meta name="baidu-site-verification" content="Cd4Lc5evwc" />-->
  {% include '_partials/head.swig' %}
  <title>{% block title %}{% endblock %}</title>
  <style>
  .forkme{
 display: none;
 }
  @media (min-width: 768px) {
 .forkme{
 display: inline;
 }
  }
  </style>
  {% include '_third-party/analytics/index.swig' %}
</head>


<body itemscope itemtype="http://schema.org/WebPage" lang="{{ page.lang || page.language || config.language }}">

  {% set container_class = "container " %}
  {% if theme.sidebar.position %}
    {% set container_class = container_class + 'sidebar-position-' + theme.sidebar.position %}
  {% endif %}
  <div class="bg_content">
    <canvas id="canvas"></canvas>
  </div>
  <div class="{{ container_class }} {% block page_class %}{% endblock %}">
    <div class="headband"></div>

    <header id="header" class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner"> {%- include '_partials/header.swig' %} </div>
	  
	  {% if hasSearch %}
    <div class="site-search">
      {% include '_partials/search.swig' %}
    </div>
  {% endif %}
	  
    </header>

    <main id="main" class="main">
      <div class="main-inner">
        <div class="content-wrap">
          <div id="content" class="content">
            {% block content %}{% endblock %}
          </div>
          {% include '_third-party/duoshuo-hot-articles.swig' %}
          {% include '_partials/comments.swig' %}
        </div>
        {% if theme.sidebar.display !== 'remove' %}
          {% block sidebar %}{% endblock %}
        {% endif %}
      </div>
    </main>

    <footer id="footer" class="footer">
	
      <div class="footer-inner">
        <div id='show2'></div>
		{% include '_partials/footer.swig' %}
        {% include '_third-party/analytics/analytics-with-widget.swig' %}
        {% block footer %}{% endblock %}
		
      </div>
    </footer>

    {% if not theme.sidebar.b2t %}
      <div class="back-to-top">
        <i class="fa fa-arrow-up"></i>
        {% if theme.sidebar.scrollpercent %}
          <span id="scrollpercent"><span>0</span>%</span>
        {% endif %}
      </div>
    {% endif %}

    {% if theme.needmoreshare2.enable and theme.needmoreshare2.float.enable %}
      <div id="needsharebutton-float">
        <span class="btn">
          <i class="fa fa-share-alt" aria-hidden="true"></i>
        </span>
      </div>
    {% endif %}

  </div>

  {% include '_scripts/vendors.swig' %}
  {% include '_scripts/commons.swig' %}

  {% set scheme_script = '_scripts/schemes/' + theme.scheme | lower + '.swig' %}
  {% include scheme_script %}

  {% block script_extra %}{% endblock %}

  {% include '_scripts/boostrap.swig' %}

  {% include '_third-party/comments/index.swig' %}
  {% include '_third-party/search/index.swig' %}
  {% include '_third-party/analytics/lean-analytics.swig' %}
  {% include '_third-party/analytics/firestore.swig' %}
  {% include '_third-party/seo/baidu-push.swig' %}
  {% include '_third-party/needsharebutton.swig' %}
  {% include '_third-party/rating.swig' %}
  {% include '_third-party/mathjax.swig' %}
  {% include '_third-party/scroll-cookie.swig' %}
  {% include '_third-party/exturl.swig' %}
 
  
  <!-- 右上角github关注-->
  <div class="forkme">
	<a href="https://github.com/542869246"><img style="position: absolute; top: 0; right: 0; border: 0;" src="http://pd2tflnys.bkt.clouddn.com/img/blog/forkme_right_red_aa0000.png" alt="Fork me on GitHub"></a>
  </div>
 
  <!-- 音乐播放器-->
  <link rel="stylesheet" href="/dist/APlayer.min.css">
  <div id="aplayer"></div>
  <script type="text/javascript" src="/dist/APlayer.min.js"></script>
  <script type="text/javascript" src="/dist/music.js"></script>
  
  {{ live2d() }}
   
<!-- 代码块复制功能 -->
<script type="text/javascript" src="/js/src/clipboard.min.js"></script>
<script type="text/javascript" src="/js/src/clipboard-use.js"></script>

</body>
<!-- 背景图-->
<script type="text/javascript" src="/js/src/dynamic_bg.js"></script
 <!-- 页面点击小红心 -->
<script type="text/javascript" src="/js/src/clicklove.js"></script>
 <!-- 页面点击汉字 -->
<script type="text/javascript" src="/js/src/hanzi.js"></script>
</html>
<!--崩溃欺骗-->
<script type="text/javascript" src="/js/src/crash_cheat.js"></script>

<script>
window.onload = function() { 
var show = document.getElementById("show2"); 
setInterval(function() { 
var time = new Date(); 
// 程序计时的月从0开始取值后+1 
var m = time.getMonth() + 1; 
//根据自己博客的创建时间更改数值 
var t = "周宇峰的博客已存活了"+(time.getFullYear()-2018) + "年" + (m-8) + "月" 
+ time.getDate() + "天 " + time.getHours() + "时" 
+ time.getMinutes() + "分" + time.getSeconds() + "秒"; 
show.innerHTML = t; 
}, 1000); 
}; 
</script>
