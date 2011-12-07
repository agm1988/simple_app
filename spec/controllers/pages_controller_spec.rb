require 'spec_helper'

describe PagesController do
  render_views

  before(:each) do
    @base_title = "Ruby on Rails Tutorial Sample App |"
  end

  describe "GET 'home'" do
    it "should be successful" do
      get 'home'
      response.should be_success
    end

    it "should have title home" do
      get 'home'
      response.should have_selector("title", :content => @base_title + " Home")
    end
  end

  describe "GET 'contact'" do
    it "should be successful" do
      get 'contact'
      response.should be_success
    end

    it "should have right title" do
      get 'contact'
      response.should have_selector("title", :content => " | Contact")
    end
  end
  
    describe "GET 'about'" do
    it "should be successful" do
      get 'about'
      response.should be_success
    end

    it "should have right title" do
      get 'about'
      response.should have_selector("title", :content => " | About")
    end
    end


  describe "Get 'help'" do
    it "should be successful" do
      get 'help'
      response.should be_success
    end
    it "should have right title" do
      get 'help'
      response.should have_selector("title", :content => " | Help")
    end
  end



end
