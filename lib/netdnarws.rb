require 'oauth'
require 'json'

module NetDNARWS
  class NetDNA
      attr_accessor :client
      def initialize company_alias, key, secret,
                     server='rws.netdna.com', secure_connection=true, *options
        @company_alias = company_alias
        @server = server
        @secure_connection = secure_connection
        @client = OAuth::Consumer.new(key, secret,
                   :site => "#{_connection_type}://#{server}")
      end

      def _connection_type
        return "http" unless @secure_connection
        "https"
      end

      def _get_url uri
        "#{_connection_type}://#{@server}/#{@company_alias}#{uri}"
      end

      def _response_as_json method, uri, options={}, *attributes
        if options.delete(:debug)
          puts "Making #{method.upcase} request to #{_get_url uri}"
        end

        response = @client.request method, _get_url(uri), nil, options, attributes
        begin
          response_json = JSON.parse(response.body)
          if response.code != "200"
            error_message = response_json['error']['message']
            raise Exception.new("#{response.code}: #{error_message}")
          end
        rescue TypeError
          raise Exception.new(
            "#{response.code}: No information supplied by the server"
          )
        end

        response_json
      end

      def get uri, options={}
        self._response_as_json 'get', uri, options
      end

      def post uri, data={}, options={}
        self._response_as_json 'post', uri, options, [data]
      end

      def put uri, data={}, options={}
        self._response_as_json 'put', uri, options, [data]
      end

      def delete uri, options={}
        self._response_as_json 'delete', uri, options
      end
  end
end
