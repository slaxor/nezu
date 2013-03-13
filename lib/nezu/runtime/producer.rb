module Nezu
  module Runtime
    class Producer
      def self.inherited(subclass)
        subclass.class_eval {cattr_accessor :queue_name} #:exchange_name?
        subclass.queue_name = ''
        subclass.queue_name << "#{configatron.amqp.send(Nezu.env.to_sym).queue_prefix}." unless configatron.amqp.send(Nezu.env.to_sym).queue_prefix.nil?
        subclass.queue_name << subclass.to_s.gsub(/::/, '.').underscore
        subclass.queue_name << ".#{configatron.amqp.send(Nezu.env.to_sym).queue_postfix}" unless configatron.amqp.send(Nezu.env.to_sym).queue_postfix.nil?
        subclass.queue_name
      end

      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def self.push!(params = {})
        conn = Bunny.new(configatron.amqp.send(Nezu.env.to_sym).url)
        conn.start
        ch = conn.create_channel
        q  = ch.queue(queue_name)
        q.publish(params.to_json, :content_type => 'application/json')
        conn.stop
      end
    end
  end
end

