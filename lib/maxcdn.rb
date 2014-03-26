require "signet/oauth_1/client"
require "curb-fu"
require "json"
require "ext/hash"
require "pp" # for debug

module MaxCDN
  class APIException < Exception
  end

  class Client
    attr_accessor :client, :debug
    def initialize(company_alias, key, secret, server="rws.maxcdn.com", secure_connection=true, _debug=false)
      @debug = _debug
      @secure_connection = secure_connection
      @company_alias = company_alias
      @server = server
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

    def _get_url uri, params={}
      url = "#{_connection_type}://#{@server}/#{@company_alias}/#{uri.gsub(/^\//, "")}"
      if params and not params.empty?
        url += "?#{params.to_params}"
      end

      url
    end

    def _response_as_json method, uri, options={}, data={}
      puts "Making #{method.upcase} request to #{_get_url uri}" if debug

      req_opts = {
        :method => method
      }

      req_opts[:uri]  = _get_url(uri, (options[:body] ? {} : data))
      req_opts[:body] = data.to_params if options[:body]

      request = @request_signer.generate_authenticated_request(req_opts)

      # crazyness for headers
      headers = options.delete(:headers) || {}
      headers["User-Agent"] = "Ruby MaxCDN API Client"

      # because CurbFu overwrites 'content-type' header, strip it
      # to set it later
      content_type = headers.case_indifferent_delete("Content-Type") || (options[:body] ? "application/json" : "application/x-www-form-urlencoded")

      # merge headers with request headers
      request.headers.case_indifferent_merge(headers)

      begin
        curb_opts = {
          :url => req_opts[:uri],
          :headers => request.headers
        }

        CurbFu.debug = debug

        response = CurbFu.send method, curb_opts, request.body do |curb|
          curb.verbose = debug

          # Because CurbFu overwrites the content-type header passed
          # to it. so we'll be setting our own.
          #
          # First, remove any existing 'Content-Type' header.
          curb.headers.case_indifferent_delete("Content-Type")

          # Second, set 'Content-Type' to our desired value.
          curb.headers["Content-Type"] = content_type
        end

        return response if options[:debug_request]
        pp response if debug

        response_json = JSON.load(response.body)

        return response_json if options[:debug_json]
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

    [ :post, :put ].each do |method|
      define_method(method) do |uri, data={}, options={}|
        options[:body] ||= true
        self._response_as_json method.to_s, uri, options, data
      end
    end

    [ :get, :delete ].each do |method|
      define_method(method) do |uri, data={}, options={}|
        options[:body] = false
        self._response_as_json method.to_s, uri, options, data
      end
    end

    def purge zone_id, file_or_files=nil, options={}
      if file_or_files.nil?
        return self.delete("/zones/pull.json/#{zone_id}/cache", {}, options)
      end

      if file_or_files.is_a?(String)
        return self.delete("/zones/pull.json/#{zone_id}/cache", { "files" => file_or_files }, options)
      end

      if file_or_files.is_a?(Array)
        result = {}
        file_or_files.each do |file|
          result[file] = self.delete("/zones/pull.json/#{zone_id}/cache", { "files" => file }, options)
        end
        return result
      end

      if file_or_files.is_a?(Hash)
        return self.purge(zone_id, file_or_files[:files]) if file_or_files.has_key?("files")
        return self.purge(zone_id, file_or_files[:files]) if file_or_files.has_key?(:files)
      end

      raise MaxCDN::APIException.new("Invalid file_or_files argument for delete method.")
    end
  end
end
