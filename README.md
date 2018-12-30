# Train Plugin - train-pcp

This plugin add support for the Puppet Enterprise Orchestrator transport to Train. This enables
you to use InSpec to connect over Puppet Enterprise's PCP transport to run Inspec tests without
needing access to SSH or WinRM on a given system, as long as they are running the PXP Agent.

In order to install and use this Train plugin you will need an Inspec installation.

## Installation

You will need InSpec v2.3 or later.

For the latest released train-pcp:
```
$ inspec plugin install train-pcp
```

To test the latest master branch of train-pcp, add this to the `Gemfile` from which InSpec is installed:
``` ruby
gem 'train-pcp', git: 'https://github.com/seanmil/train-pcp'
```

Additionally, if you wish to use PuppetDB-based Facter data for platform detection instead
of the built-in detection commands you will need a version of 'puppetdb-ruby' with patches
allowing it to auto-configure based on PE Client Tools and to use the RBAC token. This is
not required, but can speed up the InSpec start-up time by bypassing the commands required
for platform detection. The patches are here: <https://github.com/voxpupuli/puppetdb-ruby/pull/34>

## Usage

To use this transport you will need:
- A working Puppet Enterprise installation (>= 2017.x)
- A system with the PE client-tools installed and correctly configured (e.g. "puppet task" should work)
- A valid PE RBAC token (saved to (~/.puppetlabs/token)
- Rights to run the following PE Tasks:
  - bolt\_spec::shim from [puppetlabs/bolt_shim](https://forge.puppet.com/puppetlabs/bolt_shim)

You can then run:

```
$ inspec detect -t pcp://<certname>
```

Example output (for a CentOS 7 system)
```
== Platform Details

Name:      centos
Families:  redhat, linux, unix, os
Release:   7.6.1810
Arch:      x86_64

$ inspec shell -t pcp://<certname> -c 'command("echo hello").stdout'
hello
```

For PE Console integrated InSpec reports and to have all the Tasks for a given InSpec execution
run wrapped into a single Plan please see the inspec-orch plugin which complements this project
<https://github.com/seanmil/inspec-orch>.

## Configuration

The PCP transport configuration will normally be read from the PE client tools orchestrator.conf
file, as described at
[PE 2018.1 docs](https://puppet.com/docs/pe/2018.1/configuring_puppet_orchestrator.html#puppet-orchestrator-configuration-files)

If, for whatever reason, your configuration does not exist or you want/need to override it, you
can manually set the configuration in InSpec's JSON configuration file (as specified by `--json-config`).

It should have one or more of the following keys:
``` json
{
  "pcp": {
    "orchestrator_host": "master",
    "orchestrator_port": 8143,
    "cacert": "/path/to/my/ca_crt.pem",
    "token_file": "/path/to/my/token"
  }
}
```

## Security

In order to allow InSpec to correctly function, the Tasks must be able to execute arbitrary commands
as well as download arbitrary file contents. As a result, you should not grant RBAC permissions to
run the Tasks required by this plugin unless you also would grant administrative/root level access
to the user you are giving the Task permissions to.

## Limitations

The PCP-based transport is very fast, but it is not as fast as SSH (and likely WinRM) due to the
nature of the transport itself. This likely can't be fixed.

At this time the underlying library used to talk to the Orchestrator API only polls for command success
at 1 second intervals, which is far too long for most/all of the types of commands which InSpec issues.
If/when this patch <https://github.com/puppetlabs/orchestrator_client-ruby/pull/18> is merged then the
runs should go much faster, though will still never likely match SSH/WinRM for speed.

The intended use for this plugin would be in environments where - for whatever reasons - it is
simpler/easier to leverage the PCP transport than it would be to work through the SSH/WinRM credentials
or inbound SSH/WinRM network access.

## Acknowlegements

I'd like to thank the Chef folks for InSpec, an excellent system-level testing and auditing framework,
as well as great documentation on writing Train plugins and their train-local-rot13 working example.
Also, the folks at Puppet for a flexible task execution system in Puppet Enterprise with an API enabling
me to implement this crazy idea.
