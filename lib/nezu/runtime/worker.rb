module Nezu
  module Runtime
    class Worker
      def initialize(channel, consumer = Consumer.new)
        @queue_name = consumer.class.queue_name
        puts "queue name: #{@queue_name}"
        @channel = channel
        @channel.on_error(&method(:handle_channel_exception))
        @consumer = consumer
      end

      def start
        puts "[Nezu Worker] #{@queue_name}"
        @queue = @channel.queue(@queue_name, :exclusive => false)
        @queue.subscribe(&@consumer.method(:handle_message))
      end

      def handle_channel_exception(channel, channel_close)
        puts "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
      end # handle_channel_exception(channel, channel_close)
    end
  end
end

