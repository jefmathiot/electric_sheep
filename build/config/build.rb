def packaging_directories
  @_packaging_directories={}.tap do |dirs|
    dirs[:build]=File.expand_path(
      File.join(File.dirname(__FILE__), '..')
    )
    dirs[:root]=File.expand_path(File.join(dirs[:build], '..'))
  end
end

require File.join(packaging_directories[:root], 'lib/electric_sheep/version')