var pusher = new Pusher(process.env.PUSHER_APP_ID, {
  encrypted: true
});

var channelMotd = pusher.subscribe('motd');
var channelStreamer = pusher.subscribe('streamer');

channelMotd.bind('motd_update', function(data) {
  $("#motd").text(data.result.message);
});
channelStreamer.bind('streamer_added', function(data) {
  $("#streamers").text(data.result);
});
channelStreamer.bind('streamer_removed', function(data) {
  $("#streamers").text(data.result);
});
channelStreamer.bind('streamer_online', function(data) {
  $("#streamer-updates").text($("#streamer-updates").text() + "\n" + data.result.display_name + " Online!");
});
channelStreamer.bind('streamer_offline', function(data) {
  $("#streamer-updates").text($("#streamer-updates").text() + "\n" + data.result.display_name + " Offline!");
});

$.ajax({
  url: process.env.API_SERVER + 'motd',
  success: function(res) {
    console.log("here")
    $("#motd").text(res.result.message);
  }
});

$.ajax({
  url: process.env.API_SERVER + 'streamer',
  success: function(res) {
    $("#streamers").text(res.result);
  }
});

function eightBall() {
  $.ajax({
    url: process.env.API_SERVER + 'eight_ball',
    success: function(res) {
      $("#eight-ball-answer").text(res.result.answer + '.');
    }
  });
}
