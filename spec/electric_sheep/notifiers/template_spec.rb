require 'spec_helper'

describe ElectricSheep::Notifiers::Template do
  def create_template(name, ext, content)
    Tempfile.new([name, "#{ext}.erb"].compact).tap do |tmpl|
      tmpl.write content
      tmpl.close
    end
  end

  def self.ensure_rendering(ext = nil)
    describe "with the '#{ext}.erb' template" do
      let(:template) do
        create_template 'es-template', ext, 'Value: <%= bound_value %>'
      end

      after do
        template.unlink
      end

      it 'binds the context and renders the template' do
        ElectricSheep.expects(:template_path)
          .returns(File.dirname(template.path))
        renderer = subject.new(File.basename(template.path, '.erb'))
        renderer.render(bound_value: 1).must_equal 'Value: 1'
      end
    end
  end

  ensure_rendering
  ensure_rendering '.html'

  describe ElectricSheep::Notifiers::Template::Binding do
    let(:partial) do
      create_template 'es-partial', '.html',
                      'assets: <%= assets_url %>, value: <%= bound_value %>'
    end

    it 'gets bound values from context' do
      subject.new(bound_value: 1).bound_value.must_equal 1
    end

    it 'raises when value does not exist' do
      -> { subject.new({}).bound_value }.must_raise NoMethodError
    end

    it 'renders partial using a child template' do
      ElectricSheep.expects(:template_path)
        .returns(File.dirname(partial.path))
      subject.new(assets_url: 'http://assets.host.tld')
        .partial(File.basename(partial.path, '.erb'), bound_value: 1)
        .must_equal 'assets: http://assets.host.tld, value: 1'
    end

    describe 'providing helpers' do
      it 'creates path to assets' do
        subject.new(assets_url: 'http://assets.host.tld')
          .asset('asset.png')
          .must_equal 'http://assets.host.tld/asset.png'
      end

      describe 'with time frozen' do
        before {  Timecop.travel(Time.local(2014, 1, 1, 1, 2, 3)) }
        after { Timecop.return }

        it 'formats datetime to date' do
          subject.new({}).to_date(Time.now).must_equal '2014-01-01'
        end

        it 'formats datetime to time' do
          subject.new({}).to_time(Time.now).must_equal '01:02:03'
        end

        it 'formats datetime to timezone' do
          subject.new({}).to_timezone(Time.now)
            .must_equal Time.now.getlocal.zone
        end

        it 'formats number to duration' do
          subject.new({}).to_duration(3600 + 60 + 1.0)
            .must_equal '1h1m1s'
        end
      end
    end
  end
end
