class Asset < ActiveRecord::Base

  has_ancestry cache_depth: true

  scope :list, order('file_uploader ASC')
  scope :list_roots, list.where(ancestry: nil)



  attr_accessible :title, :description, :parent_id, :file_uploader, :file_uploader_cache#, :remove_file_uploader, :remote_file_uploader_url
  attr_accessible :width, :height, :size
  attr_accessible :domain

  validates_presence_of :domain
  validates_presence_of :title

  validates_uniqueness_of :title, scope: [:ancestry, :domain]


  mount_uploader :file_uploader, AssetFileUploader

  #delegate :is_image?, :width, :height, :size,
  #delegate :is_image?,
  #         to: :file_uploader,
  #         allow_nil: true


  before_create do |record|
    record.title = record.title.scan(/([^\/\\]+)\.?[a-z0-9]*$/i)[0][0].camelize if record.title.blank?
    true
  end

  def px_size
    "#{width}x#{height}" if width && height
  end

  def is_image?
    file_uploader && file_uploader.is_image? # && self.px_size
  end

end
