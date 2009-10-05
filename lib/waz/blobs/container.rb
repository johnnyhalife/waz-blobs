require 'restclient'

module WAZ
  module Blobs
    class Container
      #Singleton methods 
      class << self 
        def create(name)
          service_instance.create_container(name)
          return Container.new(name)
        end
        
        def find(name)
          begin 
            properties = service_instance.get_container_properties(name)
            return Container.new(name, properties)
          rescue RestClient::ResourceNotFound
            return nil
          end
        end
        
        private
          def service_instance
            options = Base.default_connection
            return Service.new(options[:account_name], options[:access_key])
          end        
      end
      
      attr_accessor :name, :properties, :public_access
      
      def initialize(name, metadata = nil)
        self.name = name
        self.properties = metadata
      end
      
      def metadata
        self.properties ||= service_instance.get_container_properties(self.name)
      end
      
      def put_properties(properties = {})
        service_instance.set_container_properties(self.name, properties)
        self.properties = metadata.merge!(properties)
      end
      
      def destroy!
        service_instance.delete_container(self.name)
      end
      
      def public_access?
        public_access ||= service_instance.get_container_acl(self.name)
      end
      
      def public_access=(value)
        public_access = value
        service_instance.set_container_acl(value)
      end
      
      def blobs
        service_instance.list_blobs(name).map { |blob| WAZ::Blobs::BlobObject.new(blob[:name], blob[:url], blob[:content_type]) }
      end
      
      private
        def service_instance
          options = Base.default_connection
          @service_instance ||= Service.new(options[:account_name], options[:access_key])
        end
    end
  end
end