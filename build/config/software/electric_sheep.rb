require File.join(File.dirname(__FILE__), '../build')

name "electric_sheep"

#git default version
default_version ElectricSheep::VERSION

dependency "ruby"
dependency "rubygems"
dependency "bundler"

source path: packaging_directories[:root]

relative_path "electric_sheep"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  gem "build electric_sheep.gemspec", env: env
  gem "install electric_sheep-#{ElectricSheep::VERSION}.gem \
    -n #{install_dir}/bin --no-ri --no-rdoc", env: env
end
