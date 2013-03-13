module Nezu
  module Runtime
    class Consumer
      def self.inherited(subclass) #:nodoc:
        subclass.class_eval {cattr_accessor :queue_name}
        subclass.queue_name = ''
        subclass.queue_name << "#{configatron.amqp.send(Nezu.env.to_sym).queue_prefix}." unless configatron.amqp.send(Nezu.env.to_sym).queue_prefix.nil?
        subclass.queue_name << subclass.to_s.gsub(/::/, '.').underscore
        subclass.queue_name << ".#{configatron.amqp.send(Nezu.env.to_sym).queue_postfix}" unless configatron.amqp.send(Nezu.env.to_sym).queue_postfix.nil?
      end

      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def handle_message(metadata, payload)
        Nezu.logger.debug("NEZU Consumer[#{self.class}] payload: #{payload}")
        params = JSON.parse(payload.to_s)
        action = params.delete('__action')
        reply_to = params.delete('__reply_to')
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

