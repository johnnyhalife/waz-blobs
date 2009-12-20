module WAZ
  module Blobs
    module VERSION #:nodoc:
      MAJOR    = '0'
      MINOR    = '1'
      TINY     = '1' 
    end
    
    Version = [VERSION::MAJOR, VERSION::MINOR, VERSION::TINY].compact * '.'
  end
end