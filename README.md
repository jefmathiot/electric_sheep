# ElectricSheep

A simple task system for remote resources manipulation (i.e. backup).

[![Build Status](https://travis-ci.org/servebox/electric_sheep.png)](https://travis-ci.org/servebox/electric_sheep)
[![Dependency Status](https://gemnasium.com/servebox/electric_sheep.png)](https://gemnasium.com/servebox/electric_sheep)
[![Coverage Status](https://coveralls.io/repos/servebox/electric_sheep/badge.png)](https://coveralls.io/r/servebox/electric_sheep)
[![Code Climate](https://codeclimate.com/github/servebox/electric_sheep.png)](https://codeclimate.com/github/servebox/electric_sheep)

## Roadmap

Neither the API, DSL or runner are ready so far. Roadmap of features for upcoming version :

* :white_check_mark: Local and remote shells
* :clock11: Metadata API
* :clock11: Configuration DSL
* :clock11: Projects runner
* :clock11: SCP, RSYNC over SSH and Cloud Storage transports (using Fog ?)
* :clock11: Commands for directories & files backups and compression
* :clock11: Commands for popular RDBMS dumps (MySQL, Postgres)
* :clock11: Commands for popular key-value and document stores backups (Redis, Memcached, MongoDB, CouchDB)
* :clock1: Credentials encryption using public-key cryptography
* :heavy_minus_sign: Commands for archive encryption
* :heavy_minus_sign: Reporting configuration
* :heavy_minus_sign: Documentation of projects from metadata
* :heavy_minus_sign: Retention options and incremental backups
* :heavy_minus_sign: DSL alternatives to store and retrieve metadata from/to an external repository (Redis ?)
* :heavy_minus_sign: Remote-to-remote transport
* :heavy_minus_sign: Plugin system
* :heavy_minus_sign: GUI


## Installation

Requires Ruby >= 1.9.3.

Add this line to your application's Gemfile:

    gem 'electric_sheep'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install electric_sheep

## Usage

### Setup your encryption keys

TODO

### Init

TODO

### Start

Just launch ElectricSheep inside your project with:

```
bundle exec electric_sheep work
```

ElectricSheep will look for a Sheepfile in the current directory.

#### `-c` option

ElectricSheep can use any file as the configuration:

```
bundle exec electric_sheep work -c ~/Somefile
```

#### `-p` option

You can run a single project to execute:

```
bundle exec electric_sheep work -p my-project
```

## Using the DSL

### Hosts

The `host` method allows you to declare remote hosts. Each host should have a unique identifier
and define an hostname or IP address. You can declare as many hosts as needed.

```ruby
host "production-mysql-master", hostname: "mysql1.domain.tld",
  description "MySQL - Production Master" # optional

host "backup-store-1", hostname: "store1.domain.tld",
  description "Storage Server 1"
```

Please note that you don't have to declare the localhost.

### Projects

Projects allow you to logically group commands and transports to manipulate a resource locally or
on remote hosts. Each project should have a unique identifier and **declare a single resource** in
is initial state (such as a directory, a database, a file, etc.). You can declare as many projects
as needed but each of them aims to manipulate a single resource.

```ruby
project "myapp-database-backup", description: "Database Full Backup" do
  resource type: :database, name: "myapp_db", host: "production-mysql-master"
end

project "www-media-backup", description: "Acme uploads" do
  resource type: :directory, path: '/var/www/uploads'
end
```

If you omit to mention the `host` property of the resource, Electric Sheep will assume it is on
the localhost.

### Shells & Commands

Shells allow you to execute sequences of commands locally or on remote hosts. Commands are unaware
of whether they execute on a remote host or on the local host. Their role is to consume the
provided resource in its last known state (e.g. a database) and manipulate it. Each command will
provide the resource in its new state (e.g. a database dump file) so that subsequent commands or
transport can transform it again.

The `remotely` method wraps commands inside an SSH session whereas the `locally` method
executes them on the localhost.

```ruby
project "myapp-database-backup", description: "Database Full Backup" do
  resource type: :database, name: "myapp_db", host: "production-mysql-master"

  remotely as: "operator" do
    mysql_dump user: "backup-operator", password: encrypted("XXXXXXXX")
    tar_gz delete_source: true
  end
end
```

### Transports

Transports allow you to move or copy resources from an host to another. Like shells, transports
should be nested inside a project.

```ruby
project "myapp-database-backup", description: "Database Full Backup" do
  resource type: :database, name: "myapp_db", host: "production-mysql-master"

  remotely as: "operator" do
    mysql_dump user: "backup-operator", password: encrypted("XXXXXXXX")
    tar_gz delete_source: true
  end

  move to: localhost, using: :scp, as "operator"
  copy to: "backup-store-1", using: :scp, as: "another-op", directory: '/srv/backups/'
  move to: bucket('my-bucket'), using: :s3, access_key_id: 'XXXXXXXX',
    secret_key: encrypted('XXXXXXXX')
end
```

The `move` method deletes the previous resource and replace it with a new one, whereas the `copy`
command let the previous resource unchanged.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

