# frozen_string_literal: true

class Tool < ApplicationRecord
  belongs_to :auth_server, inverse_of: :tools
  has_many :nonces, inverse_of: :tool, dependent: :delete_all

  validates :name, presence: true
  validates :client_id, presence: true, uniqueness: true
  validates :open_id_connect_initiation_url, presence: true, format: URI.regexp(%w[http https])
  validates :target_link_uri, presence: true, format: URI.regexp(%w[http https])
  validates :icon_url, format: URI.regexp(%w[http https]), allow_blank: true

  ##
  # Get the redirection url for the OIDC validation cycle of the tool.
  # The provided login_hint should be returned by the tool in the callback.
  def signed_open_id_connect_initiation_url(login_hint:)
    URI(open_id_connect_initiation_url).tap do |uri|
      uri.query = {
        iss: Rails.application.secrets.issuer,
        login_hint: login_hint,
        target_link_uri: target_link_uri
        # lti_message_hint: 'xxx'
      }.to_query
    end
  end

  # The base launch_url for this tool
  def launch_url
    Rails.application.routes.url_helpers.launch_url(tool_client_id: client_id)
  end

  # Make sure the correct attributes are serializeable
  def attributes
    super.merge('launch_url' => nil)
  end
end
