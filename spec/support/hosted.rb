module Support
  module Hosted
    extend ActiveSupport::Concern

    included do
      it do
        defines_options :host
        requires :host
      end

      it 'delegates conversion to location to host' do
        subject.new(host: mock(to_location: location = mock)).to_location
          .must_equal location
      end
    end
  end
end
