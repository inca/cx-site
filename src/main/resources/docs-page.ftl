[#ftl]

[#assign nav]
<table class="docs-nav">
  <tbody>
  <tr>
    <td class="docs-nav-prev">
      [#if prevPage??]
        <a href="${prevPage.path}.html">&larr; ${prevPage.title}</a>
      [/#if]
    </td>
    <td class="docs-nav-up">
      <a href="/docs/${docs.id}/index.html">${docs.title}</a>
    </td>
    <td class="docs-nav-next">
      [#if nextPage??]
        <a href="${nextPage.path}.html">${nextPage.title} &rarr;</a>
      [/#if]
    </td>
  </tr>
  </tbody>
</table>
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