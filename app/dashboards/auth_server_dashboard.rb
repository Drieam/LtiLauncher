# frozen_string_literal: true

require 'administrate/base_dashboard'

class AuthServerDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    tools: Field::HasMany,
    id: Field::String,
    name: Field::String,
    openid_configuration_url: Field::String,
    authorization_endpoint: Field::String,
    token_endpoint: Field::String,
    client_id: Field::String,
    client_secret: Field::Password,
    context_jwks_url: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    name
    authorization_endpoint
    context_jwks_url
    tools
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    name
    openid_configuration_url
    authorization_endpoint
    token_endpoint
    client_id
    context_jwks_url
    tools
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    name
    openid_configuration_url
    client_id
    client_secret
    context_jwks_url
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how auth servers are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(auth_server)
    auth_server.name
  end
end
