require "savon"
module Embulk
  module Input
    module YahooAds
      class LocationService < ::Savon::Client
        def invoke
          return @response unless @response.nil?
          ::Embulk.logger.info "SOAP Request: #{self.wsdl.document}"
          @response ||= self.call(:get, message: {
            account_id: @account_id,
          }).body[:get_response][:rval][:value].to_s
        end

        def self.build(account_id, auth_config)
          service = self.new({
            wsdl: "https://#{auth_config.location}/services/#{auth_config.version}/LocationService?wsdl",
            namespace: auth_config.namespace,
              soap_header: {
                "tns:RequestHeader": {
                  "tns:license" => auth_config.license,
                  "tns:apiAccountId" => auth_config.api_account,
                  "tns:apiAccountPassword" => auth_config.api_password,
                }
              },
          })
          service.account_id = account_id
          service
        end

        def account_id=(val)
          @account_id = val
        end
      end
    end
  end
end
