module Nezu
  module Runtime
    class Producer
      extend Nezu::Runtime::Common

      def self.push!(params = {})
        connection = Bunny.new(Nezu::Config.amqp[Nezu.env.to_sym].url, :threaded => false)
        connection.start
        channel = connection.create_channel
        queue ||= channel.queue(queue_name)
        queue.publish(params.to_json, :content_type => 'application/json')
        connection.close
      end
    end
  end
end

