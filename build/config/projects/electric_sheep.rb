require File.join(File.dirname(__FILE__), '../build')

name 'electric_sheep'
friendly_name "Electric Sheep IO"
maintainer 'ServeBox'
homepage 'http://electricsheep.io'

build_version ElectricSheep::VERSION

install_dir '/opt/electric_sheep'
build_iteration 1

build_platform = ohai['platform'] + '_' + ohai['platform_version']

override 'ruby', version: "2.2.1"
override 'rubygems', version: "2.4.5"

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
  license 'MIT License'
  section 'utilities'
  base_name "electric-sheep-#{build_platform}"
end

package :rpm do
  vendor 'ServeBox <humans@electricsheep.io>'
  license 'MIT'
  category 'utilities'
end

