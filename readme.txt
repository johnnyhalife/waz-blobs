This is the overall status of what's implemented on the API. The intention of the API is to leverage Windows Azure Storage from 
Ruby applications. This gem is specifically for developing against Windows Azure Blobs.

# Implemented API 
The API has been implemented against the default and most current version of Windows Azure. There's no support for 2009-07-17 version of it.

These are the implemented operations of the API

-----CONFIGURATION MANAGEMENT---------
- Set you configuration data
#
#	WAZ::Blobs::Base.establish_connection!(:account_name => "myAccount",
#										   :account_key => "myKey",
#										   :use_ssl => false)
#
- List Containers: Lists all of the containers in the given storage account.
- Create Container: Creates a new container in the given storage account.
#
#	WAZ::Blobs::Container.create('containerName')
#
- Get Container Properties: Returns all properties and metadata on the container.
#
#	container = WAZ::Blobs::Container.find('containerName') # Leverages get properties to understand whether the resource exists or not
#
#	container.metadata.each do |k, v|
#		#returns K,V for each metadata header
#	end
#
- Set Container Metadata: Sets metadata headers on the container.
#
#	container.update_attributes(:Name => "myContainer")
#
- Get Container ACL: Gets the access control list (ACL) and any container-level access policies for the container.
#
#	container.public?
#
- Set Container ACL: Sets the ACL and any container-level access policies for the container.
#
#	container.public = false
#
- Delete Container: Deletes the container and any blobs that it contains.
#
#	container.destroy!
#
- List Blobs: Lists all of the blobs in the given container.
#
#	container.blobs # does not return blobs contents
#
----------------
- Put Blob: Creates a new blob or replaces an existing blob within a container.
#
#	WAZ::Blobs::Object.store('/myContainer/myBlob', payload, "application/octet-stream")
#
- Get Blob: Reads or downloads a blob from the system, including its metadata and properties.
#
#	blob = WAZ::Blobs::Object.get('/myContainer/myBlob')
#
- Get Blob Properties: Returns all properties and metadata on the blob.
- Get Blob Metadata: Retrieves metadata headers on the blob.
#
#	blob = WAZ::Blobs::Object.get('/myContainer/myBlob')
#	blob.metadata[:content_type]
#
- Set Blob Metadata: Sets metadata headers on the blob.
#
#	blob.update_attributes(:Name => "myCustomName", :Album => "summer2009")
#
- Delete Blob: Deletes a blob.
#
#	blob.destroy!
#

-------NOT YET IMPLEMENTED--------
- Put Block: Creates a new block to be committed as part of a blob.
- Get Block List: Retrieves the list of blocks that make up the blob.
- Put Block List: Commits a blob by specifying the set of block IDs that comprise the blob.
- Copy Blob: Copies a blob to a destination within the storage account. [UNDEFINED]