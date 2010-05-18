[#ftl]
[#include '/layout.ftl']
[@page]
<h2>Circumflex-md live preview</h2>
<form action="/.mdwn" method="post" id="md-form">
  <fieldset>
    <textarea rows="20" cols="30" style="width: 100%" name="md" id="md-source"></textarea>
  </fieldset>
</form>
<div id="md-preview"></div>
<script>
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
</script>
[/@page]