require 'google/apis/monitoring_v3'
require 'json'

class Test
  class Error < ::StandardError; end
  class NotFound < Error; end

  def run
    body = Google::Apis::MonitoringV3::CreateTimeSeriesRequest.new({
      time_series: [
        {
          metric: {
            type: "custom.googleapis.com/stores/daily_sales",
            labels: {
            store_id: "Pittsburgh"
          },
          },
          resource: {
            type: "global",
            labels: {
            project_id: "#{project}",
          },
          },
          points: [
            {
              interval: {
                end_time: "#{Time.now.iso8601}",
              },
              value: {
                double_value: 123.45
              }
            }
          ]
        }
      ]
    })
    client.create_time_series("projects/#{project}", body)
  end

  private

  def credentials_file
    File.expand_path('~/.config/gcloud/application_default_credentials.json')
  end

  def project
    @project ||= JSON.parse(File.read(credentials_file))['project_id']
  end

  def client
    return @client if @client && @client_expiration > Time.now

    scope = "https://www.googleapis.com/auth/monitoring.write"
    client = Google::Apis::MonitoringV3::MonitoringService.new
    client.client_options.application_name = 'stackdriver-custom-metrics-sample'
    client.client_options.application_name = '0.0.1'
    client.request_options.retries = 5
    client.request_options.timeout_sec = 300
    client.request_options.open_timeout_sec = 300

    auth = Google::Auth.get_application_default([scope])
    client.authorization = auth

    @client_expiration = Time.now + 1800
    @client = client
  end
end

Test.new.run
