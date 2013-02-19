module Nezu
  module Runtime
    class Consumer
      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def self.to_queue_name
        q = ''
        q << "#{configatron.amqp.queue_prefix}." if configatron.amqp.queue_prefix
        q << self.to_s.gsub(/::/, '.').underscore
        q << ".#{configatron.amqp.queue_postfix}" if configatron.amqp.queue_postfix
      end

      def handle_message(metadata, payload)
        params = JSON.parse(payload)
        action = params.delete('__action')
        self.send(action.to_sym, params)
      end

    end
  end
end

