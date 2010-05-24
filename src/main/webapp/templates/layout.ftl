[#ftl]
[#macro page]
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <link rel="stylesheet" media="screen, projection" href="/css/base.css" />
  <link rel="stylesheet" media="screen, projection" href="/css/colorbox.css" />
  <link rel="stylesheet" media="print" href="/css/print.css" />
  <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon"/>
  <link rel="icon" href="/favicon.ico" type="image/x-icon"/>
  <meta name="google-site-verification" content="8igpdSJ4tgF2EKKuvmA5GOWzRLKHozE5Aun82c5NQZY" />
  <meta name='yandex-verification' content='443ed98406777aa4' />
  <meta name='yandex-verification' content='59d4a20bb51bbfea' />
  <script type="text/javascript" src="http://www.google-analytics.com/ga.js">
  </script>
  <script src="/js/application.js"></script>
  <script src="/js/highlight.pack.js"></script>
  <script src="/js/jquery-1.4.2.min.js"></script>
  <script src="/js/jquery.colorbox-min.js"></script>
  <script type="text/javascript">
    // syntax highlighting
    hljs.initHighlightingOnLoad();
    // other stuff
    $(document).ready(function(){
      // smooth scrolling
      $('a[href*=#]').click(function() {
        var $target = $(this.hash);
        $target = $target.length && $target || $('[name=' + this.hash.slice(1) +']');
        if ($target.length) {
          var $elem = this.hash.slice(1);
          var $loc = document.location.href.replace(/#.*$/, "") + "#" + $elem;
          var targetOffset = $target.offset().top;
          $('html,body').animate({scrollTop: targetOffset}, 750,
                  function() {document.location.href = $loc;});
          return false;
        }
      });
      // show/hide TOC
      $('#toc').hide();
      $('#toc-show').click(function() {
        $('#toc-show').fadeOut(200, function(){$('#toc').fadeIn(400);});
      });
      $('#toc-hide').click(function() {
        $('#toc').fadeOut(400, function(){$('#toc-show').fadeIn(200);});
      });
    });
  </script>
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
        Circumflex &mdash; lightweight Web-framework and ORM for Scala
    [/#if]
  </title>
</head>
<body>
<div id="header">
  <h1><a href="/" title="Home">Circumflex</a></h1>
</div>
  [#if toc?? && toc.toHtml != '']
  <a id="toc-show" class="toc" href="javascript:;" title="Show Table of Contents">table of contents &raquo;</a>
  <div id="toc" class="toc">
    <a id="toc-hide" class="right-float" href="javascript:;" title="Hide Table of Contents">&times;</a>
  ${toc.toHtml}
  </div>
  [/#if]
<div id="outer">
  [#if sitemap??]
  [@bar id="nav"]
  ${sitemap.toHtml}
  [/@bar]
  [/#if]
  <div id="scraps">
  </div>
  <div id="page">
    [#nested/]
  </div>
  <div id="footer">
    <span class="years">2008-${currentYear}</span>
    <a class="home" href="http://${host}">${host}</a>
  </div>
</div>
[@stats/]
</body>
</html>
[/#macro]

[#macro bar theme="green" id="" style=""]
<div [#if id != ""]id="${id}"[/#if]
     class="bar"
     style="${style}">
  <div class="${theme}">
    <div class="w">
      <div class="e">
        <div class="c">
          [#nested/]
        </div>
      </div>
    </div>
  </div>
</div>
[/#macro]

[#macro stats]
<script type="text/javascript">
  try {
    var pageTracker = _gat._getTracker("UA-12034468-1");
    pageTracker._setDomainName(".circumflex.ru");
    pageTracker._trackPageview();
  } catch(err) {}</script>
[/#macro]
