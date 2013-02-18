module Nezu
  module Runtime
    class Consumer
      def handle_message(metadata, payload)
        params = JSON.parse(payload)
        action = params.delete('__action')
        self.send(action.to_sym, params)
      end
    end
  end
end

