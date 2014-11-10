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
sudo gem install librarian-puppet --version 1.3.0

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

## Extend Java Security

Hoccer uses the PKCS7Padding for encryption which is not supported by Java on many platforms (Android supports it). If it is not supported you will get a `java.security.NoSuchAlgorithmException: Cannot find any provider supporting AES/CBC/PKCS7Padding`.

Its necessary to alter the Java security policy to support this padding as described below.

### Download and replace Java security policy file

1. Download the _Java Cryptography Extension (JCE) Unlimited Strength Jurisdiction Policy Files 7_  from [here] (http://www.oracle.com/technetwork/java/javase/downloads/jce-7-download-432124.html)
2. Unpack the archive
3. Overwrite the existing `local_policy.jar`as follows:
  * Locally:```sudo cp ~/Downloads/UnlimitedJCEPolicy/local_policy.jar $JAVA_HOME/jre/lib/security```
  * Or on a remote server/vm:
    1. Copy file to remote device:
      * E.g. to Vagrant Box: ```scp -P 2222 ~/Downloads/UnlimitedJCEPolicy/local_policy.jar vagrant@127.0.0.1:/tmp```
      * E.g. to build1 server: ```scp ~/Downloads/UnlimitedJCEPolicy/local_policy.jar deployment@build1.hoccer.de:/tmp```
    1. Replace the policy file on remote device:```sudo cp /tmp/local_policy.jar /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security```

### Install Bouncycastle as security provider in the JRE
* Locally:
  * Download http://mirrors.ibiblio.org/maven2/org/bouncycastle/bcprov-jdk15on/1.48/bcprov-jdk15on-1.48.jar to `$JAVA_HOME/jre/lib/ext` and make sure that the rights are correct (`chmod 664` on OS X).
* Or on a remote server/vm:
  * Download via:```sudo wget http://mirrors.ibiblio.org/maven2/org/bouncycastle/bcprov-jdk15on/1.48/bcprov-jdk15on-1.48.jar --directory-prefix /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/ext```

Edit the java security file via ```sudo vi /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/java.security```and append the following line to the section `List of providers and their preference orders`:

```security.provider.N=org.bouncycastle.jce.provider.BouncyCastleProvider```

where `N` is an increment to the biggest number currently present.

## Jenkins Server Migration

Jenkins is quiet portable and contains nearly all its data in ```/var/lib/jenkins/```.

One exception are user login information which have been stored in the Jenkins´ own database.
Therefore logging in with a "previous" account won´t work. To disable authentication completely set ```<useSecurity>false</useSecurity>``` in ```/var/lib/jenks/config.xml``` and remove the ```<authorizationStrategy>...</authorizationStrategy>``` node.
After restarting Jenkins (via ```sudo service jetty restart```) you should be able to access the Jenkins website as anonymous user with full permissions.
