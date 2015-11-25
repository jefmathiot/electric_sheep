module Support
  module ShellMetadata
    extend ActiveSupport::Concern

    included do
      let(:config) do
        ElectricSheep::Config.new
      end

      it 'should be empty' do
        subject_instance.size.must_equal 0
      end

      it 'should add commands' do
        shell = subject_instance
        cmd = ElectricSheep::Metadata::Command.new(config,
                                                   id: 'exec_id',
                                                   type: Object)
        shell.add cmd
        shell.size.must_equal 1
      end
    end

    def subject_instance
      subject.new(config)
    end
  end
end
