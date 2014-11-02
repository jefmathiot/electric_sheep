require File.join(File.dirname(__FILE__), '../build')

name 'electric_sheep'
maintainer 'servebox'
homepage 'https://github.com/servebox/electric_sheep'
build_version ElectricSheep::VERSION

install_dir '/opt/electric_sheep'
build_iteration 1

# creates required build directories
dependency 'preparation'

# electric_sheep dependencies/components
dependency 'electric_sheep'

# version manifest file
dependency 'version-manifest'

exclude '\.git*'
exclude 'bundler\/git'
