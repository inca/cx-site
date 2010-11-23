[#ftl]
[#assign content]
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
    ${ciripage.toHtml}
  </div>
</div>
[/#assign]
[#include "/layout.ftl"]