# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')

require 'rubygems'
require 'spec'
require 'mocha'
require 'waz-blobs'

describe "blobs service behavior" do
   
  it "should satisfy my expectations" do
     options = { :account_name => "copaworkshop", 
                  :access_key => "cEsGVWPxnYQFpwxpqjJEPC1aROCSGlLT9yQCZmGvdGz2s19ZXjso+mV56wAiT+g+JDuIWz8qWNkrpzXBtqCm7g==" }

    WAZ::Blobs::Base.establish_connection!(options)
    
    container = WAZ::Blobs::Container.find('momo-container')
    container.put_properties(:x_ms_meta_owner => "Ezequiel Morito")
    container.public_access = true
    container.store("hello.txt", "Hola Don Julio Morito y Jedib!", "plain/text")
    blob = container["hello.txt"]
    blob.put_properties(:x_ms_meta_owner => "Johnny Halife")
  end
end