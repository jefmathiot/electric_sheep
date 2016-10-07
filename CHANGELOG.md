# Changelog

Please notice we'll use semantic versioning as of 1.0.0.

## 0.6.0 - Unreleased

### Added

* Added an 'ssh' DSL verb to specify SSH options (path to a `known_hosts` file, and host keys checking behavior).
* Add an 'hostkeys' CLI command used to refresh key cache.
* Add an 'exclude' options to the 'tar_gz ' command  - enhancement [#6](https://github.com/servebox/electric_sheep/issues/6).
* Bump Ruby to 2.3.0.
* Add the `exclude_tables` option to the 'mysql_dump' command - enhancement
[#22](https://github.com/servebox/electric_sheep/issues/22).
* Add the `exclude_tables` option to the 'pg_dump' command - enhancement
[#22](https://github.com/servebox/electric_sheep/issues/22).
* Add `private_key_data` option on hosts and jobs

### Fixed

* Fixed [#16](https://github.com/servebox/electric_sheep/issues/16) (avoid sensitive data, such as passwords, to be shown verbose mode is active).
* Fixed [#15](https://github.com/servebox/electric_sheep/issues/15) (exception is raised if there is a whitespace inside the jobname).

## 0.5.0 - 2015-06-24

### Added

* Added an `encrypt` command to encrypt backup files using GPG.
* Added a `decrypt` CLI command to decrypt backup files using GPG.
* Added a `load` DSL verb to load external Sheepfiles - enhancement [#7](https://github.com/servebox/electric_sheep/issues/7).
* Allow multiple schedules of the same job - enhancement [#10](https://github.com/servebox/electric_sheep/issues/10).
* Added support for Cron expressions in scheduling - enhancement [#11](https://github.com/servebox/electric_sheep/issues/11).

## 0.4.0 - 2015-02-25

### Added

* Added a `--daemon` option to start the master in the background.
* Added a Docker image.

### Changed

* Changed the default startup mode which does not place the master process in
  the background anymore.
* In default startup mode, the master does not write its pid to a file anymore.

## 0.3.0 - 2015-02-10

### Added

* Added GPG support for encryption and decryption of secrets.
* Added the `decrypt` verb to the DSL.

### Deprecated

* Deprecated the `project` DSL noun in favor of the `job` one.
* Deprecated the `private_key` DSL method in favor of the `private_key` option.
* Deprecated encryption of secrets and credentials using OpenSSL (OpenSSL keys
  are still in use for SSH/SCP, though).

### Removed

* Removed all authentication methods except `publickey` for SSH and SCP.

### Fixed

* Fixed #5 (`encrypted` does not work outside jobs).
