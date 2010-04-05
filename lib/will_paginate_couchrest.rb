
require('will_paginate_couchrest/class_methods')
require('will_paginate_couchrest/proxy_methods')

# Take the liberty of adding ourself to the couchrest library

module CouchRest
  class ExtendedDocument < Document
    include CouchRest::Mixins::WillPaginate
  end
end

module CouchRest
  module Mixins
    module ClassProxy
      class Proxy
        include CouchRest::Mixins::WillPaginate::ProxyMethods
      end
    end
  end
end

