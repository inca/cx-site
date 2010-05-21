[#ftl]
[#macro page]
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <link rel="stylesheet" media="screen, projection" href="/css/base.css" />
  <link rel="stylesheet" media="screen, projection" href="/css/colorbox.css" />
  <link rel="stylesheet" media="print" href="/css/print.css" />
  <link rel="shortcuticon" href="/favicon.ico"/>
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
    hljs.initHighlightingOnLoad();
    $(document).ready(function(){
      $('a[href*=#]').click(function() {
        if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'')
                && location.hostname == this.hostname) {
          var $target = $(this.hash);
          $target = $target.length && $target || $('[name=' + this.hash.slice(1) +']');
          if ($target.length) {
            var targetOffset = $target.offset().top;
            $('html,body').animate({scrollTop: targetOffset}, 1000);
            return false;
          }
        }
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
<div id="toc">
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
