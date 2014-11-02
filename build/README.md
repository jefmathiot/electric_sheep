# Electric Sheep IO - Package builds

## Prerequisites

* You must have a sane Ruby 1.9+ environment with librarian-chef installed
* Vagrant 1.5+ and VirtualBox

## Build packages

Packages are built in the `pkg` directory.

## Build a single package

Cd to the platform-specific folder (i.e. vagrant/ubuntu32 ), install the cookbooks and spin up / halt a VM :

```shell
vagrant up --provision && vagrant halt
```

## Build all packages

```shell
./build-all.sh
```

## Install the packages

### Ubuntu / Debian

```shell
dpkg -i electric_sheep_0.1.0-1_amd64.deb
```
or

```shell
dpkg -i electric_sheep_0.1.0-1_i386.deb
```
