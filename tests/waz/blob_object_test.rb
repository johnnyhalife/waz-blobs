# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')

require 'rubygems'
require 'spec'
require 'mocha'
require 'restclient'
require 'tests/configuration'
require 'lib/waz/blobs'

describe "Windows Azure Blobs interface API" do
  it "should return blob path from url" do
    blob = WAZ::Blobs::BlobObject.new("blob_name", "http://localhost/container/blob", "application/xml")
    blob.path.should == "container/blob"
  end
  
  it "should return blob metdata" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"})
    WAZ::Blobs::Service.any_instance.expects(:get_blob_properties).with("container/blob").returns({:x_ms_meta_name => "blob_name"})
    blob = WAZ::Blobs::BlobObject.new("blob_name", "http://localhost/container/blob", "application/xml")  
    blob.metadata.should == { :x_ms_meta_name => "blob_name" }
  end
  
  it "should put blob metadata" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).at_most(2)
    WAZ::Blobs::Service.any_instance.expects(:get_blob_properties).with("container/blob").returns({:x_ms_meta_prop => "prop_value"})
    WAZ::Blobs::Service.any_instance.expects(:set_blob_properties).with("container/blob", {:x_ms_meta_name => "blob_name"})
    blob = WAZ::Blobs::BlobObject.new("blob_name", "http://localhost/container/blob", "application/xml")  
    blob.put_properties({ :x_ms_meta_name => "blob_name" })
  end
  
  it "should get blob contents" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).at_most(2)
    WAZ::Blobs::Service.any_instance.expects(:get_blob).with("container/blob").returns("this is the blob content")
    blob = WAZ::Blobs::BlobObject.new("blob", "http://localhost/container/blob", "application/xml") 
    blob.value.should == "this is the blob content"
  end
  
  it "should put blob contents" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).at_most(2)
    WAZ::Blobs::Service.any_instance.expects(:get_blob_properties).with("container/blob").returns({})
    WAZ::Blobs::Service.any_instance.expects(:put_blob).with("container/blob", "my new blob value", "application/xml", {}).returns("this is the blob content")
    blob = WAZ::Blobs::BlobObject.new("blob", "http://localhost/container/blob", "application/xml") 
    blob.value = "my new blob value"
  end
  
  it "should destroy blob" do
   WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).at_most(2) 
   WAZ::Blobs::Service.any_instance.expects(:delete_blob).with("container/blob")
   blob = WAZ::Blobs::BlobObject.new("blob", "http://localhost/container/blob", "application/xml")
   blob.destroy!
  end
end