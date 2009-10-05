# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')

require 'rubygems'
require 'spec'
require 'mocha'
require 'restclient'
require 'lib/waz/blobs'

describe "blobs service behavior" do
   
  it "should create a container using the API" do
     options = { :account_name => "copaworkshop", 
                  :access_key => "cEsGVWPxnYQFpwxpqjJEPC1aROCSGlLT9yQCZmGvdGz2s19ZXjso+mV56wAiT+g+JDuIWz8qWNkrpzXBtqCm7g==" }

    WAZ::Blobs::Base.establish_connection!(options)
    WAZ::Blobs::Container.create('custom-container2')
  end
  
  it "should return container properties" do
    
  end
end