module Nezu
  module Runtime
    class Worker
      def initialize(channel, queue_name = AMQ::Protocol::EMPTY_STRING, consumer = Consumer.new)
        @queue_name = queue_name
        @channel = channel
        @channel.on_error(&method(:handle_channel_exception))
        @consumer = consumer
      end

      def start
        @queue = @channel.queue(@queue_name, :exclusive => true)
        @queue.subscribe(&@consumer.method(:handle_message))
      end

      def handle_channel_exception(channel, channel_close)
        puts "Oops... a channel-level exception: code = #{channel_close.reply_code}, message = #{channel_close.reply_text}"
      end # handle_channel_exception(channel, channel_close)
    end
  end
end

