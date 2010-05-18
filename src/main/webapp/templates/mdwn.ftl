[#ftl]
[#include '/layout.ftl']
[@page]
<h2>Circumflex-md live preview</h2>
<form action="/.mdwn" method="post" id="md-form">
  <fieldset>
    <textarea rows="20" cols="30" style="width: 100%" name="md" id="md-source"></textarea>
  </fieldset>
</form>
<p>&nbsp;</p>
<h3>Result <a href="javascript:;" id="html-result-view" class="right-float inplace">Show source</a></h3>
<div id="md-preview"></div>
<script type="text/javascript">
$("#md-source").focus();
var timeout;
var needs_update = '';

function updatePreview(cont) {
  $.post($("#md-form").attr("action"), $("#md-form").serialize(), function(data, status) {
    if(status == 'success') {
      $("#md-preview").html(data);
    }
    cont();
  });
}

function scheduleUpdate() {
  if(needs_update == $("#md-source").val())
    return;

  needs_update = $("#md-source").val();
  clearTimeout(timeout);
  timeout = setTimeout(function () {
    clearTimeout(timeout);
    updatePreview(function () {
      if (needs_update != $("#md-source").val() && !timeout)
        scheduleUpdate();
    });
  }, 500)
}

$("#md-source").keyup(function(){
  scheduleUpdate();
});

$("#html-result-view").click(function() {
  $.fn.colorbox({html:'<pre><code>' + $('<div/>').text($("#md-preview").html()).html() + '</code></pre>'});
});
</script>
[/@page]