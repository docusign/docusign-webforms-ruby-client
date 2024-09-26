=begin
#Web Forms API version 1.1

#The Web Forms API facilitates generating semantic HTML forms around everyday contracts. 

OpenAPI spec version: 1.1.0
Contact: devcenter@docusign.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

=end

require 'date'

module DocuSign_WebForms
  class InstanceSource
    
    PUBLIC_URL = 'PUBLIC_URL'.freeze
    API_EMBEDDED = 'API_EMBEDDED'.freeze
    API_REMOTE = 'API_REMOTE'.freeze
    UI_REMOTE = 'UI_REMOTE'.freeze
    WORKFLOW = 'WORKFLOW'.freeze

    # Builds the enum from string
    # @param [String] The enum value in the form of the string
    # @return [String] The enum value
    def build_from_hash(value)
      constantValues = InstanceSource.constants.select { |c| InstanceSource::const_get(c) == value }
      raise "Invalid ENUM value #{value} for class #InstanceSource" if constantValues.empty?
      value
    end
  end
end
