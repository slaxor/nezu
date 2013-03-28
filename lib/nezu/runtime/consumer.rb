module Nezu
  module Runtime
    class Consumer
      extend Nezu::Runtime::Common

      def handle_message(metadata, payload)
        Nezu.logger.debug("NEZU Consumer[#{self.class}] payload: #{payload}")
        params = JSON.parse(payload.to_s)
        action = params.delete('__action')
        reply_to = params['__reply_to']
        result = self.send(action.to_sym, params)
        if reply_to
          result.reverse_merge!('__action' => "#{action}_result")
          recipient = Nezu::Runtime::Recipient.new(reply_to)
          Nezu.logger.debug("sending result #{result}of #{action} to #{recipient}")
          recipient.push!(result)
        end
      rescue JSON::ParserError => e
        Nezu.logger.error('Please send only json in the message body')
        Nezu.logger.debug(e)
      rescue NoMethodError => e
        Nezu.logger.error(e)
      end
    end
  end
end

