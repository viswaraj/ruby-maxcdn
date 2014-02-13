require "signet/oauth_1/client"
require "curb-fu"
require "json"

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
    def initialize(company_alias, key, secret, server="rws.maxcdn.com", secure_connection=true)
      @debug = false
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

    def _encode_params params={}
      encode_params(params).map { |k, v|
        "#{k}=#{v}"
      }.join "&"
    end

    def _get_url uri, params={}

      url = "#{_connection_type}://#{@server}/#{@company_alias}/#{uri.gsub(/^\//, "")}"
      if params and not params.empty?
        url += "?#{_encode_params(params)}"
      end

      url
    end

    def _response_as_json method, uri, options={}, *attributes
      if debug
        require 'pp'
        puts "Making #{method.upcase} request to #{_get_url uri}"
      end

      req_opts = {
        :method => method
      }

      req_opts[:uri] = _get_url(uri)

      if attributes and attributes.size > 0
        if options[:body]
          req_opts[:body] = attributes[0]
        else
          req_opts[:uri] = _get_url(uri, attributes[0])
        end
      end

      request = @request_signer.generate_authenticated_request(req_opts)
      request.headers["User-Agent"] = "Ruby MaxCDN API Client"

      begin
        curb_opts = {
          :url => req_opts[:uri],
          :headers => request.headers
        }

        CurbFu.debug = debug

        if options[:body]
          response = CurbFu.send method, curb_opts, request.body do |curb|
            # Yes, I would perfer to do `curb.verbose = debug`, but
            # it makes testing more difficult.
            if debug
              curb.verbose = true
            end

            # Because CurbFu overwrite the content-type header passed
            # to it
            curb.headers["Content-Type"] = "application/json"
          end
        else
          response = CurbFu.send method, curb_opts, nil do |curb|
            if debug
              curb.verbose = true
            end
          end
        end

        pp response if debug

        response_json = JSON.load(response.body)

        pp response_json if debug

        unless response.success? or response.redirect?
          error_message = response_json["error"]["message"]
          raisr MaxCDN::APIException.new("#{response.status}: #{error_message}")
        end
      rescue TypeError
        raise MaxCDN::APIException.new("#{response.status}: No information supplied by the server")
      end

      response_json
    end

    [ :get, :post, :put, :delete ].each do |meth|
      define_method(meth) do |uri, data={}, options={}|
        unless options.has_key?(:body)
          options[:body] = (meth == :post || meth == :put)
        end
        self._response_as_json meth.to_s, uri, options, data
      end
    end

    def purge zone_id, file_or_files=nil, options={}
      unless file_or_files.nil?
        return self.delete(
          "/zones/pull.json/#{zone_id}/cache",
          {"file" => file_or_files},
            options
        )
      end

      self.delete("/zones/pull.json/#{zone_id}/cache", {}, options)
    end
  end
end
