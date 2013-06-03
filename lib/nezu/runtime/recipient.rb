module Nezu
  module Runtime
    class Recipient
      def self.new(q)
        Nezu::Runtime::Producer.descendants.select {|producer| producer.queue_name == q}[0] || (raise RecipientError.does_not_exist(q))
      end
    end

    class RecipientError < RuntimeError
      def self.does_not_exist(q)
        klass = q.sub(/^#{configatron.amqp.development.queue_prefix}./, '').sub(/.#{configatron.amqp.development.queue_postfix}$/,'').classify
        message = %Q(
          The class "#{klass}" doesn`t exist or is not a child of "Nezu::Runtime::Producer".
          Please create one in \"app/producers/#{klass.underscore}.rb\" with the content of at least:

          class #{klass} < Nezu::Runtime::Producer
          end
        ).gsub(/^\s*/, '')
        self.new(message)
      end

    end
  end
end

