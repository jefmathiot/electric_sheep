require 'spec_helper'

describe ElectricSheep::Notifiers::Template do

  def self.ensure_context_binding(ext=nil)

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

      it 'binds context to a template' do
        renderer=subject.new(File.basename(*[template.path, ext].compact))
        renderer.render(bound_value: 1).must_equal 'Value: 1'
      end

    end

  end

  ensure_context_binding
  ensure_context_binding '.html'
end