module Nezu
  module Runtime
    class Consumer
      def self.inherited(subclass)
        subclass.class_eval do
          cattr_accessor :queue_name
        end
      end

      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def self.to_queue_name
        if queue_name.nil? || queue_name.empty?
          queue_name = ''
          queue_name << "#{configatron.amqp.queue_prefix}." unless configatron.amqp.queue_prefix.nil?
          queue_name << self.to_s.gsub(/::/, '.').underscore
          queue_name << ".#{configatron.amqp.queue_postfix}" unless configatron.amqp.queue_postfix.nil?
        end
        puts 'self:' + self.inspect
        puts 'queue_name:' + queue_name
        queue_name
      end

      def handle_message(metadata, payload)
        params = JSON.parse(payload)
        action = params.delete('__action')
        self.send(action.to_sym, params)
      end
    end
  end
end

