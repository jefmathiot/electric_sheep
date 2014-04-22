module Support
  module Options
    def defines_options(*options)
      options.each do |prop|
        subject.options.include?(prop).must_equal true,
          "Expected #{subject.name} to define #{prop}"
      end
    end

    def requires(*options)
      options.each do |option|
        subject.new.tap do |subject|
          expects_validation_error(subject, option,
            "Option #{option} is required")
        end
      end
    end

    def expects_validation_error(subject, option, msg, config = ElectricSheep::Config.new)
      subject.validate(config)
      actual = (subject.errors[option] || []).find do |error|
        error[:message] =~ /#{msg}/
      end
      actual.wont_be_nil "Expected validation error: #{msg}"
    end
  end
end
