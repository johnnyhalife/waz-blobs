require 'restclient'
require 'time'
require 'hmac-sha2'
require 'base64'
require 'cgi'
require 'rexml/document'
require 'rexml/xpath'

module WAZ
  module Blobs
    class Service
      attr_accessor :account_name, :account_key, :use_ssl, :base_url
      
      def initialize(account_name, account_key, use_ssl = false, base_url = "blob.core.windows.net" )
        self.account_name = account_name
        self.account_key = account_key 
        self.use_ssl = use_ssl
        self.base_url = base_url
      end
      
      def create_container(container_name)
        url = generate_request_uri(nil, container_name)
        request = generate_request("PUT", url)
        request.execute()
      end
      
      def get_container_properties(container_name)
        url = generate_request_uri(nil, container_name)
        request = generate_request("GET", url)
        request.execute().headers
      end
      
      def set_container_properties(container_name, properties = {})
        headers = {}
        properties.each{ |k, v| headers[k.to_s.gsub(/_/, '-')] = v}
        url = generate_request_uri("metadata", container_name)
        request = generate_request("PUT", url, headers)
        request.execute()
      end
      
      def get_container_acl(container_name)
        url = generate_request_uri("acl", container_name)
        request = generate_request("GET", url)
        request.execute().headers[:x_ms_prop_publicaccess].downcase == true.to_s
      end

      def set_container_acl(container_name, public_available = false)
        url = generate_request_uri("acl", container_name)
        request = generate_request("PUT", url, "x-ms-prop-publicaccess" => public_available.to_s)
        request.execute()
      end

      def list_containers(options = {})
        url = generate_request_uri("list", nil, options)
        request = generate_request("GET", url)
        doc = REXML::Document.new(request.execute())
        containers = []
        REXML::XPath.each(doc, '//Container/') do |item|
          containers << { :name => REXML::XPath.first(item, "Name").text,
                          :url => REXML::XPath.first(item, "Url").text,
                          :last_modified => REXML::XPath.first(item, "LastModified").text}
        end
        return containers
      end

      def delete_container(container_name)
        url = generate_request_uri(nil, container_name)
        request = generate_request("DELETE", url)
        request.execute()
      end

      def list_blobs(container_name)
        url = generate_request_uri("list", container_name)
        request = generate_request("GET", url)
        doc = REXML::Document.new(request.execute())
        containers = []
        REXML::XPath.each(doc, '//Blob/') do |item|
          containers << { :name => REXML::XPath.first(item, "Name").text,
                          :url => REXML::XPath.first(item, "Url").text,
                          :content_type =>  REXML::XPath.first(item, "ContentType").text }
        end
        return containers
      end

      def put_blob(path, payload, content_type = "application/octet-stream")
        url = generate_request_uri(nil, path)
        request = generate_request("PUT", url, {"Content-Type" => content_type}, payload)
        request.execute()
      end
          
      def get_blob(path)
        url = generate_request_uri(nil, path)
        request = generate_request("GET", url)
        request.execute()
      end

      def delete_blob(path)
        url = generate_request_uri(nil, path)
        request = generate_request("DELETE", url)
        request.execute()
      end
            
      def get_blob_properties(path)
        url = generate_request_uri("metadata", path)
        request = generate_request("GET", url)
        request.execute().headers.select {|h| h.start_with? "x-ms-meta" }.map { |h| h.gsub('-', '_').to_sym }
      end

      def set_blob_properties(path, properties ={})
        headers = {}
        properties.each{ |k, v| headers[k.to_s.gsub(/_/, '-')] = v}
        url = generate_request_uri("metadata", path)
        request = generate_request("PUT", url, headers)
        request.execute()
      end
      
      def generate_request(verb, url, headers = {}, payload = nil)
        request = RestClient::Request.new(:method => verb, :url => url, :headers => headers, :payload => payload)
        request.headers["x-ms-Date"] = Time.new.httpdate
        request.headers["Content-Length"] = (request.payload or "").length
        request.headers["Authorization"] = "SharedKey #{account_name}:#{generate_signature(request)}"
        return request
      end
            
      def generate_request_uri(operation, path = nil, options = {})
        protocol = use_ssl ? "https" : "http"
        query_params = options.keys.sort{ |a, b| a.to_s <=> b.to_s}.map{ |k| "#{k.to_s.gsub(/_/, '')}=#{options[k]}"}.join("&") unless options.empty?
        uri = "#{protocol}://#{account_name}.#{base_url}/#{(path or "")}#{operation ? "?comp=" + operation : ""}"
        uri << "&#{query_params}" if query_params
        return uri
      end
      
      def canonicalize_headers(headers)
        cannonicalized_headers = headers.keys.select {|h| h.to_s.start_with? 'x-ms'}.map{ |h| "#{h.downcase.strip}:#{headers[h].strip}" }.sort{ |a, b| a <=> b }.join("\x0A")
        return cannonicalized_headers
      end
      
      def canonicalize_message(url)
        uri_component = url.gsub(/https?:\/\/[^\/]+\//i, '').scan(/([^&]+)/i).first()
        cannonicalized_message = "/#{self.account_name}/#{uri_component}"
      end
      
      def generate_signature(request)
         signature = request.method + "\x0A" +
                     (request.headers["Content-MD5"] or "") + "\x0A" +
                     (request.headers["Content-Type"] or "") + "\x0A" +
                     (request.headers["Date"] or "")+ "\x0A" +
                     canonicalize_headers(request.headers) + "\x0A" +
                     canonicalize_message(request.url)
         return Base64.encode64(HMAC::SHA256.new(Base64.decode64(self.account_key)).update(signature.toutf8).digest)
       end
    end
  end
end