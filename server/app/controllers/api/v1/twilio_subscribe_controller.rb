module Api::V1
  class TwilioSubscribeController < ApiController

    @@TWILIO_CLIENT = Twilio::REST::Client.new
    @@TWILIO_LOOKUP = Twilio::REST::LookupsClient.new

    def index
      result = @@TWILIO_CLIENT.outgoing_caller_ids.list.collect { |x| x.phone_number }.sort
      render_and_log_to_db(json: {result: result}, status: 200)
    end

    # def create
    #   if params['number']
    #     #begin
    #       response = @@TWILIO_LOOKUP.phone_numbers.get(params['number'])
    #       valid_number = response.phone_number
    #       if TwilioSubscribe.where(:number => valid_number).all.empty?
    #         subscriber = TwilioSubscribe.new(
    #           :number => valid_number,
    #           :submitted_by => params['submitted_by'],
    #           :valid => true,
    #         )
    #         callerId = @@TWILIO_CLIENT.outgoing_caller_ids.add(valid_number);
    #         subscriber.save
    #         render_and_log_to_db(json: {result: subscriber}, status: 200)
    #       else
    #         render_and_log_to_db(json: {error: 'Number already subscribed.'}, status: 400)
    #       end
    #     # rescue => e
    #     #   render_and_log_to_db(json: {error: 'Please specify a valid number'}, status: 400)
    #     # end
    #   else
    #     render_and_log_to_db(json: {error: 'Please specify a valid number'}, status: 400)
    #   end
    # end
    # 
    # def destroy
    #   results = TwilioSubscribe.where(:number => params['number']).all
    #   if results.empty?
    #     render_and_log_to_db(json: {error:  'Number not on the list.'}, status: 400)
    #   else
    #     results[0].delete
    #     render_and_log_to_db(json: {result:  params['number'] +  ' unsubscribed.'}, status: 200)
    #   end
    # end
  end
end
