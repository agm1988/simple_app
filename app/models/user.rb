# == Schema Information
#
# Table name: users
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#
require "digest"

class User < ActiveRecord::Base

  attr_accessor :password

  attr_accessible :name, :email, :password, :password_confirmation

email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

# Automatically create the virtual attribute 'password_confirmation'.
  validates :password, :presence => true,
                       :confirmation => true,
                       :length => { :within => 6..40 }

  validates :name, :presence => true,
                   :length   => { :maximum => 50 }

  validates :email, :presence => true,
                    :format => {:with => email_regex},
                    :uniqueness => {:case_sensitive => false }

  before_save :encrypt_password

    # Return true if the user's password matches the submitted password.
  def has_password?(submitted_password)
    # Compare encrypted_password with the encrypted version of
    # submitted_password.
    encrypted_password == encrypt(submitted_password)

  end

  def self.authenticate(email, submitted_password)
     user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)

  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)

    #return nil  if user.nil?
    #return user if user.salt == cookie_salt

    (user && user.salt == cookie_salt) ? user : nil

  end


  private

  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt(password)
  end

  def encrypt(string)
      secure_has("#{salt}--#{string}")
  end

  def make_salt
    secure_has("#{Time.now.utc}--#{password}")
  end

  def secure_has(string)
     Digest::SHA2.hexdigest(string)
  end

end