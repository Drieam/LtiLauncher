# frozen_string_literal: true

require 'administrate/base_dashboard'

class ToolDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    auth_server: Field::BelongsTo,
    id: Field::String,
    name: Field::String,
    description: Field::Text,
    icon_url: Field::String,
    client_id: Field::String,
    open_id_connect_initiation_url: Field::String,
    target_link_uri: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    launch_url: LaunchesField
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    name
    client_id
    target_link_uri
    auth_server
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    auth_server
    id
    name
    description
    icon_url
    client_id
    open_id_connect_initiation_url
    target_link_uri
    created_at
    updated_at
    launch_url
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    auth_server
    name
    description
    icon_url
    client_id
    open_id_connect_initiation_url
    target_link_uri
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

  # Overwrite this method to customize how tools are displayed
  # across all pages of the admin dashboard.

  def display_resource(tool)
    tool.name
  end
end
