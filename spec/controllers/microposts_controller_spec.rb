require 'spec_helper'

describe MicropostsController do
      render_views

  describe "access control" do
    it "should deny access to post create" do
      post :create
      response.should redirect_to(signin_path)
    end
    it "deny access to destroy" do
      delete :destroy, :id => 1
      response.should redirect_to(signin_path)

    end

  end

  describe "post 'create'" do
    before(:each) do
      @user = test_sign_in(Factory(:user))

    end
    describe "failure" do
      before(:each) do
        @attr = {:content => ""}

      end
      it "should not create micropost" do
         lambda do
           post :create, :micropost => @attr
         end.should_not change(Micropost, :count)
      end
      #it "should render the home page" do
      #  post :create, :micropost => @attr
      #  response.should render_template('pages/home')
      #end


    end
    describe "success" do
      before(:each) do
        @attr = {:content => "lorem ipsum"}

      end
      #it "should create a micropost" do
      #      lambda do
      #        post :create, :micropost => @attr
      #      end.should change(Micropost, :count).by(1)
      #    end

      it "should redurect to home page" do
        post :create, :micropost => @attr
        response.should redirect_to(root_path)
      end
      #it "should have flash message" do
      #  post :create, :micropost => @attr
      #  flash[:success].should =~ /micropost created/i
      #end

    end

  end

  describe "Delete 'destroy'" do
    describe "for an unauthorized user" do
      before(:each) do
        @user = Factory(:user)
        wrong_user = Factory(:user, :email => Factory.next(:email))
        test_sign_in(wrong_user)
        @micropost = Factory(:micropost, :user => @user)
      end
      it "should deny access" do
        delete :destroy, :id => @micropost
        response.should redirect_to(root_path)
      end

    end

    describe "for an uathorized user" do
      before(:each) do
        @user = test_sign_in(Factory(:user))
        @micropost = Factory(:micropost, :user => @user)

      end
      it "should destroy micropost" do
        lambda do
          delete :destroy, :id => @micropost
        end.should change(Micropost, :count).by(-1)
      end

    end

  end

end
