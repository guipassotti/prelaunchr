class UsersController < ApplicationController

  # TEMPORARILY REMOVE REDIRECTION IF COOKIE EXISTS
  # before_filter :skip_first_page, :only => :new

  def new
    @bodyId = 'home'
    @is_mobile = mobile_device?
    @user = User.new
  end

  def create

    email = params[:user][:email]
    user = User.find_by_email(email)

    if user.blank? && email.present?

      cur_ip = IpAddress.find_by_address(request.env['HTTP_X_FORWARDED_FOR'])

      if cur_ip.blank?
        cur_ip = IpAddress.create(
          :address => request.env['HTTP_X_FORWARDED_FOR'],
          :count => 0
        )
      end

      if cur_ip.count > 2
        # TEMPORARILY REMOVE REDIRECTION IF SIGNUPS > 2
        # return redirect_to root_path
      else
        cur_ip.count = cur_ip.count + 1
        cur_ip.save
      end

      user = User.new(email: email)
      referred_by = User.find_by_referral_code(cookies[:h_ref])

      if referred_by.present?
        user.referrer = referred_by
      end

      if user.save
        cookies[:h_email] = { value: user.email }
        redirect_to '/refer-a-friend'
      else
        flash[:error] = "Something went wrong!"
        redirect_to root_path
      end

    else
      flash[:error] = "Something went wrong!"
      redirect_to root_path
    end
  end

  def refer
    @bodyId = 'refer'
    @is_mobile = mobile_device?
    email = cookies[:h_email]
    @user = User.find_by_email(email)
    if @user.blank?
      flash[:error] = "Something went wrong!"
      redirect_to root_path
    end
  end

  def policy
        
  end  

  def redirect
    redirect_to root_path, :status => 404
  end

  private 

    def skip_first_page
      if !Rails.application.config.ended
        email = cookies[:h_email]
        if email and !User.find_by_email(email).nil?
          redirect_to '/refer-a-friend'
        else
          cookies.delete :h_email
        end
      end
    end

end
