module Nezu
  module Runtime
    class Producer
      extend Nezu::Runtime::Common

      def self.push!(params = {})
        conn = Bunny.new(configatron.amqp.send(Nezu.env.to_sym).url)
        conn.start
        ch = conn.create_channel
        q  = ch.queue(queue_name)
        q.publish(params.to_json, :content_type => 'application/json')
        #conn.stop
        conn.close
        #ch.close
      end
    end
  end
end

