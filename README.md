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

Ansible role that installs, configures and runs [OpenSSH](https://www.openssh.com/): a remote login and operations tool based on the SSH protocol.

##### Supported Platforms:
```
* Debian
* Redhat(CentOS/Fedora)
* Ubuntu
```

Requirements
------------

Pre-installation of a C-compiler (any C89 or better compiler should work) as well as working installations of both zlib and libcrypto (included within LibreSSl/OpenSSL) are required.

A C compiler is generally available on the supported platforms/linux distributions by default but can be downloaded using each platforms' native package manager if necessary. Reference https://gcc.gnu.org/wiki/InstallingGCC for additional details.

Zlib version 1.1.4, 1.2.1.2 or greater is suggested (see https://zlib.net/fossils/ for released versions).

Also note that newer versions of OpenSSH require or strongly encourage a dedicated authentication account used by `sshd` for privilege separation. This is automatically managed by this role and configurable via custom user vars.

Optional
--------

OpenSSH makes use of pseudo-random number generators or prngs for various aspects of functionality, including but not limited to public-key cryptography. Some Unix variants (including Linux and OpenBSD) have a device driver, accessed through /dev/random and /dev/urandom, that provides random bits and a constant supply or pool of randomness for ssh to consume. There are also dedicated programs written like the “Entropy Gathering Daemon” or EGD (see http://www.lothar.com/tech/crypto/) which provide a similar service.

Installation of external entropy-gathering services is left upto the user but usage can be controlled by the `--with-egd-pool` argument, managed by specification of extra run args provided to this role (see <...> for details). If a prng pool is not specified, OpenSSH uses an internal entropy-gathering mechanism by default.

Role Variables
--------------
Variables are available and organized according to the following software & machine provisioning stages:
* _install_
* _config_
* _launch_

#### Install

TBD

#### Config

TBD

#### Launch

TBD

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
