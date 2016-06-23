# Running acceptance tests

## Prerequisites

* Ruby 2.3.0+
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

## Execute the tests

Head back to the project's root directory and:

`bundle exec cucumber --tags ~@pending`
