class SetupProperty < ActiveRecord::Base

  self.primary_key = 'name'

  has_many :setup_values,
           foreign_key: 'name',
           dependent: :destroy


  has_one :setup_value,
           foreign_key: 'name',
           readonly: true


  scope :list, includes(:setup_values).order(:position)

  acts_as_list


  attr_accessible :default_content, :label, :max_length, :meta, :name, :prop_type #, :in_panel

  validates_presence_of :name, :label, :prop_type

  serialize :meta, Hash


  after_create do |record|
    Domain.all.each do |d|
      record.setup_values.create(content: record.default_content, domain: d.name)
    end
  end

end
