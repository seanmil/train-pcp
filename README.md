# Train Plugin - train-pcp

This plugin add support for the Puppet Enterprise Orchestrator transport to Train. This enables
you to use InSpec to connect over Puppet Enterprise's PCP transport to run Inspec tests without
needing access to SSH or WinRM on a given system, as long as they are running the PXP Agent.

In order to install and use this Train plugin you will need an Inspec installation.

## Installation

You will need InSpec v2.3 or later.

```
$ inspec plugin install train-pcp
```

## Usage

To use this transport you will need:
- A working Puppet Enterprise installation (>= 2017.x)
- A system with the PE client-tools installed and correctly configured (e.g. "puppet task" should work)
- A valid PE RBAC token (saved to (~/.puppetlabs/token)
- Rights to run the following PE Tasks:
  - exec (from puppetlabs/exec)
  - inspec::\* (from seanmil/inspec)

You can then run:

```
$ inspec detect -t pcp://<certname>
```

Example output (for a CentOS 7 system)
``
== Platform Details

Name:      centos
Families:  redhat, linux, unix, os
Release:   7.6.1810
Arch:      x86_64

$ inspec shell -t pcp://<certname> -c 'command("echo hello").stdout'
hello
```

## Configuration

The PCP transport configuration will normally be read from the PE client tools orchestrator.conf
file, as described at
https://puppet.com/docs/pe/2018.1/configuring_puppet_orchestrator.html#puppet-orchestrator-configuration-files

If, for whatever reason, your configuration does not exist or you want/need to override it, you
can manually set the configuration in InSpec's JSON configuration file (as specified by `--json-config`).

It should have one or more of the following keys:
```
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

The intended use for this plugin would be in environments where - for whatever reasons - it is
simpler/easier to leverage the PCP transport than it would be to work through the SSH/WinRM credentials
or inbound SSH/WinRM network access.

## Acknowlegements

I'd like to thank the Chef folks for InSpec, an excellent system-level testing and auditing framework,
as well as great documentation on writing Train plugins and their train-local-rot13 working example.
