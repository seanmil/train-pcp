require 'train-pcp/connection'

module TrainPlugins
  module PCP
    class Transport < Train.plugin(1)
      name 'pcp'

      def connection(_instance_opts = nil)
        @connection ||= TrainPlugins::PCP::Connection.new(@options)
      end
    end
  end
end
