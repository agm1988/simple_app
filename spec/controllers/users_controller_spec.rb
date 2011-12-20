require 'spec_helper'

describe UsersController do
  render_views

  describe "get show" do
    before(:each) do
      @user = Factory(:user)

    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end

    it "should include user's name'" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "shoul have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end

    it "should show user's microposts'" do
       mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
       mp2 = Factory(:micropost, :user => @user, :content => "Baz quxx")
      get :show, :id => @user
      response.should have_selector("span.content", :content => mp1.content)
      response.should have_selector("span.content", :content => mp2.content)
    end

  end


  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  #end

  it "should have right title" do
    get 'new'
    response.should have_selector("title", :content => "Sign up")
  end

  end  #

  describe "Post create" do
    describe "failure" do
      before(:each) do
        @attr ={:name => "", :email => "", :password => "", :password_confirmation => "" }

      end

        it "should not create user" do
          lambda do
            post :create, :user => @attr
          end.should_not change(User, :count)
        end

        it "should have right title" do
          post :create, :user => @attr
          response.should have_selector("title", :content => "Sign up")
        end

        it "should render the 'new' page" do
          post :create, :user => @attr
          response.should render_template('new')
        end

    end

    describe "success" do
      before(:each) do
        @attr = {:name => "New User", :email => "user@example.com", :password => "foobar", :password_confirmation => "foobar"}

      end

        it "should create user" do
          lambda do
            post :create, :user => @attr
          end.should change(User, :count).by(1)
        end

        it "should redirect to user show page" do
          post :create, :user => @attr
          response.should redirect_to(user_path(assigns(:user)))
        end

        it "should have a success message" do
          post :create, :user => @attr
          flash[:success].should =~ /Welcome to the sample app/i
        end

        it "shoud sign the user in" do
          post :create, :user => @attr
          controller.should be_signed_in
        end

    end

    describe "exercises" do
      it "should have name field" do
        get :new
        response.should have_selector("input[name='user[name]'][type='text']")

      end

      it "should have email field" do
        get :new
        response.should have_selector("input[name='user[email]'][type='text']")

      end

      it "should have password field" do
        get :new
        response.should have_selector("input[name='user[password]'] [type='password']")
      end

      it "should have confirmation field" do
        get :new
        response.should have_selector("input [name='user[password_confirmation]'] [type='password']")
      end

    end

  end

  describe "get 'edit'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)

    end

    it "should be successfuk" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have the link to change the gravatar" do
      get :edit, :id => @user
      response.should have_selector("a", :href => "http://gravatar.com/emails", :content => "change")

    end

  end

  describe "put 'update'" do
    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)

    end

      describe "failure" do
        before(:each) do
          @attr = {:email => "", :name => "", :password => "", :password_confirmation => ""}

        end
        it "should render the 'edit' page" do
          put :update, :id => @user, :user => @attr
          response.should render_template('edit')
        end
        it "should have the right title" do
          put :update, :id => @user, :user => @attr
          response.should have_selector("title", :content => "Edit user")
        end

      end

      describe "success" do
        before(:each) do
          @attr = {:email => "user@example.org", :name => "New Name", :password => "barbaz", :password_confirmation => "barbaz"}

        end
        it "should change user attributes" do
          put :update, :id => @user, :user => @attr
          @user.reload
          @user.name.should == @attr[:name]
          @user.email.should == @attr[:email]
        end
        it"should redirect to users show page" do
          put :update, :id => @user, :user => @attr
          response.should redirect_to(user_path(@user))
        end
        it "should have flash message" do
          put :update, :id => @user, :user => @attr
          flash[:success].should =~ /updated/
        end

      end


  end

  describe "authentication of edit/update pages" do
    before(:each) do
      @user = Factory(:user)
    end

    describe "for non signed in users" do
      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end
      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end

    end

    describe "for signed in users" do
      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end
      it "should require mutching users for edit" do
         get :edit, :id => @user
        response.should redirect_to(root_path)
      end
      it "should require matching users for update" do
         put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end

    end
  end

  describe "Get 'index'" do
    describe "for non signed in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end

    end
    describe "for signed in users" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :name => "Bob", :email => "another@example.com")
        third = Factory(:user, :name => "Ben", :email => "another@example.net")

        @users = [@user, second, third]

        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
      end
      it "should be successful" do
        get :index
        response.should be_success
      end
      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end
      it "should have element for each user" do
         get :index
         @users.each do |user|
           response.should have_selector("li", :content => user.name)
         end
      end

      it "should have an element for eachuser" do
        get :index
        @users[0..2].each do |user|
           response.should have_selector("li", :content => user.name)
        end
      end
      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("a", :href => "/users?page=2", :content => "2")
        response.should have_selector("a", :href => "/users?page=2", :content => "Next")
      end

    end

  end

  describe "DELETE 'destroy'" do

      before(:each) do
        @user = Factory(:user)
      end

      describe "as a non-signed-in user" do
        #it "should deny access" do
        #  delete :destroy, :id => @user
        #  response.should redirect_to(signin_path)
        #end
      end

      describe "as a non-admin user" do
        it "should protect the page" do
          test_sign_in(@user)
          delete :destroy, :id => @user
          response.should redirect_to(root_path)
        end
      end

      describe "as an admin user" do

        before(:each) do
          admin = Factory(:user, :email => "admin@example.com", :admin => true)
          test_sign_in(admin)
        end

        it "should destroy the user" do
          lambda do
            delete :destroy, :id => @user
          end.should change(User, :count).by(-1)
        end

        it "should redirect to the users page" do
          delete :destroy, :id => @user
          response.should redirect_to(users_path)
        end
      end
  end

   describe "micropost association" do
     before(:each) do
        @user = Factory(:user)
       #@user = User.create(@attr)
       @mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
       @mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
      #@mp1 = @user.microposts.create!(:content => "1")
      #@mp2 = @user.microposts.create!(:content => "2")
     end


     it "should have a microposts attribute" do
         @user.should respond_to(:microposts)
       end

       it "should have the right microposts in the right order" do
         @user.microposts.should == [@mp2, @mp1]
       end

     it "should destroy associated microposts" do
        @user.destroy
        [@mp1, @mp2].each do |micropost|
          Micropost.find_by_id(micropost.id).should be_nil
        end
     end


   end

  describe "follow pages" do
    describe "when not signed in" do
       it "should protect following" do
         get :following, :id => 1
         response.should redirect_to(signin_path)
       end
      it "should protect 'followers'" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end

    describe "when signed in" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end
      it "should show user following" do
        get :following, :id => @user
        response.should have_selector("a", :href => user_path(@other_user), :content => @other_user.name)
      end
      it "should show user followers" do
        get :followers, :id => @other_user
        response.should have_selector("a", :href => user_path(@user), :content => @user.name)
      end

    end

  end



end
