# Running acceptance tests

## Prerequisites

* [Vagrant 1.5+](http://www.vagrantup.com/downloads.html)
* VirtualBox

## Launch the container

Install `librarian-chef` and install the cookbooks used to provision the container:

```
gem install librarian-chef
librarian-chef install
```

Install the "omnibus" vagrant plugin:

```
vagrant plugin install vagrant-omnibus
```

Then start the container from the current (`acceptance`) directory:

```
$ vagrant up
```

The provisioner will copy the SSH public key (`~/.ssh/id_rsa.pub`) from the host to the container.

## Execute the tests

From the **project root** :

`cucumber`

