module Support
    module ShellMetadata
        extend ActiveSupport::Concern

        included do

            it 'should be empty' do
                subject_instance.size.must_equal 0
            end

            it 'should add commands' do
                shell = subject_instance
                shell.add(ElectricSheeps::Metadata::Command.new(id: 'exec_id', agent: Object))
                shell.size.must_equal 1
            end
        end

        def subject_instance
            subject.new
        end
    end
end
