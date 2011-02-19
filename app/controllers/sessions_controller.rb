# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # render new.rhtml
  def new
  end
  
  def create
    logout_keeping_session!
    user=nil
    if using_open_id?
      user = open_id_authentication params[:openid_identifier]
    else
      user = User.authenticate(params[:login], params[:password])
      if(!user)
        note_failed_signin "Couldn't log you in as '#{params[:login].blank? ? params[:openid_identifier] : params[:login]}'"
      end
    end
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag
      flash[:notice] = "Logged in successfully"
      if(request.env[Rack::OpenID::RESPONSE])
        redirect_back_or_default('/')
      end
    else
      self.current_user = nil
      @login       = params[:login]
      @remember_me = params[:remember_me]
      @open_id = params[:openid_identifier]
      if(request.env[Rack::OpenID::RESPONSE])
        render :action => 'new'
      else
        #redirect_back_or_default('/')
      end
    end
  end
  
  def destroy
    logout_killing_session!
    redirect_back_or_default('/', :notice => "You have been logged out.")
  end
  
  protected
  
  
  def open_id_authentication(identity_url = nil)
    # Pass optional :required and :optional keys to specify what sreg fields you want.
    # Be sure to yield registration, a third argument in the #authenticate_with_open_id block.
    user=nil
    authenticate_with_open_id(identity_url, :required => [ :nickname, :email ], :optional => :fullname) do |result, identifier, registration|
      case result.status
        when :missing
        note_failed_signin "Sorry, the OpenID server couldn't be found"
        when :invalid
        note_failed_signin "Sorry, but this does not appear to be a valid OpenID"
        when :canceled
        note_failed_signin "OpenID verification was canceled"
        when :failed
        note_failed_signin "Sorry, the OpenID verification failed"
        when :successful
        if (user = User.where("open_id LIKE ?", "%#{identifier}%").first) != nil
          flash[:notice] = "Logged in successfully with identity URL \""+identifier+"\""
        else
          user = User.new
          user.open_id=identifier
          user.save(false)
          flash[:notice] = "First time login with identity URL \""+identifier+"\""
        end
        #redirect_back_or_default('/', :notice => "Logged in successfully")
      end
      #redirect_back_or_default('/')
    end
    return user
  end
  def note_failed_signin(msg = nil)
    flash[:error] = msg || "Couldn't log you in as '#{params[:login]}'"
    logger.warn(msg || "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}")
  end
  
end
