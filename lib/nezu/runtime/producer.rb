module Nezu
  module Runtime
    class Producer
      extend Nezu::Runtime::Common

      def self.inherited(subclass)
        super
        @@connection = Bunny.new(configatron.amqp.send(Nezu.env.to_sym).url)
        @@connection.start
        @@channel = @@connection.create_channel
      end

      def self.push!(params = {})
        @@queue  ||= @@channel.queue(queue_name)
        @@queue.publish(params.to_json, :content_type => 'application/json')
      end
    end
  end
end

