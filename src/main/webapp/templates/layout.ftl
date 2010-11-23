[#ftl]
[#macro page]
<!doctype html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <link rel="stylesheet" media="screen, projection" href="/css/main.css" />
  <link rel="stylesheet" media="screen, projection" href="/css/colorbox.css" />
  <link rel="stylesheet" media="print" href="/css/print.css" />
  <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon"/>
  <link rel="icon" href="/favicon.ico" type="image/x-icon"/>
  <meta name="google-site-verification" content="8igpdSJ4tgF2EKKuvmA5GOWzRLKHozE5Aun82c5NQZY" />
  <meta name='yandex-verification' content='443ed98406777aa4' />
  <meta name='yandex-verification' content='59d4a20bb51bbfea' />
  [#if (cfg['ga.enabled']!"false") == "true"]
    <script type="text/javascript" src="http://www.google-analytics.com/ga.js">
    </script>
  [/#if]
  <script src="/js/highlight.pack.js"></script>
  <script src="/js/jquery-1.4.2.min.js"></script>
  <script src="/js/jquery.colorbox-min.js"></script>
  <script src="/js/typeface.js"></script>
  <script src="/js/scriptorama.typeface.js"></script>
  <script src="/js/application.js"></script>
  [#if ciripage?? && .template_name?ends_with('/page.ftl')]
    <link rel="alternate"
          id="edit-link"
          type="application/x-wiki"
          title="Edit this page"
          href="${ciripage.uri}.html.e" />
  [/#if]
  <title>
    [#if ciripage?? && ciripage.title != '']
    ${ciripage.title}
      [#else]
        Circumflex &mdash; exquisite taste of Scala development
    [/#if]
  </title>
</head>
<body>
<div id="header">
  <div class="wrap">
    <h1><a href="/" title="Home">C&icirc;rcumflex</a></h1>
    [#--<ul class="topnav">--]
      [#--<li><a href="http://blog.circumflex.ru">Blog</a></li>--]
      [#--<li><a href="http://docs.circumflex.ru">Docs</a></li>--]
      [#--<li><a href="http://qa.circumflex.ru">Q<span class="amp">&amp;</span>A</a></li>--]
    [#--</ul>--]
    <span class="aside">exquisite taste of <a href="http://scala-lang.org">Scala</a> development</span>
  </div>
</div>
  [#if toc?? && toc.toHtml != '']
  <a id="toc-show"
     class="toc"
     href="javascript:;"
     title="Show Table of Contents">table of contents &raquo;</a>
  <div id="toc" class="toc" style="display:none">
    <a id="toc-hide"
       class="right-float"
       href="javascript:;"
       title="Hide Table of Contents">
      <span>&times;</span>
    </a>
  ${toc.toHtml}
  </div>
  [/#if]
<div id="content">
  <div id="page">
    [#nested/]
  </div>
</div>
<div id="footer">
  <span>Copyright 2009-${currentYear} <a href="http://circumflex.ru">circumflex.ru</a></span>
</div>
[@stats/]
</body>
</html>
[/#macro]

[#macro stats]
  [#if (cfg['ga.enabled']!"false") == "true"]
  <script type="text/javascript">
    try {
      var pageTracker = _gat._getTracker("UA-12034468-1");
      pageTracker._setDomainName(".circumflex.ru");
      pageTracker._trackPageview();
    } catch(err) {}</script>
  [/#if]
[/#macro]
