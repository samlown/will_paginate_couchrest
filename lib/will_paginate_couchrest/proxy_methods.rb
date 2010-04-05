module CouchRest
  module Mixins
    module WillPaginate
      module ProxyMethods

        def method_missing(m, *args, &block)
          if m.to_s =~ /^paginate_(.+)/ && @klass.respond_to?(m)
            @klass.send(m, *args)
          else
            super
          end
        end

      end
    end
  end
end
