# Running acceptance tests

## Prerequisites

* [Vagrant](http://www.vagrantup.com/downloads.html)
* Install the [vagrant-lxc](https://github.com/fgrehm/vagrant-lxc) provider

## Launch the container

Before first run, add the base box to Vagrant :

```
$ vagrant box init lxc-precise64 http://bit.ly/vagrant-lxc-precise64-2013-10-23
```

Then start the container :

```
$ vagrant up --provider=lxc
```

The provisioner will copy the SSH public key (`~/.ssh/id_rsa.pub`) from the host to the container.
