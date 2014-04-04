jenkins-puppet-configuration
============================

Provides a puppet manifest with basic modules for a jenkins master. Additional manual steps are currently necessary for complete setup. See: todo

#### Requirements

* Ubuntu 14.04 LTS minimal install
* extra packages
```
git puppet
```

Prepare Puppet modules:
```
cd modules
git clone https://github.com/hoccer/puppet-backuppc-client.git backuppc-client
git clone https://github.com/hoccer/puppet-deployment-user.git deployment-user
git clone https://github.com/hoccer/puppet-nrpe.git nrpe
```

Apply Puppet configuration:

```
puppet apply --no-report --modulepath ~/puppet/modules ~/puppet/jenkins.pp --verbose
```