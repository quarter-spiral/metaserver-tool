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
