(function($) {
  $.fn.slider = function(options) {
    var tabs = $(this);
    var output = $(options.output);
    new jQuery.slider(tabs, output, options);
    return this;
  };
  $.slider = function(tabs, output, options) {
    function slide(nr) {
      if (typeof nr == "undefined") {
        nr = visible_item + 1;
        nr = nr >= total_items ? 0 : nr;
      }
      tabs.removeClass('current').filter(":eq(" + nr + ")").addClass('current');
      output.stop(true, true).filter(":visible").fadeOut(function() {
        output.filter(":eq(" + nr + ")").fadeIn(function() {
          visible_item = nr;
        });
      });
    }
    var options = options || {};
    var total_items = tabs.length;
    var visible_item = options.start_item || 0;
    options.pause_on_hover = options.pause_on_hover || true;
    options.transition_interval = options.transition_interval || 5000;
    output.hide().eq( visible_item ).show();
    tabs.eq( visible_item ).addClass('current');
    tabs.click(function() {
      if ($(this).hasClass('current')) {
        return false;
      }
      slide( tabs.index(this) );
    });
    if (options.transition_interval > 0) {
      var timer = setInterval(function() {
        slide();
      }, options.transition_interval);
      if (options.pause_on_hover) {
        tabs.mouseenter(function() {
          clearInterval(timer);
        }).mouseleave(function() {
          clearInterval(timer);
          timer = setInterval(function () {
            slide();
          }, options.transition_interval);
        });
      }
    }
  };
  $(function() {
    $("#projects-slider-tabs li").slider({
      output: "#projects-slider-frames li",
      pause_on_hover: true,
      transition_interval: 60000
    });
  });
})(jQuery);