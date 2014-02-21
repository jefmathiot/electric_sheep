# ElectricSheeps

A simple task system for remote resources manipulation (i.e. backup).

[![Build Status](https://travis-ci.org/servebox/electric_sheeps.png)](https://travis-ci.org/servebox/electric_sheeps)
[![Dependency Status](https://gemnasium.com/servebox/electric_sheeps.png)](https://gemnasium.com/servebox/electric_sheeps)
[![Coverage Status](https://coveralls.io/repos/servebox/electric_sheeps/badge.png)](https://coveralls.io/r/servebox/electric_sheeps)
[![Code Climate](https://codeclimate.com/github/servebox/electric_sheeps.png)](https://codeclimate.com/github/servebox/electric_sheeps)

## Roadmap

Neither the API, DSL or runner are ready so far. Roadmap of features for upcoming version :

* :white_check_mark: Local and remote shells
* :clock11: Metadata API
* :clock11: Configuration DSL
* :clock11: Projects runner
* :clock11: SCP, RSYNC over SSH and Cloud Storage transports (using Fog ?)
* :heavy_minus_sign: Commands for directories & files backups and compression
* :heavy_minus_sign: Commands for popular RDBMS dumps (MySQL, Postgres)
* :heavy_minus_sign: Commands for popular key-value and document stores backups (Redis, Memcached, MongoDB, CouchDB)
* :heavy_minus_sign: Credentials encryption using public-key cryptography
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

    gem 'electric_sheeps'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install electric_sheeps

## Usage

### Setup your encryption keys

TODO

### Init

TODO

### Start

Just launch ElectricSheeps inside your project with:

```
bundle exec electric_sheeps work
```

ElectricSheeps will look for a Sheepfile in the current directory.

#### `-c` option

ElectricSheeps can use any file as the configuration:

```
bundle exec electric_sheeps work -c ~/Somefile 
```

## Using the DSL

### Hosts

The `host` method allows you to declare remote hosts. Each host should have a unique
identifier and define an hostname. You can declare as many hosts as needed.

```ruby
host "production-mysql-master" do
    description "MySQL - Production Master" # optional
    name "mysql1.domain.tld"
end

host "backup-store-1" do
    description "Storage Server 1"
    name "store1.domain.tld"
end
```

Please note that you don't have to declare the localhost.

### Projects

Projects allow you to logically group commands and transports to manipulate resources locally or
on remote hosts. Each project should have a unique
identifier. You can declare as many projects as needed.

```ruby
project "myapp-database-backup" do
    description "Database Full Backup"
    # Shells and transports here...
end

project "myapp-media-backup" do
    description "My Application Media Sync"
    # Shells and transports here...
end
```

### Shells & Commands

Shells allow you to execute sequences of commands locally or on remote hosts. Commands
are unaware of whether they execute on a remote host or on the local host.

The `remotely` method wraps commands inside an SSH session whereas the `locally` method
executes them on the localhost. `remotely` requires the `on` option to reference the
target host.

```ruby
project "myapp-database-backup" do
    description "Database Full Backup"
    remotely on: "production-mysql-master", as: "operator" do
        command "mysql_dump" do
            database "my_app" do
                user "backup-operator"
                encrypted.password "XXXXXXX"
            end
        end
        command "tar_gz", as: "mysql_archive" do
            file result_of("mysql_dump")
        end
    end
end
```

### Transports

Transports allow you to move or copy resources from an host to another. Like shells, transports should be nested inside a project.

```ruby
project "myapp-database-backup" do
    description "Database Full Backup"
    remotely on: "production-mysql-master", as: "operator" do
        command "mysql_dump" do
            database "my_app" do
                user "backup-operator"
                encrypted.password "XXXXXXX"
            end
        end
        command "targ_gz", as: "mysql_archive" do
            file result_of("mysql_dump")
            delete_source
        end
    end
    transport :scp do
        from do
            host host("production-mysql-master")
            file result_of("mysql_archive")
        end
        to do
            host localhost
            file result_of("mysql_archive")
        end
        delete_source
    end
    transport :s3 do
        from do
            host localhost
            file result_of("mysql_archive")
        end
        to do
            # ...
        end
    end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
