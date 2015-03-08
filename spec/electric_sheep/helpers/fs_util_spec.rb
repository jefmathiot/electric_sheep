require 'spec_helper'

describe ElectricSheep::Helpers::FSUtil do

  it 'creates a random name for temp files and directories' do
    subject.tempname.wont_equal subject.tempname
    subject.tempname.must_match /^tmp\d{8}-#{Process.pid}-.+/
  end

  let(:executor){ mock }
  let(:seq){ sequence('exec') }

  def expects_path_expansion(path, expanded)
    executor.expects(:exec).in_sequence(seq).
      with("echo \"#{path}\"").
      returns(out: expanded)
  end

  def expects_rm(path)
    executor.expects(:exec).in_sequence(seq).
      with("rm -rf #{path}")
  end

  describe 'creating a temp object' do

    let(:tempname){ "temp-name" }
    let(:temppath){ "/tmp/#{tempname}" }

    before do
      subject.stubs(:tempname).returns(tempname)
      expects_path_expansion(temppath, temppath)
    end

    describe 'creating a temporary directory' do

      def expects_exec(status=0)
        executor.expects(:exec).in_sequence(seq).
          with("mkdir -p #{temppath} && chmod 0700 #{temppath}").
        returns(exit_status: status)
      end

      it 'raises when the command fails' do
        expects_exec(1)
        ex = ->{ subject.tempdir(executor) }.must_raise RuntimeError
        ex.message.must_equal "Unable to create tempdir"
      end

      it 'yields if a block is given then deletes the directory' do
        expects_exec(0)
        expects_rm(temppath)
        expected = false
        subject.tempdir( executor ) do |path|
          expected = path == temppath
        end
        expected.must_equal true
      end

      it 'returns the path to the directory' do
        expects_exec(0)
        subject.tempdir( executor ).must_equal temppath
      end

    end

    describe 'creating the path to a temporary file' do

      it 'yields if a block is given then deletes the file' do
        expects_rm(temppath)
        expected = false
        subject.tempfile( executor ) do |path|
          expected = path == temppath
        end
        expected.must_equal true
      end

      it 'returns the path to the file' do
        subject.tempfile( executor ).must_equal temppath
      end

    end

  end

  it 'expands a path' do
    expects_path_expansion('path', '/path')
    subject.expand_path(executor, 'path').must_equal '/path'
  end

  it 'deletes an object' do
    expects_rm('path')
    subject.delete!(executor, 'path')
  end

end
