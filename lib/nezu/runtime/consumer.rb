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
        puts "[NEZU Consumer] payload: #{payload}"
        params = JSON.parse(payload)
        action = params.delete('__action')
        reply_to = params.delete('__reply_to')
        response = self.send(action.to_sym, params)
        Nezu::Runtime::Recipient.new(reply_to).push!(response)
      end
    end
  end
end

