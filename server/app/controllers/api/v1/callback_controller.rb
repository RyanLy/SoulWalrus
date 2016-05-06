# Used to accept callbacks from external services

module Api::V1
  class CallbackController < ApiController
    def index
        render_and_log_to_db(json: {result: params }, status: 200)
    end
  end
end
