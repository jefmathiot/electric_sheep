# Running acceptance tests

## Prerequisites

* [Vagrant 1.5+](http://www.vagrantup.com/downloads.html)
* Install the [vagrant-lxc 1.0.0+](https://github.com/fgrehm/vagrant-lxc) provider

## Launch the container

Before first run, add the base box to Vagrant:

Install `librarian-chef` and install the cookbooks used to provision the container:

```
gem install librarian-chef
librarian-chef install
```

Then start the container :

```
$ vagrant up --provider=lxc
```

The provisioner will copy the SSH public key (`~/.ssh/id_rsa.pub`) from the host to the container.
