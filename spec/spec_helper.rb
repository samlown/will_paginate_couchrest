$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'couchrest_extended_document'
require 'couchrest_model'
require 'will_paginate'
require 'will_paginate_couchrest'
require 'spec'
require 'spec/autorun'


unless defined?(SPEC_COUCH)
  COUCH_URL = "http://127.0.0.1:5984"
  COUCH_NAME = 'couchrest-test'

  SPEC_COUCH = CouchRest.database!("#{COUCH_URL}/#{COUCH_NAME}")
end

def reset_test_db!
  SPEC_COUCH.recreate! rescue nil 
  SPEC_COUCH
end

Spec::Runner.configure do |config|
  config.before(:all) {
    reset_test_db!
  }
  
  config.after(:all) do
    SPEC_COUCH.delete!
  end
end
