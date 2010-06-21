
require('will_paginate_couchrest/class_methods')
require('will_paginate_couchrest/proxy_methods')

# Take the liberty of adding ourself to the couchrest library

if defined?(CouchRest::ExtendedDocument)
  module CouchRest
    class ExtendedDocument < Document
      include CouchRest::WillPaginate
    end
  end

  module CouchRest
    module Mixins
      module ClassProxy
        class Proxy
          include CouchRest::WillPaginate::ProxyMethods
        end
      end
    end
  end
end

if defined?(CouchRest::Model::Base)
  module CouchRest
    module Model
      class Base < Document
        include CouchRest::WillPaginate
      end
    end
  end

  module CouchRest
    module Model
      module ClassProxy
        class Proxy
          include CouchRest::WillPaginate::ProxyMethods
        end
      end
    end
  end
end



