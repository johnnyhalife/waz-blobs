module WAZ
  module Blobs
    class BlobObject      
      attr_accessor :name, :url, :content_type
      
      def initialize(name, url, content_type)
        self.name = name
        self.url = url
        self.content_type = content_type
      end
      
      def metadata
        @properties ||= service_instance.get_blob_properties(path)
      end
      
      def value
        @value ||= service_instance.get_blob(path)
      end
      
      def value=(new_value)
        service_instance.put_blob(path, new_value, content_type, metadata)
        @value = new_value
      end
      
      def put_properties(properties = {})
        service_instance.set_blob_properties(path, properties)
        @properties = metadata.merge(properties)
      end
      
      def destroy!
        service_instance.delete_blob(path)
      end
      
      def path
        url.gsub(/https?:\/\/[^\/]+\//i, '').scan(/([^&]+)/i).first().first()
      end
      
      private
        def service_instance
          options = Base.default_connection
          @service_instance ||= Service.new(options[:account_name], options[:access_key])
        end
    end
  end
end
  