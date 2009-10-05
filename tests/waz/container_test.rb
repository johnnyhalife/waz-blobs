# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')

require 'rubygems'
require 'spec'
require 'mocha'
require 'restclient'
require 'tests/configuration'
require 'lib/waz/blobs'

describe "Windows Azure Containers interface API" do 
  it "should be able to create a container" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"})
    WAZ::Blobs::Service.any_instance.expects(:create_container).with("my_container")
    container = WAZ::Blobs::Container.create('my_container')
    container.name.should == 'my_container'
  end
  
  it "should be able to return a container by name" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"})
    WAZ::Blobs::Service.any_instance.expects(:get_container_properties).with("container_name").returns({:x_ms_meta_name => "container_name"})
    container = WAZ::Blobs::Container.find('container_name')
    container.metadata[:x_ms_meta_name].should == 'container_name'
  end
  
  it "should be able to return container metadata" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).twice()
    WAZ::Blobs::Service.any_instance.expects(:create_container).with("container_name")
    WAZ::Blobs::Service.any_instance.expects(:get_container_properties).with("container_name").returns({:x_ms_meta_name => "container_name"})
    container = WAZ::Blobs::Container.create('container_name')
    container.metadata[:x_ms_meta_name].should == 'container_name'  
  end
  
  it "should be able to say whether the container is public or not" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).twice()
    WAZ::Blobs::Service.any_instance.expects(:get_container_properties).with("container_name").returns({:x_ms_meta_name => "container_name"})
    WAZ::Blobs::Service.any_instance.expects(:get_container_acl).with("container_name").returns(false)
    container = WAZ::Blobs::Container.find("container_name")
    container.public_access?.should == false
  end
  
  it "should be able to set whether the container is public or not" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).twice()
    WAZ::Blobs::Service.any_instance.expects(:get_container_properties).with("container_name").returns({:x_ms_meta_name => "container_name"})
    WAZ::Blobs::Service.any_instance.expects(:set_container_acl).with(false)
    container = WAZ::Blobs::Container.find("container_name")
    container.public_access = false
  end
  
  it "should be able to set container properties" do
    properties = {:x_ms_meta_meta1 => "meta1"}
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).twice()
    WAZ::Blobs::Service.any_instance.expects(:set_container_properties).with("container_name", properties).returns(false)
    WAZ::Blobs::Service.any_instance.expects(:get_container_properties).with("container_name").returns({:x_ms_meta_name => "container_name"})
    container = WAZ::Blobs::Container.find("container_name")
    container.put_properties(properties)
    container.metadata[:x_ms_meta_meta1].should == "meta1"
    container.metadata[:x_ms_meta_name].should == "container_name"
  end
  
  it "should be able to return a list files within the container" do
    expected_blobs = [ {:name => 'blob1'}, {:name => 'blob2'} ]
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).at_least(2)
    WAZ::Blobs::Service.any_instance.expects(:get_container_properties).with("container_name").returns({:x_ms_meta_name => "container_name"})
    WAZ::Blobs::Service.any_instance.expects(:list_blobs).with("container_name").returns(expected_blobs)
    container = WAZ::Blobs::Container.find("container_name")
    container_blobs = container.blobs
    container_blobs.first().name = expected_blobs[0][:name]
    container_blobs[1].name = expected_blobs[1][:name]
  end
  
  it "should destroy container" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"}).at_least(2)
    WAZ::Blobs::Service.any_instance.expects(:get_container_properties).with("container_name").returns({:x_ms_meta_name => "container_name"})
    WAZ::Blobs::Service.any_instance.expects(:delete_container).with("container_name")
    container = WAZ::Blobs::Container.find("container_name")
    container.destroy!
  end
  
  it "should be able to return null when container not found by name" do
    WAZ::Blobs::Base.expects(:default_connection).returns({:account_name => "my_account", :access_key => "key"})
    WAZ::Blobs::Service.any_instance.expects(:get_container_properties).with("container_name").raises(RestClient::ResourceNotFound)
    container = WAZ::Blobs::Container.find('container_name')
    container.nil?.should == true
  end  
end