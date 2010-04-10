document.onkeydown = NavigateThrough;

function NavigateThrough (event) {
  if (!document.getElementById) return;
  if (window.event) event = window.event;
  if (event.ctrlKey) {
    var link = null;
    var href = null;
    switch (event.keyCode ? event.keyCode : event.which ? event.which : null) {
      case 0x45:
        link = document.getElementById ('edit-link');
        break;
    }

    if (link && link.href) document.location = link.href;
    if (href) document.location = href;
  }
}

function ctrlEnterSubmit(e, form) {
  if (((e.keyCode == 13) || (e.keyCode == 10)) && (e.ctrlKey == true)) form.submit();
}
