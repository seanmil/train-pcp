module TrainPlugins::PCP
  module Platform
    # The method `platform` is called when platform detection is
    # about to be performed.  Train core defines a sophisticated
    # system for platform detection, but for most plugins, you'll
    # only ever run on the special platform for which you are targeting.
    def platform
      # If you are declaring a new platform, you will need to tell
      # Train a bit about it.
      # If you were defining a cloud API, you should say you are a member
      # of the cloud family.

      # This plugin makes up a new platform.  Train (or rather InSpec) only
      # know how to read files on Windows and Un*x (MacOS is a kind of Un*x),
      # so we'll say we're part of those families.

      # When you know you will only ever run on your dedicated platform
      # (for example, a plugin named train-aws would only run on the AWS
      # API, which we report as the 'aws' platform).
      # force_platform! lets you bypass platform detection.
      # The options to this are not currently documented completely.

      # Use release to report a version number.  You might use the version
      # of the plugin, or a version of an important underlying SDK, or a
      # version of a remote API.
      # force_platform!('local-rot13', release: TrainPlugins::LocalRot13::VERSION)
    end
  end
end
