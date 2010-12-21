
var jqueryslidemenu = {

  animateduration: {over: 200, out: 100}, //duration of slide in/ out animation, in milliseconds

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
              if ($targetul.queue().length<=1) //if 1 or less queued animations
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

//build menu with ID="slidemenu" on page:
jqueryslidemenu.buildmenu("slidemenu")