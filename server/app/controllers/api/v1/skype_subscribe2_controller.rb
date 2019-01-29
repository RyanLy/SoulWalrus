module Api::V1
  class SkypeSubscribe2Controller < ApiController
    def index
      result = SkypeSubscribe2.all.collect
      render_and_log_to_db(json: { result: result }, status: 200)
    end

    def create
      if allowed_params['conversation']['id']
        if SkypeSubscribe2.where(convo_id: allowed_params['conversation']['id']).all.to_a.empty?
          subscriber = SkypeSubscribe2.new(allowed_params.merge(
                                             convo_id: allowed_params['conversation']['id']
                                           ))
          subscriber.save
          render_and_log_to_db(json: { result: subscriber }, status: 200)
        else
          render_and_log_to_db(json: { error: 'Chat already subscribed.' }, status: 400)
        end
      else
        render_and_log_to_db(json: { error: 'Please specify a chatid' }, status: 400)
      end
    end

    def destroy
      results = SkypeSubscribe2.where(convo_id: params['convo_id']).all
      if results.empty?
        render_and_log_to_db(json: { error: 'Subscriber not on the list.' }, status: 400)
      else
        results[0].delete
        render_and_log_to_db(json: { result: params['convo_id'] + ' unsubscribed.' }, status: 200)
      end
    end

    private

    def allowed_params
      params.permit([
                      :channelId,
                      [user: %i[id name]],
                      [conversation: [:id]],
                      [bot: %i[id name]],
                      :serviceUrl,
                      :useAuth
                    ])
    end
  end
end
