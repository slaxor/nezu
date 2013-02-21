module Nezu
  module Runtime
    class Producer
      def self.inherited(subclass)
        subclass.class_eval {cattr_accessor :queue_name} #:exchange_name?
        subclass.queue_name = ''
        subclass.queue_name << "#{configatron.amqp.queue_prefix}." unless configatron.amqp.queue_prefix.nil?
        subclass.queue_name << subclass.to_s.gsub(/::/, '.').underscore
        subclass.queue_name << ".#{configatron.amqp.queue_postfix}" unless configatron.amqp.queue_postfix.nil?
        subclass.queue_name
      end

      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def self.push!(params = {})
        conn = Bunny.new(configatron.amqp.url)
        conn.start
        ch = conn.create_channel
        q  = ch.queue(queue_name)
        #e  = ch.default_exchange
        #e.publish("Hello, everybody!", :routing_key => 'test1')
        #e.publish(params.to_json)
        q.publish(params.to_json)
        #delivery_info, metadata, payload = q.pop
        #puts "This is the message: #{payload}"
        conn.stop
      end
    end
  end
end

