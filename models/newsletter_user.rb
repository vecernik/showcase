class NewsletterUser < ActiveRecord::Base

  scope :list, order('created_at DESC')

  attr_accessible :email, :domain

  validates_presence_of :email
  validates_uniqueness_of :email, scope: :domain

end
