class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |inst_var|
      define_method("#{inst_var}") do
        instance_variable_get("@#{inst_var}")
      end
      define_method("#{inst_var}=") do |val|
        instance_variable_set("@#{inst_var}", val)
      end
    end
  end
end
