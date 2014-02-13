require "signet/oauth_1/client"
require "curb-fu"
require "json"
require "pp" # for debug

module MaxCDN
  module Utils
    RESERVED_CHARACTERS = /[^a-zA-Z0-9\-\.\_\~]/

    def escape(value)
      URI::escape(value.to_s, MaxCDN::Utils::RESERVED_CHARACTERS)
    rescue ArgumentError
      URI::escape(value.to_s.force_encoding(Encoding::UTF_8), MaxCDN::Utils::RESERVED_CHARACTERS)
    end

    def encode_params params={}
      Hash[params.map { |k, v| [escape(k), escape(v)] }]
    end
  end

  class APIException < Exception
  end

  class Client
    include MaxCDN::Utils

    attr_accessor :client, :debug
    def initialize(company_alias, key, secret, server="rws.maxcdn.com", _debug=false)
      @debug = _debug
      @company_alias = company_alias
      @server = server
      @request_signer = Signet::OAuth1::Client.new(
        :client_credential_key => key,
        :client_credential_secret => secret,
        :two_legged => true
      )
    end

    def _connection_type
      "https"
    end

    def _encode_params params={}
      encode_params(params).map { |k, v|
        if v.is_a? Array
          index = 0
          v.map { |i|
            str = "#{k}[#{index}]=#{i}"
            index += 1
            str
          }.join "&"
        else
          "#{k}=#{v}"
        end
      }.join "&"
    end

    def _get_url uri, params={}
      url = "#{_connection_type}://#{@server}/#{@company_alias}/#{uri.gsub(/^\//, "")}"
      if params and not params.empty?
        url += "?#{_encode_params(params)}"
      end

      url
    end

    def _response_as_json method, uri, options={}, data={}
      puts "Making #{method.upcase} request to #{_get_url uri}" if debug

      req_opts = {
        :method => method
      }

      req_opts[:uri]  = _get_url(uri, (options[:body] ? {} : data))
      req_opts[:body] = _encode_params(data) if options[:body]

      request = @request_signer.generate_authenticated_request(req_opts)
      request.headers["User-Agent"] = "Ruby MaxCDN API Client"

      begin
        curb_opts = {
          :url => req_opts[:uri],
          :headers => request.headers
        }

        CurbFu.debug = debug

        response = CurbFu.send method, curb_opts, request.body do |curb|
          curb.verbose = debug

          # Because CurbFu overwrite the content-type header passed
          # to it
          curb.headers["Content-Type"] = "application/json" if request.body
        end

        pp response if debug

        response_json = JSON.load(response.body)

        pp response_json if debug

        unless response.success? or response.redirect?
          error_message = response_json["error"]["message"]
          raise MaxCDN::APIException.new("#{response.status}: #{error_message}")
        end
      rescue TypeError
        raise MaxCDN::APIException.new("#{response.status}: No information supplied by the server")
      end

      response_json
    end

    [ :post, :get, :put, :delete ].each do |meth|
      define_method(meth) do |uri, data={}, options={}|
        options[:body] ||= true if meth != :get
        self._response_as_json meth.to_s, uri, options, data
      end
    end

    def purge zone_id, file_or_files=nil, options={}
      unless file_or_files.nil?
        return self.delete("/zones/pull.json/#{zone_id}/cache",
                 { "files" => file_or_files }, options)
      end

      self.delete("/zones/pull.json/#{zone_id}/cache", {}, options)
    end
  end
end
