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

Pre-installation of a C-compiler (any C89 or better compiler should work) as well as working installations of both the **zlib** and **libcrypto** libraries (included within *LibreSSl/OpenSSL*) are required. A C compiler is generally available on supported platforms/linux distributions by default but can be downloaded using each platforms' native package manager if necessary. [Reference](https://gcc.gnu.org/wiki/InstallingGCC) for additional details.

**Zlib** version 1.1.4, 1.2.1.2 or greater is suggested (see https://zlib.net/fossils/ for released versions).

Also note that newer versions of *OpenSSH* require or strongly encourage a dedicated authentication account used by `sshd` for privilege separation. This is automatically managed by this role and configurable via custom operator vars.

Role Variables
--------------
Variables are available and organized according to the following software & machine provisioning stages:
* _install_
* _config_
* _launch_

### Install

`openssh`can be installed using OS package management systems provided by the supported platforms (e.g `apt`, `yum/dnf`).

_The following variables can be customized to control various aspects of this installation process, ranging from the package version and user to run the SSH service as to the automatic setup of an SSH key caching agent (`ssh-agent`):_

`service_package: <package-name-and-version>` (**default**: *openssh*[-latest])
- name and version of the openssh package to download and install. [Reference](http://fr2.rpmfind.net/linux/rpm2html/search.php?query=openssh) or run something like `dnf --showduplicates list openssh` in a terminal to display a list of available packages for your platform.

`openssh_user: <service-user-name>` (**default**: *openssh*)
- dedicated service user, group and directory used by `sshd` for privilege separation (see [README.privsep](https://github.com/openssh/openssh-portable/blob/master/README.privsep) for details)

`auto_enable_agent: <hash-of-accounts-to-enable>` (**default**: *None*)
- indicates user accounts to install and automatically enable a user-scoped instance of `ssh-agent`, managed by systemd. Hash contains `run_args` key for customization of agent launch.

#### Example

 ```yaml
  auto_enable_agent:
    # users
    example-1: {}
    example-2:
       # launch ssh-agent in debug mode with key TTL of 1 hour
       run_args: "-d -t 3600"
  ```

### Config

Using this role, configuration of `openssh` is organized according to the following components:

* service (`sshd_config`)
* client (`ssh_config`)
* known hosts (`ssh_known_hosts #global` and `known_hosts #per-user`)
* authorized keys (`authorized_keys`)
* user identities (e.g. `id_rsa #private-key` and `id_rsa.pub #public-key`)

Each configuration can be expressed within a hash, keyed by user account where appropriate. The value of these user account keys are generally dicts representing config specifications (e.g. an entry in a user's authorized_keys file granting access to the local account for a particular key) containing a set of key-value pairs representing associated settings for each component. The following provides an overview and example configurations for reference.

#### Service

**_SSH daemon configuration values are defined under `ssh_config.service` and describe a service config specification to be rendered at the appropriate location (i.e. `/etc/ssh/sshd_config`):_**

`[ssh_config:] service: <key: value,...>` (**default**: see `defaults/main.yml`)
- a list of available command-line options can be found [here](https://man.openbsd.org/sshd_config).

##### Example

 ```yaml
  ssh_config:
    service:
      # disable password and challenge-response authentication methods and enable Public-Key auth *ONLY*
      PasswordAuthentication: "no"
      ChallengeResponseAuthentication: "no"
      PubKeyAuthentication: "yes"
  ```
  
#### Client

**SSH client configuration values are defined under `ssh_config.client` and describe client config specifications, from both a global and per-user scope, to be rendered at the appropriate locations (i.e. `/etc/ssh/ssh_config # global` and `~/.ssh/config` # per-user)**

*** Of note, each specification contains a keyword attribute to describe whether the config is anchored on a `Host (default)` or `Match` basis: ***
  
`[ssh_config: client : {global | user-account} :] keyword: <Host | Match>` (**default**: *Host*)
- entry match basis (reference [here](https://man.openbsd.org/sshd_config) for more details).
  
`[ssh_config: client : {global | user-account} :] options: <key: value,...>` (**default**: see `defaults/main.yml`)
- a list of available command-line options can be found [here](https://man.openbsd.org/ssh_config).

##### Example

 ```yaml
  ssh_config:
    client:
        # system-wide settings
        global:
          '*':
            options:
              # disable auto add and forwarding of user keys by an `ssh-agent`
              AddKeysToAgent: 'no'
              ForwardAgent: 'no'
        # custom settings for user-account-1 
        user-account-1:
          # add and forward keys on connections to machines with hostnames matching the dev domain
          'host "dev-user.dev.net"':
            keyword: "Match"
            options:
              AddKeysToAgent: 'yes'
              ForwardAgent: 'yes'
        user-account-2:
          # connect to hosts in test domain using designated test key and execute custom command on connection
          '*.test.net':
            keyword: "Host"
            options:
              LocalCommand: '~/test/show_test_results'
              IdentityFile: '~/.ssh/test_rsa'
        user-account-3:
          # default keyword of 'Host'
          # also silence ssh client logging and use designated production key
          '*.prod.com':
            options:
              LogLevel: "QUIET"
              IdentityFile: '~/.ssh/prod_rsa'
  ```
  
#### Known Hosts

**Like the SSH client configuration, SSH known hosts are configured based on both a global and per-user scope. Each type of config specification is defined under `ssh_config.known_hosts` and will be rendered at the appropriate locations (i.e. `/etc/ssh/ssh_known_hosts # global` and `~/.ssh/known_hosts` # per-user) accordingly.**

*** Each specification contains several attributes detailing `markers` and `hostname` patterns associated with and accepted on behalf of the specified (host) `key`. [Reference](https://man.openbsd.org/sshd#SSH_KNOWN_HOSTS_FILE_FORMAT) for more details ***
  
`[ssh_config: known_hosts : {global | user-account} : {entry} :] marker: <@cert-authority | @revoke>` (**default**: *None*)
- indicates that the line contains either a certification authority (@cert-authority) key or “@revoked” to indicate that the key contained on the line is revoked and must not ever be accepted
  
`[ssh_config: known_hosts : {global | user-account} : {entry} :] hostnames: <list of patterns>` (**default**: *None*)
- list of comma-separated patterns matched against hostnames to verify known identity

`[ssh_config: known_hosts : {global | user-account} : {entry} :] key: <host-pub-key>` (**default**:*None*)
- cryptographic public host key representing proof of authenticity for host being connected to

Cryptographic keys included can be expressed in several formats:
* _string - key definition containing: key-type, encoded key and additional comments_
* _file - local path on controller to file containing keydefinition_
* _hash - dict containing separate keys for key definition components ({type:...,encoding:...,comments:...})_

##### Example

 ```yaml
  ssh_config:
    known_hosts:
        # system-wide settings
        global:
          "Revoke ALL evil hosts":
            hostnames:
              - "*.evil.org"
            # key expressed string
            key: "ssh-rsa @k3y..."
            # mark for revocation
            marker: "@revoked"
        user-account-1:
          # add and forward keys on connections to machines with hostnames matching the dev domain
          'Certified Authorities':
            hostnames:
              # host name stored in hash form
              - "|1|JfKTdBh7rNbXkVAQCRp4OQoPfmI=|USECr3SWf1JUPsms5AqfD5QfxkM="
              - "certified.net,*.mydomain.org,*.mydomain.com"
            # host key read from file
            key: "/etc/ssh/cert_auth_host_rsa.pub"
            # mark line contains a certification authority
            marker: "@cert-authority"
        user-account-2:
          'Organization network':
            hostnames:
              - "10.0.*.*"
              - "*.example.org"
              # negate access from known compromised network
              - "!*compromised.org"
            key:
              type: "ssh-rsa"
              encoding: "th!s!s@HoSTk3y"
              comments: "Known host key"
  ```

#### Authorized Keys

**SSH authorized keys are configured on a per-user basis only. Each key specification is defined under `ssh_config.authorized_keys` and rendered at the appropriate location under the specified user's local SSH directory (i.e. `~/.ssh/authorized_keys`).**

*** Each entry contains several attributes detailing an`(authorized_)key` and `options` to associate with connection requests based on that key. [Reference](https://man.openbsd.org/sshd#AUTHORIZED_KEYS_FILE_FORMAT) for more details***
  
`[ssh_config : authorized_keys : {user-account} : {entry}:] key: <pub-key>` (**default**: *None*)
- cryptographic public key representing proof of authenticity for client's connecting to the target user account

As with the *known_hosts* configuration above, authorized keys included can be expressed in several formats:
* _string - key definition containing: key-type, encoded key and additional comments_
* _file - local path on controller to file containing keydefinition_
* _hash - dict containing separate keys for key definition components ({type:...,encoding:...,comments:...})_
  
`[ssh_config : authorized_keys : {user-account} : {entry} :] options : <list of options>` (**default**: *None*)
- list of options to apply to connections

##### Example

 ```yaml
  ssh_config:
    authorized_keys:
        user-account-1:
          "Basic Connection w/ no custom options":
            key:
              type: "ssh-rsa"
              encoding: "th!s !s @ k3y"
              comments: "these are the key comments"
          "Backup home directory":
            options:
              - "command='dump /home/user-account-1'"
              - no-pty
              - no-port-forwarding
            key: "/home/user-account/.ssh/home_dump.pub"
  ```
#### User Identities

** Use the `user_identities` configuration object to manage cryptographic public and private key pairs owned by various users throughout a network. This functionality allows for the copying of both public and private keys into their respective locations for user-host/account access across administrated machines (i.e. `~/.ssh/`). Each identity specification is defined under `ssh_config.user_identities` and expects keys and paths relative to the controller machine's filesystem.**

*** Due to the sensitive and precise nature of handling user identities, keys are only copied from files as is to target machine. [Reference](https://www.ssh.com/ssh/identity-key) for further reading***
  
`[ssh_config : user_identities : {user-account} :] src: <key-file-path>` (**default**: *None*)
- cryptographic key path located on local controller to be copied to target machine on behalf of designated *user-account*
  
`[ssh_config : user_identities : {user-account} :] dest: <key-file-name>` (**default**: *None*)
- name of key-file to be copied to on target machine

##### Example

 ```yaml
  ssh_config:
    user_identities:
        user-account-1:
          src: "/home/user-account-1/id_rsa"
          dest: "my_rsa"
  ```
  
### Launch

Execution of both the `openssh` and `ssh-agent` daemons is accomplished utilizing the [systemd](https://www.freedesktop.org/wiki/Software/systemd/) service management tool, standard on most Linux platforms. Both can be customized to adhere to system administrative policies by using the following launch arguments:_

`extra_run_args: <cli-options>` (**default**: None)
- list of `sshd` commandline arguments to pass to the executable at runtime for customizing launch. This variable enables the role to be customized according to the operator's specification; whether to activate a particular operational mode, force use of a specific type of IPv address family or pass additional configuration values.

A list of available command-line options can be found [here](https://www.freebsd.org/cgi/man.cgi?sshd(8)).

#### Example
  
```yaml
# Launch the SSH daemon only accepting IPv4 addresses and also writing log output to a location besides the system log
extra_run_args: "-4 -E /var/log/sshd.log"
```

`[auto_enable_agent : <account>]:run_args: <cli-options>` (**default**: *None*)
- list of `ssh-agent` commandline arguments to modify the default behavior of individual user's SSH authentication and key caching agent. Of note, a default value for the maximum lifetime of identities added to the agent may be specified. The lifetime may be expressed in seconds or in a time format.

A list of available command-line options can be found [here](https://linux.die.net/man/1/ssh-agent).

#### Example

  ```yaml
  auto_enable_agent:
    # user
    user-account-1:
       # automatically install a user-scoped ssh-agent for the *example* user and specify
       # a maximum lifetime for cached identities of 86,400 seconds (or 1 day):
       run_args: "-t 86400"
  ```

Dependencies
------------

None

Example Playbook
----------------

Basic setup with defaults:
```
- hosts: all
  roles:
  - role: 0xOI.openssh
```

Hardened production setup with heightened security configurations:
```
- hosts: prod
  roles:
  - role: 0xOI.openssh
    vars:
      ssh_config:
        service:
        client:
```

Custom development environment settings based on custom developer preferences:
```
- hosts: dev
  roles:
  - role: 0xOI.openssh
    vars:
      ssh_config:
        service:
        client:
        known_hosts:
        authorized_keys:
        user_identities:
```

License
-------

Apache, BSD, MIT

Author Information
------------------

This role was created in 2019 by O1 Labs.
