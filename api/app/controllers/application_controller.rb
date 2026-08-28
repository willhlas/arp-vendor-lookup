class ApplicationController < ActionController::API
  rescue_from StandardError, with: :render_unexpected_error

  private

  def render_unexpected_error(exception)
    Rails.logger.error("Unhandled exception: #{exception.class}: #{exception.message}")
    render json: { error: "unexpected server error" }, status: :internal_server_error
  end
end
