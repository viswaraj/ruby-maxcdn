require 'signet/oauth_1/client'
require 'addressable/uri'
require 'faraday/connection'
require 'json'

module Faraday
  class Request
    def url path, params=nil
      self.path = path
    end
  end
end

module NetDNARWS
  class NetDNA
      attr_accessor :client
      def initialize company_alias, key, secret,
                     server='rws.netdna.com', secure_connection=true, *options
        @company_alias = company_alias
        @server = server
        @secure_connection = secure_connection
        @request_signer = Signet::OAuth1::Client.new(
          :client_credential_key => key,
          :client_credential_secret => secret,
          :two_legged => true
        )
      end

      def _connection_type
        return "http" unless @secure_connection
        "https"
      end

      def _encode_params values
        uri = Addressable::URI.new
        uri.query_values = values
        uri.query
      end

      def _get_url uri, attributes
        url = "#{_connection_type}://#{@server}/#{@company_alias}#{uri}"
        if not attributes.empty?
          url += "?#{_encode_params(attributes[0])}"
        end

        url
      end

      def _response_as_json method, uri, options={}, *attributes
        if options.delete(:debug)
          puts "Making #{method.upcase} request to #{_get_url uri}"
        end

        request_options = {
          :uri => _get_url(uri, attributes),
          :method => method
        }

        request_options[:body] = _encode_params(attributes[0]) if options[:body]
        request = @request_signer.generate_authenticated_request(request_options)
        connection = Faraday::Connection.new

        begin
          response = connection.send method do |req|
            req.url _get_url(uri, attributes)
            req.headers = request.headers
            req.body = request.body if options[:body]
          end

          response_json = JSON.load(response.env[:body])

          if not (100..399).include? response.env[:status]
            error_message = response_json['error']['message']
            raise Exception.new("#{response.env[:status]}: #{error_message}")
          end
        rescue TypeError
          raise Exception.new(
            "#{response.env[:status]}: No information supplied by the server"
          )
        end

        response_json
      end

      def get uri, options={}
        options[:body] = false
        self._response_as_json 'get', uri, options
      end

      def post uri, data={}, options={}
        options[:body] = true
        self._response_as_json 'post', uri, options, data
      end

      def put uri, data={}, options={}
        options[:body] = true
        self._response_as_json 'put', uri, options, data
      end

      def delete uri, options={}
        options[:body] = false
        self._response_as_json 'delete', uri, options
      end
  end
end
