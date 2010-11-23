[#ftl]

[#assign content]
<div id="content">
  <div id="page">
    <div id="docco-index">
      <h1>${title}</h1>
      <ul>
        [#list dirs as dir]
          <li>
            <p>${dir}</p>
            <ul>
              [#list index[dir] as file]
                <li><a href="${dir}/${file}.html">${file}</a></li>
              [/#list]
            </ul>
          </li>
        [/#list]
      </ul>
    </div>
  </div>
</div>
[/#assign]

[#include "/layout.ftl"/]