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

Optional
--------

*OpenSSH* makes use of pseudo-random number generators or *prngs* for various aspects of functionality, including but not limited to public-key cryptography. Some Unix variants (including Linux and OpenBSD) have a device driver, accessed through `/dev/random` and `/dev/urandom`, that provides random bits and a constant supply or pool of randomness for ssh to consume. There are also dedicated programs written like the **Entropy Gathering Daemon** or EGD (see http://www.lothar.com/tech/crypto/) which provide a similar service.

Installation of external entropy-gathering services is left upto the operator but usage can be controlled by the `--with-egd-pool` argument, passed to `sshd` and managed by specification of extra run args provided to this role (see <...> for details). **note:** If a prng pool is not specified, *OpenSSH* uses an internal entropy-gathering mechanism by default.

Role Variables
--------------
Variables are available and organized according to the following software & machine provisioning stages:
* _install_
* _config_
* _launch_

#### Install

`openssh`can be installed using OS package management systems provided by the supported platforms (e.g `apt`, `yum/dnf`).

_The following variables can be customized to control various aspects of this installation process, ranging from the package version and user to run the SSH service as to the automatic setup of the SSH key caching agent (`ssh-agent`):_

`service_package: <package-name-and-version>` (**default**: openssh[-latest])
- name and version of the openssh package to download and install. [Reference](http://fr2.rpmfind.net/linux/rpm2html/search.php?query=openssh) or run something like `dnf --showduplicates list openssh` in a terminal to display a list of available packages for your platform.

`openssh_user: <service-user-name>` (**default**: openssh)
- dedicated service user, group and directory used by `sshd` for privilege separation (see [README.privsep](https://github.com/openssh/openssh-portable/blob/master/README.privsep) for details)

`auto_enable_agent: <hash-of-accounts-to-enable>` (**default**: None - see `test/integration/enable_ssh_agent/default_playbook.yml` for examples)
- indicates user accounts to install and automatically enable a user-scoped instance of `ssh-agent`, managed by systemd. Hash contains `run_args` key for customization of agent launch.

 ```yaml
  auto_enable_agent:
    # user
    example-1: {}
    example-2: {}
  ```

#### Config

TBD

#### Launch

Running of both the `openssh` and `ssh-agent` daemons is accomplished utilizing the [systemd](https://www.freedesktop.org/wiki/Software/systemd/) service management tool, standard on most Linux platforms. Both can be customized to adhere to system administrative policies by using the following launch arguments:_

`extra_run_args: <sshd-cli-options>` (**default**: None)
- list of `sshd` commandline arguments to pass to the executable at runtime for customizing launch. This variable enables the role to be customized according to the operator's specification; whether to activate a particular operational mode, force use of a specific type of IPv address family or pass additional configuration values.

A list of available command-line options can be found [here](https://www.freebsd.org/cgi/man.cgi?sshd(8)).

- **e.g.** Launch the SSH daemon only accepting IPv4 addresses and also writing log output to a location besides the system log:
  ```yaml
  extra_run_args: "-4 -E /var/log/sshd.log"
  ```

`[auto_enable_agent : <account>]:run_args: <ssh-agent-cli-options>` (**default**: None)
- list of `ssh-agent` commandline arguments to modify the default behavior of individual user's SSH authentication and key caching agent. Of note, a default value for the maximum lifetime of identities added to the agent may be specified. The lifetime may be expressed in seconds or in a time format.

A list of available command-line options can be found [here](https://linux.die.net/man/1/ssh-agent).

- **e.g.** Automatically install a user-scoped ssh-agent for the *example* user and specify a maximum lifetime of cached identities of 86,400 seconds or 1 day:
  ```yaml
  auto_enable_agent:
    # user
    example:
       # arguments to pass to the ssh-agent on launch - set key TTL of 1 day
       run_args: "-t 86400"
  ```

##### Examples

TBD

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
