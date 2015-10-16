module Support
  module Options
    def defines_options(*options)
      options.each do |prop|
        subject.options.include?(prop)
          .must_equal true, "Expected #{subject.name} to define #{prop}"
      end
    end

    def requires(*options)
      options.each do |option|
        args = [nil] * [subject.allocate.method(:initialize).arity, 0].max
        subject.new(*args).tap do |subject|
          expects_validation_error(subject, option,
          "Option #{option} is required")
        end
      end
    end

    def defaults_option(option, to)
      subject.new.option(option).must_equal to
    end

    def expects_validation_error(subject, option, msg,
      config = ElectricSheep::Config.new)
      subject.validate(config)
      actual = (subject.errors[option] || []).find do |error|
        error[:message] =~ /#{msg}/
      end
      actual.wont_be_nil "Expected validation error: #{msg}"
    end
  end
end
