[#ftl]
[#assign content]
<div id="content">
  <div id="page">
    <h1>Circumflex Markeven Live <a href="/products/me/me-cheatsheet" id="me-markup-help" class="right-float inplace">syntax help</a></h1>
    <form action="/products/me" method="post" id="me-form">
      <fieldset>
        <textarea rows="20" cols="30" style="width: 100%" name="me" id="me-source" placeholder="Type something here"></textarea>
      </fieldset>
    </form>
    <p>&nbsp;</p>
    <div id="results">
      <h3><a href="javascript:;" id="html-result-view" class="right-float inplace">show source</a></h3>
      <div id="me-preview"></div>
    </div>
  </div>
</div>

<script type="text/javascript">
  $("#me-source").focus();
  var timeout;
  var needs_update = '';

  function updatePreview(cont) {
    $.post($("#me-form").attr("action"), $("#me-form").serialize(), function(data, status) {
      if(status == 'success') {
        $("#me-preview").html(data);
        $("#results").show();
      }
      cont();
    });
  }

  function scheduleUpdate() {
    if(needs_update == $("#me-source").val())
      return;
    needs_update = $("#me-source").val();
    clearTimeout(timeout);
    timeout = setTimeout(function () {
      clearTimeout(timeout);
      updatePreview(function () {
        if (needs_update != $("#me-source").val() && !timeout)
          scheduleUpdate();
      });
    }, 500)
  }

  $("#me-source").keyup(function(){
    if ($("#me-source").val().trim() != "") scheduleUpdate();
    else $("#results").hide();
  });

  $("#html-result-view").click(function() {
    $.fn.colorbox({html:'<pre><code>' + $('<div/>').text($("#me-preview").html()).html() + '</code></pre>'});
  });

  $("#me-markup-help").click(function() {
    $.get($(this).attr('href'), function(data) {
      $.fn.colorbox({html: '<div id="me-markup-help-contents">' + data + "</div>"});
    });
    return false;
  });

  $("#results").hide();
</script>
[/#assign]

[#include '/layout.ftl']