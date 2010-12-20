[#ftl]
[#assign basePath][#list 1..depth as i]../[/#list][/#assign]
<div id="docco-page">
  <h1 id="docco-back">
    <a href="${basePath}index.html" title="Back to index">&larr;</a>&nbsp;&nbsp;${title}
  </h1>
  <table cellspacing="0" cellpadding="0">
    <tbody>
      [#list sections as sec]
      <tr id="section-${sec_index}">
        <td class="docs">
          ${sec.doc}
        </td>
        <td class="code">
          <pre class="scala"><code>${sec.code?html}</code></pre>
        </td>
      </tr>
      [/#list]
  </table>
</div>