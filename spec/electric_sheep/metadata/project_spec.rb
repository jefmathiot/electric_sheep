require 'spec_helper'

describe ElectricSheep::Metadata::Project do
  include Support::Accessors
  include Support::Queue

  def queue_items
    [
      ElectricSheep::Metadata::Shell.new,
      ElectricSheep::Metadata::Transport.new
    ]
  end

  it "initializes the project's id" do
    project = subject.new(id: 'some-project')
    project.id.must_equal 'some-project'
    project.products.size.must_equal 0
  end

  it 'defines a description accessor' do
    expects_accessor(:description)
  end

  it 'uses the initial resource when there are no products' do
    project = subject.new
    project.start_with!(resource = mock)
    project.last_product.must_equal resource
  end

  it 'retrieves the last product' do
    project = subject.new
    project.store_product!(mock)
    project.store_product!(resource = mock)
    project.last_product.must_equal resource
  end
end
