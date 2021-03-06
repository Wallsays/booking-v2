class InventoryTemplateGroup < ActiveRecord::Base
  attr_accessible :name, :primary, :restaurant
 
  validates :restaurant_id,      :presence => true
  validates :name,               :presence => true
 
  belongs_to :restaurant
  has_many   :inventory_templates
  
end
