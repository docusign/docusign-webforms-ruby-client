=begin
#Web Forms API version 1.1

#The Web Forms API facilitates generating semantic HTML forms around everyday contracts. 

OpenAPI spec version: 1.1.0
Contact: devcenter@docusign.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

=end

require 'date'

module DocuSign_WebForms
  class WebFormSource
    
    TEMPLATES = 'templates'.freeze
    BLANK = 'blank'.freeze

    # Builds the enum from string
    # @param [String] The enum value in the form of the string
    # @return [String] The enum value
    def build_from_hash(value)
      constantValues = WebFormSource.constants.select { |c| WebFormSource::const_get(c) == value }
      raise "Invalid ENUM value #{value} for class #WebFormSource" if constantValues.empty?
      value
    end
  end
end