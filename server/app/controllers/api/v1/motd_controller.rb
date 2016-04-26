module Api::V1
  class MotdController < ApiController
      
    def index
      @resp = Aws::DynamoDB::Client.new(
        region: 'us-east-1'
      ).scan({
        table_name: "skypecheckin"
      })
      
      render json: {result: @resp.items[0] }
     end

  end
end
