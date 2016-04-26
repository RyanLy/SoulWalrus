module Api::V1
  class EightBallController < ApiController
      
    def index
      @resp = Aws::DynamoDB::Client.new(
        region: 'us-east-1'
      ).scan({
        table_name: "eight_ball"
      })
      
      @BALL_ANSWERS = @resp.items.collect { |x| x['answer'] }

      render json: {result: @BALL_ANSWERS[rand(@BALL_ANSWERS.length)]}
     end
  end
end
