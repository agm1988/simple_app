class Micropost < ActiveRecord::Base

  attr_accessible :content

  belongs_to :user

  validates :content, :presence => true, :length => {:maximum => 140}
  validates :user_id, :presence => true

  # Return microposts from the users being followed by the given user.
  default_scope :order => 'microposts.created_at DESC'

  scope :form_users_followed_by, lambda {|user| followed_by(user)}




  #def self.form_users_followed_by(user)
  #  #following_ids = user.following_ids
  #  #where("user_id IN (#{following_ids}) OR user_id = ?", user)
  #
  #  where(:user_id => user.following_ids.push(user))
  #end



  private

  # Return an SQL condition for users followed by the given user.
  # We include the user's own id as well.

  def self.followed_by(user)
    #following_ids = user.following_ids
    following_ids = %(SELECT followed_id FROM relationships WHERE follower_id = :user_id)
    where("user_id IN (#{following_ids}) OR user_id = :user_id", {:user_id => user})
  end






end
