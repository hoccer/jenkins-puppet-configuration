jenkins-puppet-configuration
============================

## Requirements

* Ubuntu 14.04 LTS minimal install
* Valid jenkins certificate and private key (see Facter configuration below)

Provides a puppet manifest with basic modules for a Jenkins Master.

The following steps describe the initial provisioning (only). There are still several steps needed at the moment to configure Jenkins, Jetty and HAProxy. See [wiki](https://github.com/hoccer/jenkins-puppet-configuration/wiki) for documentation on system and application configuration.

Provide

## General Setup

```bash
# install git
sudo apt-get -y install git-core

# install puppet
sudo apt-get -y install puppet

# install ruby-dev
sudo apt-get install ruby-dev

# install make if not present
sudo apt-get install make

# install librarian-puppet gem instead (you might need to reopen your terminal afterwards)
sudo gem install librarian-puppet
```

## Production Setup

The following steps install all packages, dependencies and modules required (including this repository) and apply the puppet configuration. Make sure that an appropriate SSL certificate is present to clone the required repositories.

```bash
# checkout puppet provisioning repository and apply
git clone git@github.com:hoccer/hoccer-talk-puppet-configuration.git
cd hoccer-talk-puppet-configuration

# install puppet modules
librarian-puppet install --verbose

# edit configuration.sh and then execute it
source configure.sh

# apply puppet configuration
sudo -E puppet apply init.pp --no-report --modulepath modules --verbose
```

## Development Setup

The provisioning can be tested on a local VM using Vagrant as follows:

```bash
# create VM
vagrant up

# log into VM
vagrant ssh

# go to shared folder on the VM
cd /vagrant

# install puppet modules
librarian-puppet install --verbose

# edit configuration.sh and then execute it
source configure.sh

# apply puppet configuration
sudo -E puppet apply init.pp --no-report --modulepath modules --verbose
```
