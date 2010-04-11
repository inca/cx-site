[#ftl]
[#include '/layout.ftl']
[@page]
<div id="git-status">
${status}
</div>
<form action=".git"
      method="post">
  <textarea id="message"
            name="message"
            rows="5"
            style="width: 100%"></textarea>
  <fieldset class="submits">
    <input type="submit" value="add ." name="add"/>
    <input type="submit" value="commit -a" name="commit"/>
    <input type="submit" value="push origin master" name="push"/>
  </fieldset>
</form>
[/@page]