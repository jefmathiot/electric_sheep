# Electric Sheep IO - Package builds

## Prerequisites

* A 64bits Linux OS,
* You must have a sane Ruby 1.9+ environment
* ~~Vagrant 1.5+ and VirtualBox~~
* Docker 1.8

## Build packages

Packages are built in the `pkg` directory.

## Build all packages

```shell
./build-all.sh
```

## Install the packages

### Ubuntu / Debian

```shell
dpkg -i electric_sheep_${VERSION}-1_amd64.deb
```
or

```shell
dpkg -i electric_sheep_${VERSION}-1_i386.deb
```
