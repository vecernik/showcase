class Country < ActiveRecord::Base

  has_many :companies


  scope :list, select('countries.id, countries.name').joins(:companies).where('companies.lat IS NOT NULL AND companies.lng IS NOT NULL').group('countries.id, countries.name').order('countries.name')


  attr_accessible :name

  validates_presence_of :name
  validates_uniqueness_of :name

end
