[#ftl]

[#assign nav]
<div class="docs-nav">
  [#if prevPage??]
    <a class="docs-nav-prev" href="${prevPage.path}.html">&larr; ${prevPage.title}</a>
  [/#if]
  <a class="docs-nav-up" href="/docs/${docs.id}/index.html">${docs.title}</a>
  [#if nextPage??]
    <a class="docs-nav-next" href="${nextPage.path}.html">${nextPage.title} &rarr;</a>
  [/#if]
</div>
[/#assign]

[#assign content]
<div id="page">
${nav}
  <h1>${page.title}</h1>
${page.toHtml}
${nav}
</div>
[/#assign]

[#include "/layout.ftl"/]