$.ajax({
  url: process.env.API_SERVER + 'motd',
  success: function(res) {
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
