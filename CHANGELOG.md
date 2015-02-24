# Changelog

Please notice we'll use semantic versioning as of 1.0.0.

## 0.4.0 (Unreleased)

### Added

* Added a `--daemon` option to start the master in the background.

### Changed

* Changed the default startup mode which does not place the master process in
  the background anymore.

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
