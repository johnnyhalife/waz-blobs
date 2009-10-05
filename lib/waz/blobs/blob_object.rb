module WAZ
  module Blobs
    class BlobObject
      class << self
        def store(path, payload, content_type)
        end
        
        def get(path)
        end
      end
      
      attr_accessor :name, :url, :content_type
      
      def initialize(name, url, content_type)
        self.name = name
        self.url = url
        self.content_type = content_type
      end
      
      def metadata
      end
      
      def update_attributes(attributes = {})
      end
      
      def destroy!
      end    
    end
  end
end
  