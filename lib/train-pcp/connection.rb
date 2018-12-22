require 'train'

# TODO: Add PuppetDB-based facter platform detection:
# require 'train-pcp/platform'

require 'orchestrator_client'

module TrainPlugins
  module PCP
    class Connection < Train::Plugins::Transport::BaseConnection
      # TODO: We should look at pulling the platform detection from PuppetDB based on
      # Facter data, but for now the default works:
      # include TrainPlugins::PCP::Platform

      def initialize(options)
        # 'options' here is a hash, Symbol-keyed,
        # of what Train.target_config decided to do with the URI that it was
        # passed by `inspec -t` (or however the application gathered target information)
        # Some plugins might use this moment to capture credentials from the URI,
        # and the configure an underlying SDK accordingly.
        # You might also take a moment to manipulate the options.
        # Have a look at the Local, SSH, and AWS transports for ideas about what
        # you can do with the options.

        # Regardless, let the BaseConnection have a chance to configure itself.
        super(options)

        # If you need to attempt a connection to a remote system, or verify your
        # credentials, now is a good time.
        @node = options[:host]

        @pcp_options = @options.delete(:pcp) || {}

        @orch_host = @pcp_options.delete('orchestrator_host')
        @orch_port = @pcp_options.delete('orchestrator_port')
        @environment = @pcp_options.delete('environment') || 'production'
        @cacert = @pcp_options.delete('cacert')
        @token_file = @pcp_options.delete('token_file')
      end

      def file_via_connection(path)
        # TODO: We should revamp this in terms of a "download" task that grabs
        # the content and stat in terms of a Puppet Task which transfers the
        # file contents base64 encoded to protect it from encoding troubles in
        # transit.
        if os.aix?
          Train::File::Remote::Aix.new(self, path)
        elsif os.solaris?
          Train::File::Remote::Unix.new(self, path)
        elsif os[:name] == 'qnx'
          Train::File::Remote::Qnx.new(self, path)
        else
          Train::File::Remote::Linux.new(self, path)
        end
      end

      def run_command_via_connection(cmd)
        # TODO: Change this to be in terms of the 'exec' Task.
        result = invoke_task('bolt_shim::command', command: cmd)
        CommandResult.new(
          result.first['result']['stdout'],
          result.first['result']['stderr'],
          result.first['result']['exit_code'],
        )
      end

      def invoke_task(name, params = {})
        req = {
          environment: @environment,
          scope: {
            nodes: [
              @node,
            ],
          },
          task: name,
          params: params,
        }
        session.run_task(req)
      end

      def session
        return @session unless @session.nil?

        uri = if @orch_host and @orch_port
                "https://#{@orch_host}:#{@orch_port}"
              elsif @orch_host
                "https://#{@orch_host}"
              else
                nil
              end

        opts = {}
        opts['service-url'] = uri unless uri.nil?
        opts['cacert'] = @cacert unless @cacert.nil?
        opts['token-file'] = @token_file unless @token_file.nil?

        @session = OrchestratorClient.new(opts, load_files: true)
      end

      def logout
        @session = nil
      end

      def uri
        "pcp://#{@node}"
      end
    end
  end
end