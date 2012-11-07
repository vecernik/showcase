class SetupValue < ActiveRecord::Base

  belongs_to :setup_property

  attr_accessible :content, :domain

  validates_presence_of :domain

  #cattr_accessor :_properties
  #  all
  #end

  def self.get name, domain_name
    prop = find_by_name_and_domain(name, domain_name)
    prop.content if prop
  end

  #def self.properties
  #  @_properties ||= all
  #end

end
