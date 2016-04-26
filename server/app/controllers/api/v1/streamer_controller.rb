module Api::V1
  class StreamerController < ApiController
      
    def index
      @resp = Aws::DynamoDB::Client.new(
        region: 'us-east-1'
      ).scan({
        table_name: "streamers"
      })
      
      render json: {result: @resp.items.collect { |x| x['display_name'] }.sort }
     end
  end
end
