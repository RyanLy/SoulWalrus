module Api::V1
  class ApiController < ApplicationController
    # Generic API stuff here

    def render_and_log_to_db(result)
      Log.new(
        controller: params['controller'],
        action: params['action'],
        params: params,
        result: result
      ).save
      render(result)
    end
  end
end
