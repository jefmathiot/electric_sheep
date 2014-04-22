module Support
  module Properties
    def defines_properties(*properties)
      properties.each do |prop|
        subject.properties.include?(prop).must_equal true,
          "Expected #{subject.name} to define #{prop}"
      end
    end

    def requires(*properties)
      properties.each do |property|
        subject.new.tap do |subject|
          expects_validation_error(subject, property,
            "Property #{property} is required")
        end
      end
    end

    def expects_validation_error(subject, property, msg, config = ElectricSheep::Config.new)
      subject.validate(config)
      actual = (subject.errors[property] || []).find do |error|
        error[:message] =~ /#{msg}/
      end
      actual.wont_be_nil "Expected validation error: #{msg}"
    end
  end
end
