# enabling the load of files from root (on RSpec)
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../')
require 'lib/waz/blobs/base'
require 'lib/waz/blobs/service'
require 'lib/waz/blobs/container'
require 'lib/waz/blobs/blob_object'
require 'lib/waz/blobs/exceptions'