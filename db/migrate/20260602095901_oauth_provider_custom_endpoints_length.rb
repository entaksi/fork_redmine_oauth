# frozen_string_literal: true

# Redmine plugin OAuth
#
# Widen client_id: Google and other providers use IDs longer than varchar(60).
# Widen site as well to keep both URL-related fields consistent.

# OauthProviders DB migration
class OauthProviderCustomEndpointsLength < ActiveRecord::Migration[7.2]
  def up
    change_column :oauth_providers, :custom_auth_endpoint, :string, null: true, limit: 256
    change_column :oauth_providers, :custom_token_endpoint, :string, null: true, limit: 256
  end

  def down
    change_column :oauth_providers, :custom_auth_endpoint, :string, null: true, limit: 80
    change_column :oauth_providers, :custom_token_endpoint, :string, null: true, limit: 80
  end
end
