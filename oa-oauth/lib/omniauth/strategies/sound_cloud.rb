require 'omniauth/oauth'
require 'multi_json'

module OmniAuth
  module Strategies
    #
    # Authenticate to SoundCloud via OAuth and retrieve basic
    # user information.
    #
    # Usage:
    #
    #    use OmniAuth::Strategies::SoundCloud, 'consumerkey', 'consumersecret'
    #

    class SoundCloud < OmniAuth::Strategies::OAuth2
    
      
      def initialize(app, consumer_key = nil, consumer_secret = nil, options = {}, &block)
        client_options = {
          :site => 'https://api.soundcloud.com',
          :authorize_path => 'http://soundcloud.com/connect',
          :access_token_path => 'https://api.soundcloud.com/oauth2/token'
        }

        options.merge!(:response_type => 'code', :grant_type => 'authorization_code')

        super(app, :soundcloud, consumer_key, consumer_secret, client_options, options, &block)
      end

      def auth_hash
        OmniAuth::Utils.deep_merge(super, {
          'uid' => user_hash['id'],
          'user_info' => user_info,
          'extra' => {'user_hash' => user_hash}
        })
      end

      def user_info
        user_hash = self.user_hash
        {
          'name' => user_hash['full_name'],
          'nickname' => user_hash['username'],
          'location' => user_hash['city'],
          'description' => user_hash['description'],
          'image' => user_hash['avatar_url'],
          'urls' => {'Website' => user_hash['website']}
        }
      end
      

      def user_hash
        @user_hash ||= MultiJson.decode(@access_token.get('/me.json'))
      end
    end
  end
end
