require 'spec_helper'

describe ElectricSheep do

  it 'provides the path to the gem installation' do
    subject.gem_path.must_match /electric_sheep$/
  end

  it 'provides the path to the templates' do
    subject.template_path.must_equal "#{subject.gem_path}/templates"
  end

end