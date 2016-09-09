require File.join(File.dirname(__FILE__), '../build')

name          'electric_sheep'
friendly_name 'Electric Sheep IO'
maintainer    'ServeBox <humans@electricsheep.io>'
homepage      'http://electricsheep.io'
license       'MIT'

build_version ElectricSheep::VERSION

install_dir '/opt/electric_sheep'
build_iteration 1

# build_platform = ohai['platform']

override 'ruby', version: '2.3.1'
override 'rubygems', version: '2.6.6'

# creates required build directories
dependency 'preparation'

# electric_sheep dependencies/components
dependency 'electric_sheep'

# version manifest file
dependency 'version-manifest'

exclude '\.git*'
exclude 'bundler\/git'

package :deb do
  vendor 'ServeBox <humans@electricsheep.io>'
  license 'MIT'
  section 'utilities'
end
