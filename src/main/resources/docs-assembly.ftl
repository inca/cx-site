[#ftl]

[#assign content]
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
  <ul>
    [#list docs.pages as p]
      <li><a href="#${p.anchor}">${p.title}</a></li>
    [/#list]
  </ul>
</div>
<div id="page">
  <h1>${docs.title}</h1>
  <h2>Table Of Contents</h2>
  <ul id="docs-index-toc">
    [#list docs.pages as p]
      <li><a href="#${p.anchor}">${p.title}</a></li>
    [/#list]
  </ul>
  <p class="docs-see-also">
    This document is also available in a <a href="/docs/${docs.id}/index.html">multi-page format</a>.
  </p>
  [#list docs.pages as p]
    <h1 id="${p.anchor}">${p.title}</h1>
  ${p.toAssemblyHtml}
  [/#list]
</div>
[/#assign]

[#include "/layout.ftl"/]