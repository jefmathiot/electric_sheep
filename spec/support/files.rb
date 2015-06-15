require 'timecop'

module Support
  module Files
    module Named
      extend ActiveSupport::Concern
      include Options

      included do
        it do
          defines_options :parent, :basename
          requires :parent, :basename
        end

        it 'creates a path from elements' do
          subject.new(
            parent: '/tmp',
            basename: 'test'
          ).path.must_equal '/tmp/test'
        end

        it 'adds a timestamp to the name' do
          named = subject.new(
            parent: '/tmp',
            basename: 'test'
          )
          Timecop.travel Time.utc(2014, 1, 1, 0, 0, 0) do
            named.timestamp!(subject.new)
            named.path.must_equal '/tmp/test-20140101-000000'
          end
        end
      end
    end

    module Extended
      extend ActiveSupport::Concern
      include Options

      included do
        it do
          defines_options :extension
        end

        it 'adds the extension to the name' do
          named = subject.new(
            parent: '/tmp',
            basename: 'test',
            extension: '.tar.gz'
          )
          Timecop.travel Time.utc(2014, 1, 1, 0, 0, 0) do
            named.timestamp!(subject.new)
            named.path.must_equal '/tmp/test-20140101-000000.tar.gz'
          end
        end
      end
    end
  end
end
