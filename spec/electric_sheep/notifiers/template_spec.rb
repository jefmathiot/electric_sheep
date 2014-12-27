require 'spec_helper'

describe ElectricSheep::Notifiers::Template do

  def self.ensure_rendering(ext=nil)

    describe "with the '#{ext}.erb' template" do

      before do
        ElectricSheep.expects(:template_path).returns(
          File.dirname(template.path)
        )
      end

      let(:template) do
        Tempfile.new(['es-template', "#{ext}.erb"].compact).tap do |tmpl|
          tmpl.write 'Value: <%= bound_value %>'
          tmpl.close
        end
      end

      after do
        template.unlink
      end

      it 'binds the context and renders the template' do
        renderer=subject.new(File.basename(template.path, '.erb'))
        renderer.render(bound_value: 1).must_equal 'Value: 1'
      end

    end

  end

  ensure_rendering
  ensure_rendering '.html'
end
