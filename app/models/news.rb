class News < ActiveRecord::Base
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  has_many :attachments, :as => :parent, :dependent => :destroy, :class_name => "::Attachment"
  
  validates_presence_of :title, :content, :author
  
  default_scope :order => "created_at DESC"
  
  define_index do
    indexes title
    indexes content
  end
end
