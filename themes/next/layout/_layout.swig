<!DOCTYPE html>

{# NexT version #}
{% set version = next_env('version') %}

{# Language & Config #}
{% set title = __('title') !== 'title' && __('title') || config.title %}
{% set subtitle = __('subtitle') !== 'subtitle' && __('subtitle') || config.subtitle %}
{% set author = __('author') !== 'author' && __('author') || config.author %}
{% set description = __('description') !== 'description' && __('description') || config.description %}

{% set html_class = 'theme-next ' + theme.scheme %}
{% if theme.motion.enable %}
  {% set html_class = html_class + ' use-motion' %}
{% endif %}

<html class="{{ html_class | lower }}" lang="{{ config.language }}">
<head>
  {{ partial('_partials/head/head.swig', {}, {cache: theme.cache.enable}) }}
  {% include '_partials/head/head-unique.swig' %}
  <title>{% block title %}{% endblock %}</title>
  {% include '_third-party/analytics/index.swig' %}
  {{ partial('_scripts/noscript.swig', {}, {cache: theme.cache.enable}) }}
</head>

<body itemscope itemtype="http://schema.org/WebPage" lang="{{ page.lang || page.language || config.language }}">

  {% set container_class = "container " %}
  {% if theme.sidebar.position %}
    {% set container_class = container_class + 'sidebar-position-' + theme.sidebar.position %}
  {% endif %}

  <div class="{{ container_class }} {% block page_class %}{% endblock %}">
    <div class="headband"></div>

    <header id="header" class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner">{% include '_partials/header/index.swig' %}</div>
    </header>

    {{ partial('_third-party/github-banner.swig', {}, {cache: theme.cache.enable}) }}

    <main id="main" class="main">
      <div class="main-inner">
        <div class="content-wrap">
          {% if theme.scheme === 'Pisces' || theme.scheme === 'Gemini' %}
            {% include '_partials/header/sub-menu.swig' %}
          {% endif %}
          <div id="content" class="content">
            {% block content %}{% endblock %}
          </div>
          {% include '_partials/comments.swig' %}
        </div>
        {% if theme.sidebar.display !== 'remove' %}
          {% block sidebar %}{% endblock %}
        {% endif %}
      </div>
    </main>

    <footer id="footer" class="footer">
      <div class="footer-inner">
        {{ partial('_partials/footer.swig', {}, {cache: theme.cache.enable}) }}
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
	
    {% if theme.baidushare and theme.baidushare.type === "slide" %}
      <div>
        {% include '_partials/share/baidushare.swig' %}
      </div>
    {% endif %}

    {% if theme.add_this_id %}
      <div>
        {% include '_partials/share/add-this.swig' %}
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
  {% include '_third-party/math/index.swig' %}
  {% include '_third-party/needsharebutton.swig' %}
  {% include '_third-party/rating.swig' %}
  {% include '_third-party/pangu.swig' %}
  {% include '_third-party/scroll-cookie.swig' %}
  {% include '_third-party/exturl.swig' %}
  {% include '_third-party/bookmark.swig' %}
  {% include '_third-party/copy-code.swig' %}
  
  <div class="bg_content">
	<!--<canvas id="canvas"></canvas>
	<canvas id="canvas1"></canvas>-->
	  <!-- html5-canvas-animation-->
	  <div class="canvas-wrap">
		<!-- <div class="canvas-content">
			<h1>Hello world</h1>
		</div>-->
		<div id="canvas3" class="gradient"></div>
	</div>
  </div>
  
  
  
  <!-- 右上角github关注-->
  <div class="forkme">
	<a href="https://github.com/542869246"><img style="position: absolute; top: 0; right: 0; border: 0;" src="http://pd2tflnys.bkt.clouddn.com/img/blog/forkme_right_red_aa0000.png" alt="Fork me on GitHub"></a>
  </div>
  
  <!-- 音乐播放器-->
  <link rel="stylesheet" href="/dist/APlayer.min.css">
  <div id="aplayer"></div>
  <script type="text/javascript" src="/dist/APlayer.min.js"></script>
  <script type="text/javascript" src="/dist/music.js"></script>
 
   <!-- 页面点击小红心 -->
<script type="text/javascript" src="/js/src/clicklove.js"></script>
 <!-- 页面点击汉字 -->
<script type="text/javascript" src="/js/src/hanzi.js"></script>
  
  <!-- 代码块复制功能 -->
<script type="text/javascript" src="/js/src/clipboard.min.js"></script>  
<script type="text/javascript" src="/js/src/clipboard-use.js"></script>
<!-- 流星雨-->
<!--<script type="text/javascript" src="/js/src/meteor-rain.js"></script>-->
<!-- 粒子效果-->
<!--<script type="text/javascript" src="/js/src/dynamic_bg.js"></script>-->

<!-- html5-canvas-animation-->
<!-- Main library -->
<script src="/js/src/three.min.js"></script>
<!-- Helpers -->
<script src="/js/src/projector.js"></script>
<script src="/js/src/canvas-renderer.js"></script>
<!-- Visualitzation adjustments -->
<script src="/js/src/3d-lines-animation.js"></script>
<!-- Animated background color -->
<script src="/js/src/color.js"></script>



</body>
</html>
