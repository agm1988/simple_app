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

require 'spec_helper'

describe User do
  # pending "add some examples to (or delete) #{__FILE__}"
  before(:each) do
    @attr = { :name => "Example User",
              :email => "user@example.com",
              :password => "foobar",
              :password_confirmation => "foobar"
    }
  end

  it "should create new instance given valid attributes" do
      User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name => ""))
    no_name_user.should_not be_valid
  end

  it "should require email address" do
    no_mail_address = User.new(@attr.merge(:email => ""))
    no_mail_address.should_not be_valid
  end

  it "should not be valid long name" do
    long_name = "a" * 51
    long_name_user = User.new(@attr.merge(:name => long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email address" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject duplicate email address up to case" do
    upcase_email  = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcase_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
    end

    it "should reject short password" do
      short = "a" * 5
      User.new(@attr.merge(:password => short, :password_confirmation => short)).should_not be_valid
    end

    it "should reject long passwords" do
      long = "a" * 41
      User.new(@attr.merge(:password => long, :password_confirmation => long)).should_not be_valid
    end

  end

  describe "password encryption" do
    before(:each) do
      @user = User.create!(@attr)

    end

    it "should have encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

  end

  describe "has_password? method" do

  before(:each) do
      @user = User.create!(@attr)

  end

    it "it should be true if password match" do
    @user.has_password?(@attr[:password]).should be_true
    end

    it "it should be false if password dont match" do
      @user.has_password?("invalid").should be_false
    end

  end

  describe "authenticate method" do

  #before(:each) do
  #    @user = User.create!(@attr)
  #
  #end

    it "should return nil on email/password mismatch" do
      wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
      wrong_password_user.should be_nil
    end

    it "should return nil for an email address with no user" do
        nonexisten_user = User.authenticate("bar@foo.com", @attr[:password])
        nonexisten_user.should be_nil
    end
    it "should return user on email/password match" do
      matchin_user = User.authenticate(@attr[:email], @attr[:password])
      matchin_user.should == @user
    end
  end

  describe "admin attribute" do
    before(:each) do
      @user = User.create!(@attr)
    end
    it "should respond to admin" do
      @user.should respond_to(:admin)
    end
    it "should not be admin by default" do
      @user.should_not be_admin
    end
    it "should be convertible to admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end

  end

  describe "micropost associations" do

    before(:each) do
      @user = User.create(@attr)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end

    describe "status feed" do
      it "should have a feed do" do
        @user.should respond_to(:feed)
      end
      #it "should include user's microposts'" do
      #  @user.feed.include?(@mp1).should be_true
      #  @user.feed.include?(@mp2).should be_true
      #end

      it "should not include different users's microposts'" do
        mp3 = Factory(:micropost, :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.include?(mp3).should be_false
      end


    end

    describe "status feed" do
      it "should have a feed" do
        @user.should respond_to(:feed)
      end
      it "should include a users microposts" do
        @mp1 = @user.microposts.create!(:content => "ssss")
        @mp2 = @user.microposts.create!(:content => "sssszxZxz")
        @user.feed.should include(@mp1)
        @user.feed.should include(@mp2)
      end
      it "should not ionclude different users microposts" do
        mp3 = Factory(:micropost, :user => Factory(:user, :email => Factory.next(:email)))
        @user.feed.should_not include(mp3)
      end
      it "should include microposts of followed users" do
        followed = Factory(:user, :email => Factory.next(:email))
        mp3 = Factory(:micropost, :user => followed)
        @user.follow!(followed)
        @user.feed.should include(mp3)
      end

    end


  end

  describe "Relationship" do
    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end
    it "should have a relationship method" do
      @user.should respond_to(:relationships)
    end

  end

    describe "relationship" do
    before(:each) do
    @user = User.create!(@attr)
    @followed = Factory(:user)
    end

    it "should have a relationship method" do
      @user.should respond_to(:relationships)
    end
    it "should have a following method" do
      @user.should respond_to(:following)
    end

    it "should have a following? method" do
      @user.should respond_to(:following?)
    end
    it "should respond to follow! method" do
      @user.should respond_to(:follow!)
    end
    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end
    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end

    it "should have an unfollow! method" do
      @followed.should respond_to(:unfollow!)
    end
    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end

    it "should have a reverse relationship method" do
      @user.should respond_to(:reverse_relationships)
    end
    it "should have a followers method" do
      @user.should respond_to(:followers)
    end
    it "should include followers in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
  end





end
