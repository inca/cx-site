[#ftl]
[#include '/layout.ftl']
[@page]
<h2>Circumflex-md live preview <a href="/.md-cheatsheet" id="md-markup-help" class="right-float inplace">Markup help</a></h2>
<form action="/.mdwn" method="post" id="md-form">
  <fieldset>
    <textarea rows="20" cols="30" style="width: 100%" name="md" id="md-source" placeholder="Type something here"></textarea>
  </fieldset>
</form>
<p>&nbsp;</p>
<h3 id="results">Result <a href="javascript:;" id="html-result-view" class="right-float inplace">Show source</a></h3>
<div id="md-preview"></div>
<script type="text/javascript">
$("#md-source").focus();
var timeout;
var needs_update = '';

function updatePreview(cont) {
  $.post($("#md-form").attr("action"), $("#md-form").serialize(), function(data, status) {
    if(status == 'success') {
      $("#md-preview").html(data);
      $("#results").show();
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

$("#md-markup-help").click(function() {
  $.get($(this).attr('href'), function(data) {
    $.fn.colorbox({html: '<div id="md-markup-help-contents">' + data + "</div>"});
  });
  return false;
});

$("#results").hide();
</script>
[/@page]