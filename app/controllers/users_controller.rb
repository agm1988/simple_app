class UsersController < ApplicationController

  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Sign up"
    redirect_to(root_path) if current_user
  end

  def create
    redirect_to(root_path) if current_user
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      # Обработка успешного сохранения.
      redirect_to @user
      flash[:success] = "Welcome to the Sample App!"
    else
      @title = "Sign up"
      #---------------------------------
      @user.password = nil
      @user.password_confirmation = nil
      #---------------------------------
      render('new')
    end
  end

  def edit
    @title = "Edit user"
    @user = User.find(params[:id])   #
  end

  def update
    @user = User.find(params[:id])        #
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    #if current_user.admin?
    #  flash[:error] = "It is admin!"
    #  redirect_to(root_path)
    #else
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
    #end
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render('show_follow')
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render('show_follow')
  end


  private

  #def authenticate
  #   deny_access unless signed_in?
  #end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)

  end

  def admin_user
    #if current_user == nil
    #  redirect_to(signin_path)
    #else

    redirect_to(root_path) unless current_user.admin?
    #end
  end


end
