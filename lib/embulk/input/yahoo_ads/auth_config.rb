module Embulk
  module Input
    module YahooAds
      class AuthConfig
        def initialize(options)
          @location = options[:location]
          @version = options[:version]
          @license = options[:license]
          @api_account = options[:api_account]
          @api_password = options[:api_password]
          @namespace = options[:namespace]
        end

        def location; @location end
        def version; @version end
        def license; @license end
        def api_account; @api_account end
        def api_password; @api_password end
        def namespace; @namespace end
      end
    end
  end
end
