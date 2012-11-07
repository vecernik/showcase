class EntryContainer < ActiveRecord::Base

  #belongs_to :page,
  #           foreign_key: 'containee_id'

  #acts_as_list scope: :page

  has_many :entries,
           foreign_key: 'container_id',
           include: :editable_properties,
           order: 'position',
           class_name: 'EditableEntry',
           dependent: :destroy



  attr_accessible :can_add, :can_autobuild, :can_delete, :can_edit, :can_move, :key_name, :max_count, :url, :properties, :entry_path, :domain, :new_title

  serialize :properties, Hash


  validates_presence_of :key_name
  validates_presence_of :domain


  after_create do |record|
    if record.persisted? && record.can_autobuild && record.max_count > 0
      record.max_count.times{ record.entries.create }
    end
  end


  def add_entry(properties=nil)
    if !self.max_count || entries.length <= self.max_count
      entry = entries.create
      entry.set_properties properties if properties
    end
  end


  def self.duplicate_from source_container, new_properties
    attrs = {}
    accessible_attributes.each do |name|
      attrs[name.to_sym] = source_container.send name unless name.blank?
    end
    attrs.merge! new_properties
    create attrs
  end


  def duplicate_entries_from source_container

    source_container.entries.order(:position).each do |source_entry|

      new_entry = self.entries.create

      source_entry.editable_properties.each do |prop|
        new_entry.set_property prop.name, prop.content
      end

    end

  end

end
