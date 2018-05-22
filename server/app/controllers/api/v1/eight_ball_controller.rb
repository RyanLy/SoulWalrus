module Api::V1
  class EightBallController < ApiController

    def index
      @BALL_ANSWERS = Eightball.all.to_a
      if @BALL_ANSWERS.empty?
        Eightball.loadAnswers
        @BALL_ANSWERS = Eightball.all
      end
      render_and_log_to_db(json: {result: @BALL_ANSWERS[rand(@BALL_ANSWERS.length)]}, status: 200)
     end
  end
end
