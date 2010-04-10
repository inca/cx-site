[#ftl]
[#macro page]
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html; charset=utf-8" />
  <link rel="stylesheet" media="screen, projection" href="/css/base.css" />
  <link rel="stylesheet" media="print" href="/css/print.css" />
  <script src="/js/application.js"></script>
  [#if p?? && .template_name == 'page.ftl']
    <link rel="alternate"
          id="edit-link"
          type="application/x-wiki"
          title="Edit this page"
          href="${p.uri}.html.e" />
  [/#if]
  <title>
    [#if p?? && p.title != '']
    ${p.title}
      [#else]
        Circumflex &mdash; lightweight Web-framework and ORM for Scala
    [/#if]
  </title>
</head>
<body>
<div id="header">
  <h1><a href="/" title="Home">Circumflex</a></h1>
</div>
<div id="outer">
[@bar id="nav"]
  <ul>
    <li><a href="/">Home</a></li>
  </ul>
[/@bar]
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
