module Nezu
  module Runtime
    class Consumer
      def self.inherited(subclass)
        subclass.class_eval {cattr_accessor :queue_name}
        subclass.queue_name = ''
        subclass.queue_name << "#{configatron.amqp.queue_prefix}." unless configatron.amqp.queue_prefix.nil?
        subclass.queue_name << subclass.to_s.gsub(/::/, '.').underscore
        subclass.queue_name << ".#{configatron.amqp.queue_postfix}" unless configatron.amqp.queue_postfix.nil?
      end

      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def handle_message(metadata, payload)
        Nezu::LOGGER.debug("NEZU Consumer[#{self.class}] payload: #{payload}")
        params = JSON.parse(payload.to_s)
        action = params.delete('__action')
        reply_to = params.delete('__reply_to')
        result = self.send(action.to_sym, params)
        if reply_to
          result.reverse_merge!('__action' => "#{action}_result")
          recipient = Nezu::Runtime::Recipient.new(reply_to)
          Nezu::LOGGER.debug("sending result #{result}of #{action} to #{recipient}")
          recipient.push!(result)
        end
      rescue NoMethodError => e
        Nezu::LOGGER.error(e.to_s)
        e.backtrace.each {|bt_line| Nezu::LOGGER.error(bt_line)}
      end
    end
  end
end

