class EditableEntry < ActiveRecord::Base

  belongs_to :container,
             class_name: 'EntryContainer',
             inverse_of: :entries


  acts_as_list scope: :container


  has_many :editable_properties,
           #order: 'editable_properties.position',
           include: :editable_property,
           foreign_key: 'entry_id',
           class_name: 'EditableEntryProperty',
           dependent: :destroy


#  attr_accessible :container_id #, :max_pictures
  attr_accessible :position


  after_create do |record|
    record.container.properties.keys.each do |property_name|
      property = EditableProperty.find(property_name)
      record.editable_properties.create(name: property_name, content: property.default_content)
    end
    true
  end


  def get_property(name)
    prop = property_by_name(name.to_s)
    prop.get_value if prop
  end

  def get_raw_property(name)
    prop = property_by_name(name.to_s)
    prop.content if prop
  end

  def set_property(name, value)
    prop = property_by_name(name.to_s)
    prop.set_value(value) && prop.reload if prop
    #get_property(name)
  end

  def set_properties(values)
    values.each do |name, value|
      set_property(name, value)
    end
    self
  end

  def method_missing(name)
    if container.properties.key?(name.to_sym)
      get_property(name)
    else
      super
    end
  end

  def get_size(name=:file)
    f = self.send(name)
    if f.blank?
      0
    elsif !f[/:\/\//]
      filename = "#{Rails.public_path}/uploads#{f}"
      handle = File.open(filename) if File.exists? filename
      handle.size.to_i if handle
    end
  end

  def ext(name=:file)
    self.send(name).scan(/[^.][a-z0-9]+$/)[0] || 'unknown'
  end

  def get_filename(name=:file)
    self.send(name).scan(/[^\/]+$/)[0]
  end

private

  def property_by_name(name)
    editable_properties.find{|record| record.name == name }
  end

end
