# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider "virtualbox" do |v|
    v.name = "jenkins_master"
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.box = "ubuntu/trusty64"

  # enable access via https on host port 8443
  config.vm.network "forwarded_port", guest: 443, host: 8443

  # ssh agent support
  config.ssh.private_key_path = [ '~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa' ]
  config.ssh.forward_agent = true


  # Enable shell provisioning
  config.vm.provision :shell do |shell|
    shell.inline = <<-SCRIPT
      sudo apt-get -y install git-core puppet ruby-dev make
      sudo gem install librarian-puppet --version 1.3.0
    SCRIPT
  end
end
