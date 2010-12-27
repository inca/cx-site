(function() {

  // Code highlighting
  hljs.initHighlightingOnLoad();

  // Menu
  var jqueryslidemenu = {
    animateduration: {over: 200, out: 100},
    buildmenu:function(menuid, arrowsvar){
      jQuery(document).ready(function($){
        var $mainmenu=$("#" + menuid + ">ul");
        var $headers=$mainmenu.find("ul").parent();
        $headers.each(function(i){
          var $curobj = $(this);
          var $subul = $(this).find('ul:eq(0)');
          this._dimensions = {
            w:this.offsetWidth,
            h:this.offsetHeight,
            subulw:$subul.outerWidth(),
            subulh:$subul.outerHeight()
          };
          this.istopheader = $curobj.parents("ul").length == 1;
          $subul.css({ top: this.istopheader ? this._dimensions.h + "px" : 0});
          $curobj.hover(
              function(e){
                var $targetul = $(this).children("ul:eq(0)")
                this._offsets = {
                  left:$(this).offset().left,
                  top:$(this).offset().top
                };
                var menuleft = this.istopheader ? 0 : this._dimensions.w + 2;
                menuleft = (this._offsets.left + menuleft + this._dimensions.subulw > $(window).width()) ?
                    (this.istopheader ? - this._dimensions.subulw + this._dimensions.w : - this._dimensions.w)
                    : menuleft;
                if ($targetul.queue().length <= 1) //if 1 or less queued animations
                  $targetul.css({
                    left:menuleft+"px",
                    width:this._dimensions.subulw+'px'
                  }).slideDown(jqueryslidemenu.animateduration.over)
              },
              function(e){
                var $targetul = $(this).children("ul:eq(0)")
                $targetul.slideUp(jqueryslidemenu.animateduration.out)
              }
              );
          $curobj.click(function(){
            $(this).children("ul:eq(0)").hide()
          })
        });
        $mainmenu.find("ul").css({display:'none', visibility:'visible'})
      });
    }
  };

  jqueryslidemenu.buildmenu("slidemenu");

  // Slider

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
    $("#projects-slider-tabs > li").slider({
      output: "#projects-slider-frames > li",
      pause_on_hover: true,
      transition_interval: 60000
    });
  });

  // GitHub activities
  $(function() {
    var maxCommits = 3;
    var apiUrl = "http://github.com/api/v2/json/commits/list/inca/circumflex";
    var commitsSection = $("#gh-commits");
    if (commitsSection.length > 0) {
      var commitTemplate = $("#gh-commit-tmpl");
      // replace with loading image
      var placeholder = $('<img src="/img/loading.gif"/>');
      commitsSection.after(placeholder);
      // retrieve refspec for github
      var refspec = $("a", commitsSection).text();
      var url = apiUrl + "/" + refspec;
      // go to GitHub for commit data
      $.get(url, function(data) {
        var i = 0;
        maxCommits = data.commits.length < maxCommits ? data.commits.length : maxCommits;
        var commitsList = $('<ul id="gh-commits-list"/>');
        for (i = 0; i < maxCommits; i++) {
          var commit = data.commits[i];
          var emailHash = $.md5(commit.author.email);
          var commitDate = new Date(Date.parse(commit.committed_date)).toDateString();
          var listItem = commitTemplate.tmpl({"commit": commit, "emailHash": emailHash, "commitDate": commitDate});
          commitsList.append(listItem);
        }
        placeholder.replaceWith(commitsList);
      }, "jsonp");
    }
  });

  // GitHub downloads
  $(function() {
    var downloadsSection = $("#gh-downloads");
    if (downloadsSection.length > 0) {
      var downloadsTemplate = $("#gh-downloads-tmpl");
      var placeholder = $('<img src="/img/loading.gif"/>');
      downloadsSection.after(placeholder);
      $.get("/json/meta.json", function(data) {
        var i = 0;
        var downloadsList = $('<ul id="gh-downloads-list"/>');
        for(i = 0; i < data.releases.length; i++) {
          var release = data.releases[i];
          var listItem = downloadsTemplate.tmpl({"release": release});
          downloadsList.append(listItem);
        }
        placeholder.replaceWith(downloadsList);
      }, "json");
    }
  });

  // Maven downloads
  $(function() {
    var downloadsSection = $("#mvn-downloads");
    if (downloadsSection.length > 0) {
      var downloadsTemplate = $("#mvn-downloads-tmpl");
      var placeholder = $('<img src="/img/loading.gif"/>');
      var module = $('a', downloadsSection).text();
      downloadsSection.after(placeholder);
      $.get("/json/meta.json", function(data) {
        var i = 0;
        for(i = 0; i < data.modules.length; i++) {
          var m = data.modules[i];
          if (m.name == module) {
            var downloadsList = $('<ul id="mvn-downloads-list"/>');
            var j = 0;
            for (j = 0; j < m.versions.length; j++) {
              var listItem = downloadsTemplate.tmpl({"module": module, "version": m.versions[j]});
              downloadsList.append(listItem);
            }
            placeholder.replaceWith(downloadsList);
          }
        }
      }, "json");
    }
  });

  // Other stuff
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


})(jQuery);
