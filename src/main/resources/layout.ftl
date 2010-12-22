[#ftl]
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
  <script type="text/javascript" src="http://www.google-analytics.com/ga.js">
  </script>
  <script src="/js/highlight.pack.js"></script>
  <script src="/js/jquery-1.4.2.min.js"></script>
  <script src="/js/jquery.colorbox-min.js"></script>
  <script src="/js/application.js"></script>
  <script src="/js/menu.js"></script>
  <title>Circumflex &mdash; exquisite taste of Scala development</title>
</head>
<body>
<div id="header">
  <div class="wrap">
    <h1>
      <a href="/" title="Home">C&icirc;rcumflex</a>
    </h1>
    <div id="topnav">
      <p>exquisite taste of <a href="http://scala-lang.org">Scala</a> development</p>
      <div id="slidemenu">
      ${sitemap.toHtml}
      </div>
    </div>
  </div>
</div>
${content!}
<div id="footer">
  <p>
    <a href="/license.html">Terms <span class="amp">&amp;</span> conditions</a>
    <span>&middot;</span>
    <a href="/support.html">Support</a>
    <span>&middot;</span>
    <a href="/contacts.html">Contacts</a>
    <span>&middot;</span>
    <a href="/credits.html">Credits</a>
  </p>
  <p>
    <span>Copyright 2009-${currentYear}</span>
    <a href="http://circumflex.ru">circumflex.ru</a>
  </p>
</div>
[@stats/]
</body>
</html>

[#macro stats]
<script type="text/javascript">
  try {
    var pageTracker = _gat._getTracker("UA-12034468-1");
    pageTracker._setDomainName(".circumflex.ru");
    pageTracker._trackPageview();
  } catch(err) {}</script>
[/#macro]
