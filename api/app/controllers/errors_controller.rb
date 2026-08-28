class ErrorsController < ApplicationController
  def not_found
    render json: { error: "no route matches #{request.method} #{request.path}" }, status: :not_found
  end
end
