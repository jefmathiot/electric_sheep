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
  end

  it 'defines a description accessor' do
    expects_accessor(:description)
  end

end
