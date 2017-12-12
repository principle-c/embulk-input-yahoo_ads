module Embulk
  module Input
    module YahooAds
      class Plugin < InputPlugin
        ::Embulk::Plugin.register_input("yahoo_ads", self)

        def self.transaction(config, &control)
          # configuration code:
          task = {
            :location => config.param("location", :string),
            :version => config.param("version", :string),
            :license => config.param("license", :string),
            :api_account => config.param("api_account", :string),
            :api_password => config.param("api_password", :string),
            :namespace => config.param("namespace", :string),
            :columns => config.param("columns", :array),
            :account_id => config.param("account_id", :string),
            :report_type => config.param("report_type", :string),
            :date_range => {
              :min => config.param("date_range_min", :string),
              :max => config.param("date_range_max", :string),
            },
          }

          columns = task[:columns].map do |colname|
            column = Column.all.find{|c| c[:request_name] == colname}
            ::Embulk::Column.new(nil, colname, column[:type])
          end

          resume(task, columns, 1, &control)
        end

        def self.resume(task, columns, count, &control)
          task_reports = yield(task, columns, count)

          next_config_diff = {}
          return next_config_diff
        end

        def init
        end

        def run
          auth_config = AuthConfig.new({
            :location => task["location"],
            :version => task["version"],
            :license => task["license"],
            :api_account => task["api_account"],
            :api_password => task["api_password"],
            :namespace => task["namespace"],
          })
          ReportClient.new(task["account_id"], auth_config).run({
            :report_type => task["report_type"],
            :date_range_type => 'CUSTOM_DATE',
            :date_range => {
              :start_date => task["date_range"]["min"],
              :end_date => task["date_range"]["max"],
            },
            :fields => task["columns"]
          }).each do |row|
            page_builder.add(task["columns"].map do|column|
              col = Column.all.find{|c| c[:request_name] == column}
              row.send(col[:xml_name])
            end)
          end
          page_builder.finish

          task_report = {}
          return task_report
        end
      end
    end
  end
end
