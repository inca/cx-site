// ciridiri
document.onkeydown = NavigateThrough;
function NavigateThrough (event) {
  if (!document.getElementById) return;
  if (window.event) event = window.event;
  if (event.ctrlKey) {
    var link = null;
    switch (event.keyCode ? event.keyCode : event.which ? event.which : null) {
      case 0x45:
        link = document.getElementById ('edit-link');
        break;
    }
    if (link && link.href) document.location = link.href;
  }
}
function ctrlEnterSubmit(e, form) {
  if (((e.keyCode == 13) || (e.keyCode == 10)) && (e.ctrlKey == true)) form.submit();
}
// syntax highlighting
hljs.initHighlightingOnLoad();
// other stuff
$(function() {
  // smooth scrolling
  $('a[href^=#]').click(function() {
    var $target = $(this.hash);
    $target = $target.length && $target || $('[name=' + this.hash.slice(1) +']');
    if ($target.length) {
      var $elem = this.hash.slice(1);
      var $loc = document.location.href.replace(/#.*$/, "") + "#" + $elem;
      var targetOffset = $target.offset().top;
      $('html,body').animate({scrollTop: targetOffset}, 750,
          function() {document.location.href = $loc;});
      return false;
    }
  });
  // show/hide TOC
  $('#toc-show').click(function() {
    $('#toc-show').fadeOut(200, function(){$('#toc').fadeIn(400);});
  });
  $('#toc-hide').click(function() {
    $('#toc').fadeOut(400, function(){$('#toc-show').fadeIn(200);});
  });
});