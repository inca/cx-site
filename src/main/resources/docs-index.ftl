[#ftl]

[#assign content]
<div id="page">
  <h1>${docs.title}</h1>
  <h2>Table Of Contents</h2>
  <ul id="docs-index-toc">
    [#list docs.pages as p]
      <li><a href="${p.path}.html">${p.title}</a></li>
    [/#list]
  </ul>
  <p class="docs-see-also">
    This document is also available in a <a href="/docs/${docs.id}/assembly.html">single-page format</a>.
  </p>
</div>
[/#assign]

[#include "/layout.ftl"/]