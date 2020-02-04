# frozen_string_literal: true

module Api
  module V1
    class ToolsController < ActionController::API
      rescue_from ActiveRecord::RecordNotFound do |e|
        render json: { code: 404, message: "Could not find #{e.model&.underscore || 'record'}" }, status: :not_found
      end

      def index
        auth_server = AuthServer.find(params[:auth_server_id])
        render json: auth_server.tools.to_json(only: %i[name description launch_url icon_url])
      end
    end
  end
end
