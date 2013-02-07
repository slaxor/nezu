# encoding: utf-8
class Dispatcher
  def initialize(metadata, payload)
    puts metadata, payload
    debugger
    case metadata.type
    when "gems.install"
      data = YAML.load(payload)
      puts "[gems.install] Received a 'gems.install' request with #{data.inspect}"

      # just to demonstrate a realistic example
      shellout = "gem install #{data[:gem]} --version '#{data[:version]}'"
      puts "[gems.install] Executing #{shellout}"; system(shellout)

      puts
      puts "[gems.install] Done"
      puts
    else
      puts "[commands] Unknown command: #{metadata.type}"
    end

    # message is processed, acknowledge it so that broker discards it
    metadata.ack
  end
end


