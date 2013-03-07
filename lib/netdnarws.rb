require 'signet/oauth_1/client'
require 'addressable/uri'
require 'curb-fu'
require 'json'

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

        begin
          curb_options = {}
          curb_options[:url] = _get_url(uri, attributes)
          curb_options[:headers] = request.headers

          if not options[:body]
            response = CurbFu.send method, curb_options
          else
            response = CurbFu.send method, curb_options, request.body
          end

          return response if options[:debug_request]

          response_json = JSON.load(response.body)

          return response_json if options[:debug_json]

          if not (response.success? or response.redirect?)
            error_message = response_json['error']['message']
            raise Exception.new("#{response.status}: #{error_message}")
          end
        rescue TypeError
          raise Exception.new(
            "#{response.status}: No information supplied by the server"
          )
        end

        response_json
      end

      def get uri, data={}, options={}
        options[:body] = false
        self._response_as_json 'get', uri, options, data
      end

      def post uri, data={}, options={}
        options[:body] = true
        self._response_as_json 'post', uri, options, data
      end

      def put uri, data={}, options={}
        options[:body] = true
        self._response_as_json 'put', uri, options, data
      end

      def delete uri, data={}, options={}
        options[:body] = false
        self._response_as_json 'delete', uri, options, data
      end

      def purge zone_id, file_or_files=nil, options={}
        if file_or_files.respond_to? :each
          options[:debug_json] = true if options[:debug_json].nil?
          responses = Hash.new

          file_or_files.each { |e|
            responses[e] = self.delete(
                             "/zones/pull.json/#{zone_id}/cache",
                             {'file' => e},
                             options
                           )
          }
          return responses
        end


        unless file_or_files.nil?
          return self.delete(
            "/zones/pull.json/#{zone_id}/cache",
            {'file' => file_or_files},
            options
          )
        end

        self.delete("/zones/pull.json/#{zone_id}/cache", {}, options)
      end
  end
end
