class LookupsController < ApplicationController
  def index
    if params[:mac].present?
      lookup_by_mac
    else
      recent_lookups
    end
  end

  private

  def lookup_by_mac
    lookup = VendorLookupService.new(params[:mac]).call
    render json: lookup, status: lookup.found? ? :ok : :not_found
  rescue VendorLookupService::InvalidMacError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue VendorLookupService::UpstreamError => e
    render json: { error: e.message }, status: :bad_gateway
  end

  def recent_lookups
    render json: Lookup.recent
  end
end
