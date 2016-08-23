module Api::V1
  class SkypeSubscribeController < ApiController

    def index
      result = SkypeSubscribe.all.collect { |x| x['chatid'] }.sort
      render_and_log_to_db(json: {result: result}, status: 200)
    end

    def create
      if params['chatid']
        if SkypeSubscribe.where(:chatid => params['chatid']).all.empty?
          subscriber = SkypeSubscribe.new(
            :chatid => params['chatid'],
            :submitted_by => params['submitted_by'],
            :valid => true,
          )
          subscriber.save
          render_and_log_to_db(json: {result: subscriber}, status: 200)
        else
          render_and_log_to_db(json: {error: 'Chat already subscribed.'}, status: 400)
        end
      else
        render_and_log_to_db(json: {error: 'Please specify a chatid'}, status: 400)
      end
    end
    
    def destroy
      results = SkypeSubscribe.where(:chatid => params['chatid']).all
      if results.empty?
        render_and_log_to_db(json: {error:  'Subscriber not on the list.'}, status: 400)
      else
        results[0].delete
        render_and_log_to_db(json: {result:  params['chatid'] +  ' unsubscribed.'}, status: 200)
      end
    end
  end
end
