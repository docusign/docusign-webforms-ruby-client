=begin
#Web Forms API version 1.1

#The Web Forms API facilitates generating semantic HTML forms around everyday contracts. 

OpenAPI spec version: 1.1.0
Contact: devcenter@docusign.com
Generated by: https://github.com/swagger-api/swagger-codegen.git

=end

require 'date'

module DocuSign_WebForms
  # A list of web form summary items.
  class WebFormSummaryList
    # Array of web form items with each containing summary.
    attr_accessor :items

    # Result set size for current page
    attr_accessor :result_set_size

    # Total result set size
    attr_accessor :total_set_size

    # Starting position of fields returned for the current page
    attr_accessor :start_position

    # Ending position of fields returned for the current page
    attr_accessor :end_position

    # Url for the next page of results
    attr_accessor :next_url

    # Url for the previous page of results
    attr_accessor :previous_url

    # Attribute mapping from ruby-style variable name to JSON key.
    def self.attribute_map
      {
        :'items' => :'items',
        :'result_set_size' => :'resultSetSize',
        :'total_set_size' => :'totalSetSize',
        :'start_position' => :'startPosition',
        :'end_position' => :'endPosition',
        :'next_url' => :'nextUrl',
        :'previous_url' => :'previousUrl'
      }
    end

    # Attribute type mapping.
    def self.swagger_types
      {
        :'items' => :'Array<WebFormSummary>',
        :'result_set_size' => :'Float',
        :'total_set_size' => :'Float',
        :'start_position' => :'Float',
        :'end_position' => :'Float',
        :'next_url' => :'String',
        :'previous_url' => :'String'
      }
    end

    # Initializes the object
    # @param [Hash] attributes Model attributes in the form of hash
    def initialize(attributes = {})
      return unless attributes.is_a?(Hash)

      # convert string to symbol for hash key
      attributes = attributes.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }

      if attributes.has_key?(:'items')
        if (value = attributes[:'items']).is_a?(Array)
          self.items = value
        end
      end

      if attributes.has_key?(:'resultSetSize')
        self.result_set_size = attributes[:'resultSetSize']
      end

      if attributes.has_key?(:'totalSetSize')
        self.total_set_size = attributes[:'totalSetSize']
      end

      if attributes.has_key?(:'startPosition')
        self.start_position = attributes[:'startPosition']
      end

      if attributes.has_key?(:'endPosition')
        self.end_position = attributes[:'endPosition']
      end

      if attributes.has_key?(:'nextUrl')
        self.next_url = attributes[:'nextUrl']
      end

      if attributes.has_key?(:'previousUrl')
        self.previous_url = attributes[:'previousUrl']
      end
    end

    # Show invalid properties with the reasons. Usually used together with valid?
    # @return Array for valid properties with the reasons
    def list_invalid_properties
      invalid_properties = Array.new
      invalid_properties
    end

    # Check to see if the all the properties in the model are valid
    # @return true if the model is valid
    def valid?
      true
    end

    # Checks equality by comparing each attribute.
    # @param [Object] Object to be compared
    def ==(o)
      return true if self.equal?(o)
      self.class == o.class &&
          items == o.items &&
          result_set_size == o.result_set_size &&
          total_set_size == o.total_set_size &&
          start_position == o.start_position &&
          end_position == o.end_position &&
          next_url == o.next_url &&
          previous_url == o.previous_url
    end

    # @see the `==` method
    # @param [Object] Object to be compared
    def eql?(o)
      self == o
    end

    # Calculates hash code according to all attributes.
    # @return [Fixnum] Hash code
    def hash
      [items, result_set_size, total_set_size, start_position, end_position, next_url, previous_url].hash
    end

    # Builds the object from hash
    # @param [Hash] attributes Model attributes in the form of hash
    # @return [Object] Returns the model itself
    def build_from_hash(attributes)
      return nil unless attributes.is_a?(Hash)
      self.class.swagger_types.each_pair do |key, type|
        if type =~ /\AArray<(.*)>/i
          # check to ensure the input is an array given that the attribute
          # is documented as an array but the input is not
          if attributes[self.class.attribute_map[key]].is_a?(Array)
            self.send("#{key}=", attributes[self.class.attribute_map[key]].map { |v| _deserialize($1, v) })
          end
        elsif !attributes[self.class.attribute_map[key]].nil?
          self.send("#{key}=", _deserialize(type, attributes[self.class.attribute_map[key]]))
        end # or else data not found in attributes(hash), not an issue as the data can be optional
      end

      self
    end

    # Deserializes the data based on type
    # @param string type Data type
    # @param string value Value to be deserialized
    # @return [Object] Deserialized data
    def _deserialize(type, value)
      case type.to_sym
      when :DateTime
        DateTime.parse(value)
      when :Date
        Date.parse(value)
      when :String
        value.to_s
      when :Integer
        value.to_i
      when :Float
        value.to_f
      when :BOOLEAN
        if value.to_s =~ /\A(true|t|yes|y|1)\z/i
          true
        else
          false
        end
      when :Object
        # generic object (usually a Hash), return directly
        value
      when /\AArray<(?<inner_type>.+)>\z/
        inner_type = Regexp.last_match[:inner_type]
        value.map { |v| _deserialize(inner_type, v) }
      when /\AHash<(?<k_type>.+?), (?<v_type>.+)>\z/
        k_type = Regexp.last_match[:k_type]
        v_type = Regexp.last_match[:v_type]
        {}.tap do |hash|
          value.each do |k, v|
            hash[_deserialize(k_type, k)] = _deserialize(v_type, v)
          end
        end
      else # model
        temp_model = DocuSign_WebForms.const_get(type).new
        temp_model.build_from_hash(value)
      end
    end

    # Returns the string representation of the object
    # @return [String] String presentation of the object
    def to_s
      to_hash.to_s
    end

    # to_body is an alias to to_hash (backward compatibility)
    # @return [Hash] Returns the object in the form of hash
    def to_body
      to_hash
    end

    # Returns the object in the form of hash
    # @return [Hash] Returns the object in the form of hash
    def to_hash
      hash = {}
      self.class.attribute_map.each_pair do |attr, param|
        value = self.send(attr)
        next if value.nil?
        hash[param] = _to_hash(value)
      end
      hash
    end

    # Outputs non-array value in the form of hash
    # For object, use to_hash. Otherwise, just return the value
    # @param [Object] value Any valid value
    # @return [Hash] Returns the value in the form of hash
    def _to_hash(value)
      if value.is_a?(Array)
        value.compact.map { |v| _to_hash(v) }
      elsif value.is_a?(Hash)
        {}.tap do |hash|
          value.each { |k, v| hash[k] = _to_hash(v) }
        end
      elsif value.respond_to? :to_hash
        value.to_hash
      else
        value
      end
    end

  end
end
