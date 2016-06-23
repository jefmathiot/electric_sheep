require 'spec_helper'

describe ElectricSheep::Interactors::Base do
  class FakeInteractor < ElectricSheep::Interactors::Base
    attr_accessor :returning, :directories, :session

    def exec(*cmd)
      _exec(*cmd) do
        returning
      end
    end

    def build_session
      :session
    end
  end

  [:host, :job, :logger].each do |m|
    let(m) { mock }
  end

  let(:interactor) { FakeInteractor.new(host, job, logger) }

  describe 'executing' do
    let(:secret) do
      ElectricSheep::Command::LoggerSafe.new('secret')
    end

    before do
      logger.expects(:debug).with('command ********')
      interactor.directories = mock
    end

    it 'succeeds' do
      interactor.returning = { exit_status: 0 }
      interactor.exec('command ', secret)
    end

    describe 'on failure' do
      it 'logs an error message if provided' do
        interactor.returning = { exit_status: 1, err: 'An error' }
        ex = -> { interactor.exec('command ', secret) }.must_raise
        ex.message.must_equal 'An error'
      end

      it 'logs the exit status otherwise' do
        interactor.returning = { exit_status: 1, err: '' }
        ex = -> { interactor.exec('command ', secret) }.must_raise
        ex.message.must_equal 'Command terminated with exit status: 1'
      end
    end
  end

  it 'wraps a block in session' do
    block_called = nil
    interactor.directories.expects(:mk_job_directory!)
    interactor.in_session do
      block_called = true
    end
    interactor.session.must_equal :session
    block_called.must_equal true
  end

  it 'deletes a resource' do
    resource = mock(path: 'resource')
    interactor.expects(:expand_path).with('resource')
              .returns('/path/to/resource')
    ElectricSheep::Helpers::FSUtil
      .expects(:delete!)
      .with(interactor, '/path/to/resource')
    interactor.delete!(resource)
  end

  it 'does nothing on close' do
    interactor.close
  end
end
