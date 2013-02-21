module Nezu
  module Runtime
    class Consumer
      def self.inherited(subclass)
        subclass.class_eval {cattr_accessor :queue_name}
        subclass.queue_name = ''
        subclass.queue_name << "#{configatron.amqp.queue_prefix}." unless configatron.amqp.queue_prefix.nil?
        subclass.queue_name << subclass.to_s.gsub(/::/, '.').underscore
        subclass.queue_name << ".#{configatron.amqp.queue_postfix}" unless configatron.amqp.queue_postfix.nil?
      end

      def self.descendants
        ObjectSpace.each_object(Class).select { |klass| klass < self }
      end

      def handle_message(metadata, payload)
        params = JSON.parse(payload)
        action = params.delete('__action')
        recipient = Nezu::Runtime::Recipient.new(params.delete('__reply_to'))
        self.send(action.to_sym, params)
        recipient.push!(response)
      end
    end
  end
end


#class WebApp<Nezu::Runtime::Producer ; end

#params['__respond_to'] # talkyoo.web_aap => WebAap

#class Numberman<Nezu::Runtime::Producer ; end

#Numberman.produce!(params)

#Thread.new do
  #abbonier_irgenwelche_queues
#end

