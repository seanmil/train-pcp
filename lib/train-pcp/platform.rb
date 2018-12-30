module TrainPlugins::PCP
  module Platform
    def platform
      return @platform unless @platform.nil?

      begin
        require 'puppetdb'
      rescue LoadError
        logger.debug('[PCP] Skipping PuppetDB-based platform detection, "gem install puppetdb-ruby" to enable.')
        nil
      end

      p = begin
            PuppetDB::Client.new()
          rescue NameError
            nil

          # If the 'puppetdb-ruby' version is too old and does not support auto-detection then it will
          # raise an ArgumentError:
          rescue ArgumentError
            logger.debug('[PCP] Skipping PuppetDB-based platform detection, "puppetdb-ruby" too old.')
            nil
          end

      if p.nil?
        logger.debug('[PCP] Using standard OS-based platform detection.')
        return @platform ||= super()
      end

      resp = p.request('', "facts { certname = '#{node}' and name = 'os' }")

      if resp.data.first.nil?
        logger.debug("[PCP] No facts found for #{node}, using standard OS-based platform detection.")
        return @platform ||= super()
      end

      os = resp.data.first['value']

      value = {}
      value[:release] = os['release']['full']
      value[:arch] = os['architecture']

      # We have to match the platform names from Train::Platforms::Detect::Specifications::OS
      # the families will be auto-supplied by the hierarchies setup in that class, which were
      # pre-loaded in the base plugin class.
      name = case os['name'].downcase
             when 'oraclelinux'
               'oracle'
             when 'sles'
               'suse'
             when 'darwin'
               if os.has_key?('macosx')
                 'mac_os_x'
               else
                 'darwin'
               end
             else
               os['name'].downcase
             end

      platform = force_platform!(name, value)

      if platform
        logger.debug('[PCP] Platform detection found match via PuppetDB, using it.')
        @platform = platform
      else
        logger.debug('[PCP] Platform detection found no match via PuppetDB, falling back to normal method.')
        @platform = super()
      end

      return @platform
    end
  end
end
