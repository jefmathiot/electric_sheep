require 'spec_helper'

describe ElectricSheep::Interactors::ShellStat do

    ShellStatKlazz = Class.new do
      include ElectricSheep::Interactors::ShellStat
    end

    describe ShellStatKlazz do

      let(:shell_stat){ subject.new }

      [:file, :directory].each do |type|

        before do
          @resource=ElectricSheep::Resources.const_get(type.to_s.camelize).
            new(path: 'it')
        end

        it "stats a #{type} resource" do
          shell_stat.expects(:expand_path).with(@resource.path).
            returns('/path/to/it')
          shell_stat.expects(:exec).with("du -bs /path/to/it | cut -f1").
            returns(out: '1024\n')
          shell_stat.stat(@resource).must_equal 1024
        end

        it "does not exec if resource size is already known" do
          shell_stat.expects(:expand_path).never
          shell_stat.expects(:exec).never
          @resource.stat! 1024
          shell_stat.stat(@resource).must_equal 1024
        end
      end
    end
end
