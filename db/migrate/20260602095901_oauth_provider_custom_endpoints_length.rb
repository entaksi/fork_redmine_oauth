# frozen_string_literal: true

# Redmine plugin OAuth
#
# The input fields for "OAuth endpoint" and "Token endpoint" enforce a maximum length of 80 characters.
# This is insufficient for real-world IdP endpoints.

# OauthProviders DB migration
class OauthProviderCustomEndpointsLength < ActiveRecord::Migration[7.2]
  def up
    change_column :oauth_providers, :custom_auth_endpoint, :string, null: true, limit: 256
    change_column :oauth_providers, :custom_token_endpoint, :string, null: true, limit: 256
    change_column :oauth_providers, :custom_profile_endpoint, :string, null: true, limit: 256
  end
end
