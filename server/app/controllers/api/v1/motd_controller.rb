module Api::V1
  class MotdController < ApiController
    def index
      motds = Motd.all.to_a
      if motds.empty?
        render_and_log_to_db(json: { error: 'No data' }, status: 400)
      else
        render_and_log_to_db(json: { result: motds[0] }, status: 200)
      end
    end

    def update
      if params[:message]
        motds = Motd.all.to_a
        motd = if motds.empty?
                 Motd.new
               else
                 motds[0]
               end
        motd[:message] = params[:message]
        motd[:submitted_by] = params[:submitted_by]
        motd.save
        Pusher.trigger('motd', 'motd_update',
                       result: motd)
        render_and_log_to_db(json: { result: motd }, status: 200)
      else
        render_and_log_to_db(json: { error: 'Please specify a message' }, status: 400)
      end
    end
  end
end
