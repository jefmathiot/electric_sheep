module Support
  module Accessors
    
    def expects_accessor(accessor)
      subject.new.respond_to?(accessor).must_equal true, "expected to define a \"#{accessor}\" accessor"
      subject.new.respond_to?("#{accessor}=").must_equal true, "expected to define a \"#{accessor}\" accessor"
    end

  end
end