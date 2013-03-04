module Nezu
  module Runtime
    class Recipient
      def self.new(q)
        Nezu::Runtime::Producer.descendants.select {|producer| producer.queue_name == q}[0] || (raise RecipientError.does_not_exist(q))
      end
    end

    class RecipientError < RuntimeError
      def self.does_not_exist(q)
        message = %Q(
          The class "#{q.classify}" doesn`t exist or is not a child of "Nezu::Runtime::Producer".
          Please create one in \"app/producers/#{q}.rb\" with the content of at least:

          class #{q.classify} < Nezu::Runtime::Producer
          end
        ).gsub(/^\s*/, '')
        self.new(message)
      end

    end
  end
end

