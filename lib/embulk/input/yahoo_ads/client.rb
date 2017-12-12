module Embulk
  module Input
    module YahooAds
      class Client
        def initialize(account_id, auth_config)
          @account_id = account_id
          @auth_config = auth_config
          @locationService = LocationService.build(account_id, auth_config)
        end

        def invoke(service_name, action, params)
          s = self.service(service_name)
          ::Embulk.logger.info "SOAP Request: #{s.wsdl.document}"
          s.call(action, params).body
        end

        def service(name)
          ::Savon::Client.new({
            wsdl: "https://#{@auth_config.location}/services/#{@auth_config.version}/#{name}?wsdl",
            endpoint: "https://#{@locationService.invoke}/services/#{@auth_config.version}/#{name}",
            namespace: @auth_config.namespace,
              soap_header: {
              "tns:RequestHeader": {
                "tns:license": @auth_config.license,
                "tns:apiAccountId": @auth_config.api_account,
                "tns:apiAccountPassword": @auth_config.api_password,
              }
            }
          })
        end
      end
    end
  end
end
