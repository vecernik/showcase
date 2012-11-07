class EditableProperty < ActiveRecord::Base

  self.primary_key = 'name'

  has_many :editable_entry_properties,
           foreign_key: 'name',
           dependent: :delete_all


  scope :list, order(:position)

  acts_as_list


  attr_accessible :default_content, :label, :max_length, :meta, :name, :prop_type, :position #, :in_panel

  validates_presence_of :name, :label, :prop_type

  serialize :meta, Hash


  #after_create do |record|
  #  EditableEntry.includes(:container).each do |entry|
  #    entry.editable_properties.create(editable_property: record, content: record.default_content) if entry.container.properties.key?(record.name.to_sym)
  #  end
  #end

end
