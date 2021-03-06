# encoding: utf-8
class Reservation < ActiveRecord::Base

  PERIODS = ["00:00","00:15","00:30","00:45","01:00","01:15","01:30","01:45","02:00","02:15","02:30","02:45","03:00","03:15","03:30","03:45","04:00","04:15","04:30","04:45","05:00","05:15","05:30","05:45","06:00","06:15","06:30","06:45","07:00","07:15","07:30","07:45","08:00","08:15","08:30","08:45","09:00","09:15","09:30","09:45","10:00","10:15","10:30","10:45","11:00","11:15","11:30","11:45","12:00","12:15","12:30","12:45","13:00","13:15","13:30","13:45","14:00","14:15","14:30","14:45","15:00","15:15","15:30","15:45","16:00","16:15","16:30","16:45","17:00","17:15","17:30","17:45","18:00","18:15","18:30","18:45","19:00","19:15","19:30","19:45","20:00","20:15","20:30","20:45","21:00","21:15","21:30","21:45","22:00","22:15","22:30","22:45","23:00","23:15","23:30","23:45","24:00"]
 
  attr_accessible :active, :date, :party_size, 
                  :start_time, :end_time,
                  :user_id, :owner_id, :restaurant_id,
                  :name, :email, :phone,
                  :no_show, :arrived, :table,
                  :special_request
 
  # validates :user_id,       :presence => true
  # validates user/owner id presence
  validates :restaurant_id, :presence => true
  validates :date,          :presence => true
  validates :start_time,    :presence => true
  validates :end_time,      :presence => true
  validates :party_size,    :presence => true

  validate  :unreg_user_validation            
  validate  :restaurant_id_validation            
  validate  :date_validation, :if => :is_restaurant_id_real?
  # validate  :party_size_available_validation

  validates :party_size, :numericality => { 
      :greater_than => 0 }

  after_create   :create_reward
  after_update   :update_reward
  before_destroy :delete_reward

  belongs_to :user
  belongs_to :owner
  belongs_to :restaurant

  has_one :reward

  scope :active, -> { where active: true }

  def start_time 
    self[:start_time].strftime('%H:%M') unless self[:start_time].blank?
  end

  def start_time=(value) 
    self[:start_time] = Time.zone.parse(value.to_s).utc 
  end

  def end_time 
    self[:end_time].strftime('%H:%M') unless self[:end_time].blank?
  end

  def end_time=(value) 
    self[:end_time] = Time.zone.parse(value.to_s).utc 
  end


private

  def party_size_available_validation
    unless is_avilabale_reservation?
      self.errors.add(:party_size, "Please, check restaurant page for available date/time and places.")
    end
  end

  # TODO
  def is_avilabale_reservation?
    Restaurant.find(restaurant_id).inventories.each do |inv| 
      if inv.date == date
        if inv.start_time.strftime('%H:%M') <= start_time && 
           inv.end_time.strftime('%H:%M') >= end_time
          if inv.quantity_available >= party_size
            return true
          end
        end
        return false
      end
    end 
    false
  end

  def unreg_user_validation
    return unless user_id.blank?

    if name.blank?
      self.errors.add(:name,  "Fill name field")
    end
    
    if email.blank?
      self.errors.add(:email, "Fill email field")
    end

    if phone.blank?
      self.errors.add(:phone, "Fill phone field")
    end

  end

  def restaurant_id_validation
    unless is_restaurant_id_real?
      self.errors.add(:restaurant_id, "Provide correct Restaurant ID")
    end
  end

  def is_restaurant_id_real?
    begin
      Restaurant.find(restaurant_id)
      return true
    rescue
      return false
    end
    false
  end

  def date_validation
    unless is_date_valid?
      self.errors.add(:date, "Check inventory for picked day.")
    end
  end

  def is_date_valid?
    return true unless owner_id.blank?  # not check available status for owners reservations
    found = false
    begin
      Restaurant.find(restaurant_id).inventories.each do |inv|
        if inv.date.year == date.year && inv.date.month == date.month && inv.date.day == date.day
          found = true
        end
      end
    rescue
      return false
    end
    found
  end

  def create_reward
    Reward.create( user_id: user_id, 
                   reservation_id: id, 
                   points_total: 5*party_size, 
                   points_pending: 5*party_size,    
                   description: "")
    # UserMailer.booking_create(current_user, @reservation).deliver
    # OwnerMailer.booking_create(@reservation).deliver
  end

  def update_reward
    reward = Reward.where(:reservation_id => id).first
    reward.update_attributes( points_total: 5*party_size, 
                              points_pending: 5*party_size )
    # UserMailer.booking_update(current_user, @reservation).deliver
    # OwnerMailer.booking_update(@reservation).deliver
  end

  def delete_reward
    reward = Reward.where(:reservation_id => id).first
    reward.destroy
    # UserMailer.booking_removed(current_user, @reservation).deliver
    # OwnerMailer.booking_removed(@reservation).deliver
  end
  
end
