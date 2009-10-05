module WAZ
  module Blobs
    class WAZStorageException < StandardError
    end
    
    class InvalidOption < WAZStorageException
      def initialize(missing_option)
        super("You did not provide both required access keys. Please provide the #{missing_option}.")
      end
    end
  end
end