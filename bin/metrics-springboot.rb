#! /usr/bin/env ruby
#
#   springboot-metrics
#
# DESCRIPTION:
#   get metrics from Spring Boot 1.2.x application using actuator endpoints
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: json
#   gem: uri
#
# USAGE:
#
#   All metrics:
#     springboot-metrics.rb --host=192.168.1.1 &
#       --port=8081 &
#       --username=admin --password=secret &
#       --path=/metrics --counters --gauges
#   Exclude counters and gauges:
#     springboot-metrics.rb --host=192.168.1.1 &
#       --port=8081 &
#       --username=admin --password=secret --path=/metrics
#   Use with insecure SSL:
#     springboot-metrics.rb --host=192.168.1.1 &
#       --port=443 &
#       --username=admin --password=secret &
#       --path=/metrics --insecure --protocol http
#
# NOTES:
#   Check with Spring Boot 1.2.0 actuator endpoints
#
# LICENSE:
#   Copyright 2014 Victor Pechorin <dev@pechorina.net>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'net/http'
require 'net/https'
require 'json'
require 'uri'

class SpringBootMetrics < Sensu::Plugin::Metric::CLI::Graphite
  option :url,
         short: '-u URL',
         long: '--url URL',
         description: 'The url for your app metrics',
         required: false

  option :host,
         short: '-h HOST',
         long: '--host HOST',
         description: 'Your spring boot actuator endpoint',
         required: false,
         default: 'localhost'

  option :port,
         short: '-P PORT',
         long: '--port PORT',
         description: 'Your app port',
         required: false,
         default: 8080

  option :path,
         short: '-e PATH',
         long: '--path PATH',
         description: 'Metrics endpoint path',
         required: false,
         default: '/metrics'

  option :protocol,
         short: '-l PROTO',
         long: '--protocol PROTO',
         description: 'The protocol used to make requests',
         in: %(http https),
         default: http

  option :insecure,
         short: '-k',
         long: '--insecure',
         description: 'Insecure SSL Certificate',
         boolean: true,
         default: false

  option :username,
         short: '-u USERNAME',
         long: '--username USERNAME',
         description: 'Your app username',
         required: false

  option :password,
         short: '-p PASSWORD',
         long: '--password PASSWORD',
         description: 'Your app password',
         required: false

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         required: true,
         default: "#{Socket.gethostname}.springboot_metrics"

  option :counters,
         description: 'Include counters',
         short: '-c',
         long: '--counters',
         boolean: true,
         default: false

  option :gauges,
         description: 'Include gauges',
         short: '-g',
         long: '--gauges',
         boolean: true,
         default: false

  def json_valid?(str)
    JSON.parse(str)
    return true
  rescue JSON::ParserError
    return false
  end

  def run
    unless config[:url]
      config[:url] = "#{config[:protocol]}://#{config[:host]}:#{config[:port]}#{config[:path]}"
    end

    uri = URI.parse(config[:url])

    verify_mode = config[:insecure] ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER

    begin
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme, verify_mode: verify_mode) do |http|
        req = Net::HTTP::Get.new(uri.path)
        if config[:username] && config[:password]
          req.basic_auth(config[:username], config[:password])
        end
        http.request(req)
      end
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET,
           EOFError, Net::HTTPBadResponse,
           Net::HTTPHeaderSyntaxError, Net::ProtocolError,
           Errno::ECONNREFUSED => e
      critical e
    end

    if json_valid?(res.body)
      json = JSON.parse(res.body)
      json.each do |key, val|
        if key.to_s =~ /^counter\.(.+)/
          output(config[:scheme] + '.' + key, val) if config[:counters]
        elsif key.to_s =~ /^gauge\.(.+)/
          output(config[:scheme] + '.' + key, val) if config[:gauges]
        else
          output(config[:scheme] + '.' + key, val)
        end
      end
    else
      critical 'Response contains invalid JSON'
    end

    ok
  end
end
