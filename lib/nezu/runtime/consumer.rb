module Nezu
  module Runtime
    class Consumer
      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def self.to_queue_name
        q = ''
        q << "#{configatron.amqp.queue_prefix}." unless configatron.amqp.queue_prefix.nil?
        q << self.to_s.gsub(/::/, '.').underscore
        q << ".#{configatron.amqp.queue_postfix}" unless configatron.amqp.queue_postfix.nil?
        q
      end

      def handle_message(metadata, payload)
        params = JSON.parse(payload)
        action = params.delete('__action')
        self.send(action.to_sym, params)
      end

    end
  end
end

