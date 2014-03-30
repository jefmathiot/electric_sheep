describe ElectricSheeps::Resources::FileSystem do

  FileSystemKlazz = Class.new do
    include ElectricSheeps::Resources::FileSystem
  end

  describe FileSystemKlazz do

    it 'defines a path option' do
      subject.new(path: 'myfile.txt').path.must_equal 'myfile.txt'
    end

    it 'defaults remote to false' do
      subject.new.remote?.must_equal false
    end

    it 'defines a remote option' do
      subject.new(remote: true).remote?.must_equal true
    end

  end

end
