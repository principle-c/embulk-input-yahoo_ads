require "nokogiri"
require "open-uri"
require "ostruct"
module Embulk
  module Input
    module YahooAds
      class ReportClient < Client
        def run(query)
          report_id = query_report_definition(query)
          ::Embulk.logger.info "Create Report, report_id = #{report_id}"
          report_job_id = query_report_job(report_id)
          ::Embulk.logger.info "Create Report JOB, report_job_id = #{report_job_id}"
          download_url = report_download_url(report_job_id)
          ::Embulk.logger.info "Download Report, URL = #{download_url}"
          xml = xml_parse(download_url)
          remove_report_job(report_job_id)
          ::Embulk.logger.info "Remove Report JOB, report_job_id = #{report_job_id}"
          remove_report_definition(report_id)
          ::Embulk.logger.info "Remove Report, report_id = #{report_id}"
          xml
        end

        private
        def query_report_definition(selector)
          response = self.invoke(:ReportDefinitionService, :mutate, message: {
            :operations => {
              :operator => 'ADD',
              :account_id => @account_id,
              :operand => {
                :account_id => @account_id,
                :report_name => "YahooReport_#{DateTime.now.strftime("%Y%m%d_%H%I%s")}",
                :report_type => nil,
                :fields => [],
                :compress => 'NONE',
                :is_template => 'FALSE',
                :interval_type => 'ONETIME',
                :format => 'XML',
                :language => 'JA',
                :include_zero_impressions => 'FALSE',
                :include_deleted => 'TRUE',
              }.deep_merge(selector)
            }
          })
          if response[:mutate_response][:rval][:values][:operation_succeeded] == false
            error = response[:mutate_response][:rval][:values][:error]
            raise ::Embulk::Input::YahooAds::Error::InvalidEnumError, error.to_json 
          end
          response[:mutate_response][:rval][:values][:report_definition][:report_id].to_s
        end

        def query_report_job(report_id)
          response = self.invoke(:ReportService, :mutate, message: {
            :operations => {
              :operator => 'ADD',
              :account_id => @account_id,
              :operand => {
                :report_id => report_id
              }
            }
          })
          response[:mutate_response][:rval][:values][:report_record][:report_job_id].to_s
        end

        def report_download_url(report_job_id, wait_second = 5)
          sleep(wait_second)
          response = self.invoke(:ReportService, :get, message: {
            :selector => {
              :account_id => @account_id,
              :report_job_ids => [report_job_id]
            }
          })
          status = nil
          if response[:get_response][:rval][:values][:report_record][:status].nil? == false
            status = response[:get_response][:rval][:values][:report_record][:status].to_s
          elsif response[:get_response][:rval][:values][:report_record][:report_job_status].nil? == false
            status = response[:get_response][:rval][:values][:report_record][:report_job_status].to_s
          end
          case status
          when 'COMPLETED' then
            return response[:get_response][:rval][:values][:report_record][:report_download_url].to_s
          when 'IN_PROGRESS' then
            return report_download_url(report_job_id, wait_second * 2)
          when 'WAIT' then
            return report_download_url(report_job_id, wait_second * 2)
          end
        end

        def xml_parse(url)
          xml = Nokogiri::XML(open(url).read)
          columns = xml.css('column').map{|column| column.attribute('name').value }
          xml.css('row').map do |row|
            value = {}
            columns.each do |column|
              value[column.to_sym] = row.attribute(column).value
            end
            OpenStruct.new(value)
          end
        end

        def remove_report_job(report_job_id)
          self.invoke(:ReportService, :mutate, message: {
            :operations => {
              :operator => 'REMOVE',
              :accountId => @account_id,
              :operand => {
                :report_job_id => report_job_id
              }
            }
          })
        end

        def remove_report_definition(report_id)
          self.invoke(:ReportDefinitionService, :mutate, message: {
            :operations => {
              :operator => 'REMOVE',
              :account_id => @account_id,
              :operand => {
                :report_id => report_id
              }
            }
          })
        end
      end
    end
  end
end
