def configure_ubuntu(box)
  Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = box

    config.omnibus.chef_version = :latest
    config.vm.provider "virtualbox" do |v|
      v.name = "electric_sheep-#{box.gsub(/\//, '-')}-build"
      v.memory = 4096
      v.cpus = 2
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    end

    config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
    config.vm.provision :shell, inline: "sudo locale-gen fr_FR.UTF-8 && sudo dpkg-reconfigure locales"

    config.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = ["cookbooks"]
      chef.add_recipe "apt"
    end

    config.vm.synced_folder File.expand_path(File.join(File.dirname(__FILE__), "../../")), "/tmp/electric_sheep/"

    config.vm.provision :shell, privileged: true, inline: <<-SCRIPT
      apt-get install -y python-software-properties
      apt-add-repository ppa:brightbox/ruby-ng
      apt-get update
      apt-get install -y ruby2.1 git ruby2.1-dev ruby-dev build-essential autoconf
      gem install bundler --no-rdoc --no-ri
      gem install omnibus --no-rdoc --no-ri
      git config --global user.email "humans@electricsheep.io"
      git config --global user.name "Electric Sheep IO"
      mkdir -p /opt/electric_sheep /var/cache/omnibus
      rm -rf /var/cache/omnibus/pkg/*
      chown vagrant:vagrant /opt/electric_sheep
      chown vagrant:vagrant /var/cache/omnibus
      cd /tmp/electric_sheep/build
      bundle install
      bundle exec omnibus build electric_sheep
    SCRIPT
  end
end
