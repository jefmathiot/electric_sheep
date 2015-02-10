# Changelog

Please notice we'll use semantic versioning as of 1.0.0.

## 0.4.0 (Unreleased)

## 0.3.0 - 2015-02-10

* Deprecated the `project` DSL noun in favor of the `job` one
* Deprecated the `private_key` DSL method in favor of the `private_key` option
* Deprecated encryption of secrets and credentials using OpenSSL (OpenSSL keys
  are still in use for SSH/SCP, though)
* Added GPG support for encryption and decryption of secrets
* Added the `decrypt` verb to the DSL
* Removed all authentication methods except `publickey` for SSH and SCP
* Fixed #5 (`encrypted` does not work outside jobs)
