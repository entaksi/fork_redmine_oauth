# frozen_string_literal: true

# Redmine plugin OAuth
#
# Karel Pičman <karel.picman@kontron.com>
#
# This file is part of Redmine OAuth plugin.
#
# Redmine OAuth plugin is free software: you can redistribute it and/or modify it under the terms of the GNU General
# Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# Redmine OAuth plugin is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
# the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with Redmine OAuth plugin. If not, see
# <https://www.gnu.org/licenses/>.

module RedmineOauth
  module Patches
    # AccountController patch
    module SudoModeControllerPatch
      ################################################################################################################
      # Overridden methods

      # handle sudo password form submit
      def process_sudo_form
        if params[:oauth_sudo_mode_ok].present?
          Redmine::SudoMode.active!
          #else
          #flash.now[:error] = l(:notice_account_wrong_password)
        end
      end

      # display the sudo password form
      def render_sudo_form(param_names)
        @oauth_provider = OauthProvider.find_by(id: session[:oauth_login])
        return super unless @oauth_provider

        if param_names.blank?
          # This list was copied from the original `require_sudo_mode`, but without `_method`.
          param_names = params.keys - %w(id action controller authenticity_token utf8)
        end

        back_url = url_for(**params.slice(:controller, :action, :id, :project_id).to_unsafe_hash)

        session[:oauth_sudo_mode] = {
          back_url: back_url,
          params: params.slice(*param_names, '_method').to_unsafe_hash,
          options: {
            method: request.method_symbol,
            authenticity_token: :auto,
          }
        }

        # @sudo_form ||= SudoMode::Form.new
        # @sudo_form.original_fields = params.slice(*param_names)
        #original_fields = params.slice(*param_names)
        #original_fields[:_action] = params[:action]
        # a simple 'render "oauth_sudo_mode/new"' works when used directly inside an
        # action, but not when called from a before_action:
        no_store
        respond_to do |format|
          format.html { render 'oauth_sudo_mode/new' }
          format.js   { render 'oauth_sudo_mode/new' }
        end
      end

      # def require_sudo_mode(*param_names)
      #   # return super unless RedmineOidc.settings.enabled
      #   # return super unless RedmineOidc.settings.sudo_mode_reauthenticate
      #
      #   return true if Redmine::SudoMode.active?
      #
      #   # if OidcSession.spawn(session).auth_time > Redmine::SudoMode.timeout.ago.to_i
      #   #   logger.info "Activating sudo mode for user #{User.current.login}"
      #   #   Redmine::SudoMode.active!
      #   # end
      #
      #   # Note: This method must be called even right after `Redmine::SudoMode.active!`
      #   # because despite its name, it has side effects!
      #   #return true if Redmine::SudoMode.active?
      #
      #   oauth_provider = OauthProvider.find_by(id: session[:oauth_login])
      #   return super unless oauth_provider
      #
      #   if param_names.blank?
      #     # This list was copied from the original `require_sudo_mode`, but without `_method`.
      #     param_names = params.keys - %w(id action controller authenticity_token utf8)
      #   end
      #
      #   back_url = url_for(**params.slice(:controller, :action, :id, :project_id).to_unsafe_hash)
      #
      #   session[:oauth_sudo_mode] = {
      #     back_url: back_url,
      #     params: params.slice(*param_names).to_unsafe_hash,
      #     options: {
      #       method: request.method_symbol,
      #       authenticity_token: :auto,
      #     }
      #   }
      #
      #   #logger.info "Reauthenticating #{User.current.login} for sudo mode"
      #   redirect_to oauth_path(back_url: back_url, oauth_provider: oauth_provider.id, reauth: true)
      #
      #   false
      # end
    end
  end
end

Redmine::SudoMode::Controller.prepend RedmineOauth::Patches::SudoModeControllerPatch
