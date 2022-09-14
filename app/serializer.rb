class Serializer
  class << self
    attr_accessor :attributes_data
  end

  def attributes_data
    self.class.attributes_data || {}
  end

  Attribute = Struct.new(:name, :block) do
    def value(serializer)
      if block
        serializer.instance_eval(&block)
      else
        serializer.read_attribute(name)
      end
    end
  end

  attr_reader :object

  def initialize(object)
    @object = object
  end

  def read_attribute(name)
    if respond_to?(name)
      send(name)
    else
      object.public_send(name)
    end
  end

  def self.attribute(name, &block)
    self.attributes_data ||= {}
    self.attributes_data[name] = Attribute.new(name, block)
  end

  def serialize
    attributes_data.each_with_object({}) do |(key, attr), hash|
      hash[key] = attr.value(self)
    end
  end
end
