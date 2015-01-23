require 'spec_helper'


describe ElectricSheep::Spawn do

  let(:child){ mock.tap{|m| m.expects(:status).returns(127) } }
  let(:cmd){ 'echo "" > /dev/null' }

  before do
    POSIX::Spawn::Child.expects(:new).with(cmd).returns(child)
  end

  it 'returns the default output' do
    child.expects(:out).returns nil
    child.expects(:err).returns nil
    subject.exec(cmd).must_equal({ out: '', err: '', exit_status: 127 })
  end

  describe 'with an stdout' do

    let(:expected_result){
      { out: 'x', err: '', exit_status: 127}
    }

    before do
      child.expects(:out).at_least_once.returns "x\n"
      child.expects(:err).returns nil
    end

    it 'adds the stdout in return hash' do
      subject.exec(cmd).must_equal expected_result
    end

    it 'logs the stdout' do
      logger=mock
      logger.expects(:debug).with('x')
      subject.exec(cmd, logger)
    end

  end

  describe 'with an stderr' do

    let(:expected_result){
      { out: '', err: 'y', exit_status: 127}
    }

    before do
      child.expects(:out).returns nil
      child.expects(:err).at_least_once.returns "y\n"
    end

    it 'adds the stderr in the return hash' do
      subject.exec(cmd).must_equal expected_result
    end

  end
end
