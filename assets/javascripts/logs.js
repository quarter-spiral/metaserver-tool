if (!window.qs) {
  window.qs = {};
}
window.qs.logs = {followLogs: false};

var followLogs = function() {
  if (window.qs.logs.followLogs) {
    $("html, body").animate({ scrollTop: $(document).height() }, 500);
  }
}
setInterval(followLogs, 1000);

key('f', function(){
  window.qs.logs.followLogs = !window.qs.logs.followLogs
  var text = window.qs.logs.followLogs ? 'Now following logs' : 'Stopped to follow logs';
  $().toastmessage('showNoticeToast', text);
});

key('⌘+k, ctrl+k', function() {
  $('body pre').css('margin-top', -1 * $('body pre').height() - 20)
});

setTimeout(function() {
  $().toastmessage('showNoticeToast', 'Press f to follow the logs automatically');
  $().toastmessage('showNoticeToast', 'Press f again to stop that and scroll around freely');
}, 2000);
