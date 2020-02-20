class ApplicationController < ActionController::Base

  def authenticate(section)
    env_credentials = Rails.application.credentials[Rails.env.to_sym]
    return true if env_credentials.nil?

    authentication = env_credentials[:authentication][section]
    return true if authentication.nil?

    authenticate_or_request_with_http_basic do |u, p|
      u == authentication[:username] && p == authentication[:password]
    end
  end

  rescue_from ActionController::ParameterMissing do |e|
    render plain: 'Invalid Parameters'
  end

end
