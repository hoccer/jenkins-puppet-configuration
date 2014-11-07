jenkins-puppet-configuration
============================

Provides a puppet manifest with basic modules for a Jenkins Master.

Following the steps below all packages, dependencies and modules required (including this repository) are downloaded and applied using _puppet apply_. Make sure that an appropriate SSL certificate is present to clone the required repositories from GitHub. This can be achieved by installing one manually or by using ssh [agent forwarding](https://help.github.com/articles/using-ssh-agent-forwarding). For the latter you might need to make your key available via `ssh-add -K` first.

Checkout the [wiki](https://github.com/hoccer/jenkins-puppet-configuration/wiki) for documentation on system and application configuration.

## Requirements

* Ubuntu 14.04 LTS minimal install
* Valid jenkins certificate and private key (see Facter configuration below)

## Production Setup

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
sudo gem install librarian-puppet --version 1.4.0

# checkout puppet provisioning repository and apply
git clone git@github.com:hoccer/jenkins-puppet-configuration.git
cd jenkins-puppet-configuration

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

# you should now be able to access the jenkins web interface from your host system at https://127.0.0.1:8443
```

## Jenkins Server Migration

Jenkins is quiet portable and contains nearly all its data in ```/var/lib/jenkins/```.

One exception are user login information which have been stored in the Jenkins´ own database.
Therefore logging in with a "previous" account won´t work. To disable authentication completely set ```<useSecurity>false</useSecurity>``` in ```/var/lib/jenks/config.xml``` and remove the ```<authorizationStrategy>...</authorizationStrategy>``` node.
After restarting Jenkins (via ```sudo service jetty restart```) you should be able to access the Jenkins website as anonymous user with full permissions.
