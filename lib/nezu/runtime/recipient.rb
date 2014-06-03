module Nezu
  module Runtime
    class Recipient
      def self.new(q)
        Nezu::Runtime::Producer.descendants.select {|producer| producer.queue_name == q}[0] || (raise RecipientError.does_not_exist(q))
      end
    end

    class RecipientError < RuntimeError
      def self.does_not_exist(q)
        klass = q.sub(/^#{Nezu::Config.amqp.development.queue_prefix}./, '').sub(/.#{Nezu::Config.amqp.development.queue_postfix}$/,'').classify
        all_producers = Nezu::Runtime::Producer.descendants.inject({}) {|accu, producer| accu.merge({producer.name => producer.queue_name})}

        message = %Q(

          I couldn't find the queue "#{q}" anywhere in the producers.
          Please create one in \"app/producers/#{klass.underscore}.rb\" with the content of at least:
          -----------8<-----------8<-----------8<-----------
          class #{klass} < Nezu::Runtime::Producer
          end
          ----------->8----------->8----------->8-----------
          These are the producers i've got:


        ).gsub(/^\s*/, '')
        all_producers.each do |p,q|
          message << %Q(class: "#{p}" queue_name:  "#{q}"\n)
        end
        self.new(message)
      end

    end
  end
end

