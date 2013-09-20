# Copyright (C) 2012-2013 Zammad Foundation, http://zammad-foundation.org/

class Sso < ApplicationLib

=begin

authenticate user via username and password

  result = Sso.check( params )

returns

  result = user_model # if authentication was successfully

=end

  def self.check(params)

    # use std. auth backends
    config = [
      {
        :adapter => 'Sso::Env',
      },
      {
        :adapter => 'Sso::Otrs',
      },
    ]

    # added configured backends
    Setting.where( :area => 'Security::SSO' ).each {|setting|
      if setting.state[:value]
        config.push setting.state[:value]
      end
    }

    # try to login against configure auth backends
    user_auth = nil
    config.each {|config_item|
      next if !config_item[:adapter]

      # load backend
      backend = self.load_adapter( config_item[:adapter] )
      return if !backend

      user_auth = backend.check( params, config_item )

      # auth ok
      if user_auth

        # remember last login date
        user_auth.update_last_login

        # reset login failed
        user_auth.login_failed = 0
        user_auth.save

        return user_auth
      end
    }
    return

  end
end
