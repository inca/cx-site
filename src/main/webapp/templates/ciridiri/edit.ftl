[#ftl]
[#include "layout.ftl"]
[@page]
<h1>Edit page</h1>
<script type="text/javascript">
window.onload = function() {
  document.getElementById('p-content').focus();
}
</script>

<form action="${p.uri}.html" method="post" onkeypress="ctrlEnterSubmit(event, this)">
<fieldset>
  <div>
    <textarea rows="30" cols="20" id="p-content" name="content" style="width: 100%">${p.content?html}</textarea>
  </div>
  <div>
    <label for="password">Password: </label><input type="password" name="password" id="password" />
  </div>
</fieldset>
<fieldset class="submits">
    <input type="submit" value="Save" /> or <a href="${p.uri}.html">cancel</a>
</fieldset>
</form>
[/@page]
