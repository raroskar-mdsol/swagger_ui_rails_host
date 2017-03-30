class ApplicationController < ActionController::API

  before_action :enforce_json_request_format
  before_action :set_and_log_requesting_app

  before_action :set_cache_control_header

  class GenericNotFoundError < StandardError; end
  class GenericInvalidInputError < StandardError; end

  rescue_from "StandardError" do |e|
    error_cause = {
        ActionController::UnpermittedParameters => :unprocessable_entity,
        ActionController::ParameterMissing => :unprocessable_entity,
        ApplicationController::GenericNotFoundError => :not_found,
        ApplicationController::GenericInvalidInputError => :unprocessable_entity,
        ArgumentError => :unprocessable_entity
    }[e.exception.class]
    error_cause ||= :internal_server_error
    case error_cause
      when :internal_server_error
        Rails.logger.error e.exception.try(:to_s).try(:to_json)
        Rails.logger.error e.backtrace.join("\n")
        Rails.logger.warn "Returning an error with status #{error_cause}"
        render_status(error_cause, error_hash('base', 'Error message stored in logs'))
      when :not_found
        Rails.logger.warn e.message
        msg = ENV['EUREKA_STAGE'] == 'sandbox' ? "#{e.class}: #{e.message}" : 'Resource not found'
        render_status(error_cause, error_hash('base', msg))
      else
        Rails.logger.warn e.message
        Rails.logger.warn "Returning an error with status #{error_cause}"
        render_status(error_cause, error_hash('base', e.message))
    end
  end

  private

  def render_status(status, errors_hash)
    render :json => errors_hash, status: status
  end

  # Returns a keyed hash with error messages as per our API best practices
  # (The first keys is "errors", followed by a keyed by fields and an array of
  # string messages.  The second param can either be an string, or an array of
  # strings.
  def error_hash(key, messages)
    messages = [messages] unless messages.is_a?(Array)
    {"errors" => {key => messages}}
  end

  def set_and_log_requesting_app
    # Thread.current[:requesting_app_urn] = Mdsol::URI.generate(request.env['mauth.app_uuid'], :resource => :apps).to_s
    # Rails.logger.info("Requesting app uuid: #{request.env['mauth.app_uuid']};"\
    #                   " controller: #{controller_name}; action: #{action_name}")
  end

  # Set the Cache-Control header on the response to private.  THIS SHOULD BE OVERRIDDEN IN THE
  # DERIVED CLASS IF CACHE EXPIRY SHOULD BE SET DIFFERENTLY ON CERTAIN RESOURCES.
  def set_cache_control_header
    # time unit is seconds
    # Expires_in should be changed in cloned services to something more reasonable for that service
    expires_in 0, :public => false
  end

  def enforce_json_request_format
    render json: {msg:  'Request format must be application/json'}, status: 406 if request.format && request.format.to_s != 'application/json'
  end
end
