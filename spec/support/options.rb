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
        expects_validation_error(initialize_subject(*args), option,
                                 "Option #{option} is required")
      end
    end

    def defaults_option(option, to)
      initialize_subject.option(option).must_equal to
    end

    def expects_validation_error(subject, option, msg)
      subject.validate
      actual = (subject.errors[option] || []).find do |error|
        error[:message] =~ /#{msg}/
      end
      actual.wont_be_nil "Expected validation error: #{msg}"
    end

    def initialize_subject(*args)
      if subject.ancestors.include?(ElectricSheep::Metadata::Configured)
        subject.new(ElectricSheep::Config.new, *args)
      else
        subject.new(*args)
      end
    end
  end
end
