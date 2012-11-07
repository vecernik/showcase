class NeedBuilding < ActiveRecord::Base

  scope :list, order('created_at DESC')


  attr_accessible :address, :building_usage, :comments, :company_name, :country_name, :email, :name, :surface_area, :telephone, :title_or_profession, :send_newsletter

  validates_presence_of :building_usage, :email #, :name, :surface_area, :telephone

  #serialize :building_usage, Hash


  comma do

    #domain
    country_name
    building_usage
    #surface_area
    comments
    name
    #title_or_profession
    company_name
    address
    telephone
    email
    #send_newsletter
    created_at

  end

end
