require 'spec_helper'

describe ElectricSheeps::Metadata::Project do
  include Support::Accessors
  include Support::Queue

  def queue_items
    [
      ElectricSheeps::Metadata::Shell.new,
      ElectricSheeps::Metadata::Transport.new
    ]
  end

  it "initializes the project's id" do
    project = subject.new(id: 'some-project')
    project.id.must_equal 'some-project'
    project.products.keys.size.must_equal 0
  end

  it 'defines a description accessor' do
    expects_accessor(:description)
  end

  it 'stores and retrieves products' do
    project = subject.new
    project.store_product('step', resource = mock)
    ['step', :step].each do |step|
      project.product_of(step).must_equal resource
    end
  end

end
