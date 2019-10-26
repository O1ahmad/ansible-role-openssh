Ansible Role :closed_lock_with_key: OpenSSH
=========
[![Galaxy Role](https://img.shields.io/ansible/role/41457.svg)](https://galaxy.ansible.com/0x0I/openssh)
[![Downloads](https://img.shields.io/ansible/role/d/41457.svg)](https://galaxy.ansible.com/0x0I/openssh)
[![Build Status](https://travis-ci.org/0x0I/ansible-role-openssh.svg?branch=master)](https://travis-ci.org/0x0I/ansible-role-openssh)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**
  - [Supported Platforms](#supported-platforms)
  - [Requirements](#requirements)
  - [Role Variables](#role-variables)
      - [Install](#install)
      - [Config](#config)
      - [Launch](#launch)
  - [Dependencies](#dependencies)
  - [Example Playbook](#example-playbook)
  - [License](#license)
  - [Author Information](#author-information)
<!-- END doctoc generated TOC please keep comment here to allow auto update -->

Ansible role that installs, configures and runs [OpenSSH](https://www.openssh.com/): a remote login and operations tool based on the **SSH protocol**.

##### Supported Platforms:
```
* Debian
* Redhat(CentOS/Fedora)
* Ubuntu
```

Requirements
------------

Pre-installation of a C-compiler (any C89 or better compiler should work) as well as working installations of both the **zlib** and **libcrypto** libraries (included within *LibreSSl/OpenSSL*) are required. A C compiler is generally available on supported platforms/linux distributions by default but can be downloaded using each platforms' native package manager if necessary. Reference https://gcc.gnu.org/wiki/InstallingGCC for additional details.

**Zlib** version 1.1.4, 1.2.1.2 or greater is suggested (see https://zlib.net/fossils/ for released versions).

Also note that newer versions of *OpenSSH* require or strongly encourage a dedicated authentication account used by `sshd` for privilege separation. This is automatically managed by this role and configurable via custom operator vars.

Role Variables
--------------
Variables are available and organized according to the following software & machine provisioning stages:
* _install_
* _config_
* _launch_

#### Install

`openssh`can be installed using OS package management systems provided by the supported platforms (e.g `apt`, `yum/dnf`).

_The following variables can be customized to control various aspects of this installation process, ranging from the package version and user to run the SSH service as to the automatic setup of an SSH key caching agent (`ssh-agent`):_

`service_package: <package-name-and-version>` (**default**: *openssh*[-latest])
- name and version of the openssh package to download and install. [Reference](http://fr2.rpmfind.net/linux/rpm2html/search.php?query=openssh) or run something like `dnf --showduplicates list openssh` in a terminal to display a list of available packages for your platform.

`openssh_user: <service-user-name>` (**default**: *openssh*)
- dedicated service user, group and directory used by `sshd` for privilege separation (see [README.privsep](https://github.com/openssh/openssh-portable/blob/master/README.privsep) for details)

`auto_enable_agent: <hash-of-accounts-to-enable>` (**default**: *None* - see `test/integration/enable_ssh_agent/default_playbook.yml` for examples)
- indicates user accounts to install and automatically enable a user-scoped instance of `ssh-agent`, managed by systemd. Hash contains `run_args` key for customization of agent launch.

##### Example

 ```yaml
  auto_enable_agent:
    # users
    example-1: {}
    example-2:
       # launch ssh-agent in debug mode with key TTL of 1 hour
       run_args: "-d -t 3600"
  ```

#### Config

Using this role, configuration of `openssh` is organized according to the following components:

* _service config (`sshd_config`)_
* _client config (`ssh_config`)_
* _known hosts (`ssh_known_hosts #global` and `known_hosts #per-user`)_
* _authorized keys (`authorized_keys`)_
* _user identities (e.g. `id_rsa #private-key` and `id_rsa.pub #public-key`)

Each configuration can be expressed within a hash, keyed by user account where appropriate. The value of these user account keys are generally dicts representing config specifications (e.g. an entry in a user's authorized_keys file granting access to the local account for a particular key) containing a set of key-value pairs representing associated settings for each component. The following provides an overview and example configurations for reference.

_SSH daemon configuration values are defined under `config.service` and describe a service config specification to be rendered at the appropriate location (i.e. `/etc/ssh/sshd_config`):_

`[config:] service : <key: value,...>` (**default**: see `defaults/main.yml`)
- a list of available command-line options can be found [here](https://man.openbsd.org/sshd_config).

##### Example

 ```yaml
  config:
    service:
      # disable password and challenge-response authentication methods and enable Public-Key auth *ONLY*
      PasswordAuthentication: "no"
      ChallengeResponseAuthentication: "no"
      PubKeyAuthentication: "yes"
  ```
  
  _SSH client configuration values are defined under `config.client` and describe client config specifications, from both a global and per-user scope, to be rendered at the appropriate locations (i.e. `/etc/ssh/ssh_config # global` and `~/.ssh/config` # per-user). Of note, each specification contains a keyword attribute to describe whether the config is anchored on a `Host (default)` or `Match` basis:_
  
`[config:] client : <global | user-account> : keyword : <Host | Match>` (**default**: *Host*)
- entry match basis (reference [here](https://man.openbsd.org/sshd_config) for more details).
  
`[config:] client : <global | user-account> : options : <key: value,...>` (**default**: see `defaults/main.yml`)
- a list of available command-line options can be found [here](https://man.openbsd.org/sshd_config).

##### Example

 ```yaml
  config:
    client:
        # system-wide settings
        global:
          '*':
            options:
              # disable auto add and forwarding of user keys by an `ssh-agent`
              AddKeysToAgent: 'no'
              ForwardAgent: 'no'
              IdentityFile: '~/.ssh/secureId_rsa'
        # custom settings for user-account-1 
        user-account-1:
          # add and forward keys and user 
          'host "dev-user.dev.com"':
            keyword: "Match"
            options:
              AddKeysToAgent: 'yes'
              ForwardAgent: 'yes'
              IdentityFile: '~/.ssh/test_rsa'
        user-account-2:
          '*.prod.com':
            keyword: "Match"
            options:
              AddKeysToAgent: 'no'
              ForwardAgent: 'no'
              IdentityFile: '~/.ssh/test_rsa'
  ```

#### Launch

Execution of both the `openssh` and `ssh-agent` daemons is accomplished utilizing the [systemd](https://www.freedesktop.org/wiki/Software/systemd/) service management tool, standard on most Linux platforms. Both can be customized to adhere to system administrative policies by using the following launch arguments:_

`extra_run_args: <sshd-cli-options>` (**default**: None)
- list of `sshd` commandline arguments to pass to the executable at runtime for customizing launch. This variable enables the role to be customized according to the operator's specification; whether to activate a particular operational mode, force use of a specific type of IPv address family or pass additional configuration values.

A list of available command-line options can be found [here](https://www.freebsd.org/cgi/man.cgi?sshd(8)).

##### Example
  
```yaml
# Launch the SSH daemon only accepting IPv4 addresses and also writing log output to a location besides the system log
extra_run_args: "-4 -E /var/log/sshd.log"
```

`[auto_enable_agent : <account>]:run_args: <ssh-agent-cli-options>` (**default**: *None*)
- list of `ssh-agent` commandline arguments to modify the default behavior of individual user's SSH authentication and key caching agent. Of note, a default value for the maximum lifetime of identities added to the agent may be specified. The lifetime may be expressed in seconds or in a time format.

A list of available command-line options can be found [here](https://linux.die.net/man/1/ssh-agent).

##### Example

  ```yaml
  auto_enable_agent:
    # user
    example:
       # automatically install a user-scoped ssh-agent for the *example* user and specify
       # a maximum lifetime for cached identities of 86,400 seconds (or 1 day):
       run_args: "-t 86400"
  ```

Dependencies
------------

None

Example Playbook
----------------

TBD

License
-------

Apache, BSD, MIT

Author Information
------------------

This role was created in 2019 by O1 Labs.
