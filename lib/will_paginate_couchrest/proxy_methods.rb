module CouchRest
  module WillPaginate
    module ProxyMethods

      def method_missing(m, *args, &block)
        if m.to_s =~ /^paginate_(.+)/ && @klass.respond_to?(m)
          view_name = $1 # view name
          opts = args.shift || {}
          paginated_view(view_name, opts)
        else
          super
        end
      end

      def paginated_view(view_name, opts = {})
        opts = { 
          :database => @database
        }.merge(opts)
        result = @klass.paginated_view(view_name, opts)
        result.each{|doc| doc.database = @database if respond_to?(:database) } if result
        result
      end

    end
  end
end
