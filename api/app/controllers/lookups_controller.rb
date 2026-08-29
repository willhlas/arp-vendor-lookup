class LookupsController < ApplicationController
  def index
    if params[:mac].nil?
      recent_lookups
    else
      lookup_by_mac
    end
  end

  private

  def lookup_by_mac
    lookup = VendorLookupService.new(params[:mac], params[:ip]).call
    render json: lookup, status: lookup.found? ? :ok : :not_found
  rescue VendorLookupService::InvalidMacError, VendorLookupService::InvalidIpError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue VendorLookupService::UpstreamRateLimitedError => e
    render json: { error: e.message }, status: :too_many_requests
  rescue VendorLookupService::UpstreamUnavailableError => e
    render json: { error: e.message }, status: :service_unavailable
  rescue VendorLookupService::UpstreamBadResponseError => e
    render json: { error: e.message }, status: :bad_gateway
  end

  def recent_lookups
    render json: Lookup.recent
  end
end
