class ApplicationController < ActionController::Base

  def authenticate(section)
    username = ENV["AUTH_USERNAME"]
    password = ENV["AUTH_PASSWORD"]

    if username.blank? || password.blank?
      env_credentials = Rails.application.credentials[Rails.env.to_sym]
      return true if env_credentials.nil?

      authentication = env_credentials[:authentication]
      return true if authentication.nil?

      section = authentication[section]
      return true if section.nil?

      username = section[:username]
      password = section[:password]
    end

    authenticate_or_request_with_http_basic do |u, p|
      u == username && p == password
    end
  end

  rescue_from ActionController::ParameterMissing do |e|
    render plain: 'Invalid Parameters'
  end

end
