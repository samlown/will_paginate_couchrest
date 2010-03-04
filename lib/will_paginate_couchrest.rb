# Based on original validators in CouchRest::Validation
require 'couchrest/mixins/validation'

module CouchRest
  module Mixins 
    module WillPaginate

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # Define a CouchDB paginate view. The name of the view will be the concatenation
        # of <tt>paginate_by</tt> and the keys joined by <tt>_and_</tt>
        #  
        # ==== Example views:
        #  
        #   class Post
        #     # view with default options
        #     # query with Post.paginate_by_date
        #     paginated_view_by :date, :descending => true
        #  
        #     # view with compound sort-keys
        #     # query with Post.by_user_id_and_date
        #     paginated_view_by :user_id, :date
        #  
        #     # view with custom map/reduce functions
        #     # query with Post.by_tags :reduce => true
        #     paginated_view_by :tags,                                                
        #       :map =>                                                     
        #         "function(doc) {                                          
        #           if (doc['couchrest-type'] == 'Post' && doc.tags) {                   
        #             doc.tags.forEach(function(tag){                       
        #               emit(doc.tag, 1);                                   
        #             });                                                   
        #           }                                                       
        #         }",                                                       
        #       :reduce =>                                                  
        #         "function(keys, values, rereduce) {                       
        #           return sum(values);                                     
        #         }"                                                        
        #   end
        #  
        # <tt>paginated_view_by :date</tt> will create a view defined by this Javascript
        # function:
        #  
        #   function(doc) {
        #     if (doc['couchrest-type'] == 'Post' && doc.date) {
        #       emit(doc.date, 1);
        #     }
        #   }
        #
        # And a standard summing reduce function like the following:
        #  
        #   function(keys, values, rereduce) {                       
        #     return sum(values);
        #   } 
        #
        # It can be queried by calling <tt>Post.paginate_by_date</tt> which accepts all
        # valid options for CouchRest::Database#view. In addition, calling with
        # the <tt>:raw => true</tt> option will return the view rows
        # themselves. By default <tt>Post.by_date</tt> will return the
        # documents included in the generated view.
        #  
        # For further details on <tt>view_by</tt>'s other options, please see the
        # standard documentation.
        
        def paginated_view_by(*keys)

          # Prepare the Traditional view
          opts = keys.last.is_a?(Hash) ? keys.pop : {}
          view_name = "by_#{keys.join('_and_')}"
          method_name = "paginate_#{view_name}"

          doc_keys = keys.collect{|k| "doc['#{k}']"}
          key_emit = doc_keys.length == 1 ? "#{doc_keys.first}" : "[#{doc_keys.join(', ')}]"
          guards = opts.delete(:guards) || []
          guards.push("(doc['couchrest-type'] == '#{self.to_s}')")
          guards.concat doc_keys

          opts.reverse_merge!(
            :map => "
              function( doc ) {
                if (#{guards.join(' && ')}) {
                  emit(#{key_emit}, 1 );
                }
              }
            ",
            :reduce => "
              function(keys, values, rereduce) {                       
                return sum(values);
              }
            "
          )

          # View prepared, send to traditional view_by
          view_by keys, opts

          instance_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
            def #{method_name}(options = {})
              paginated_view('#{view_name}', options)
            end
          RUBY_EVAL

        end


        protected

          ##
          # Return a WillPaginate collection suitable for usage
          # 
          def paginated_view(view_name, options = {})
          
            raise "Missing page parameter" if options[:page].nil?
            raise "Missing per_page parameter" if options[:per_page].nil?

            ::WillPaginate::Collection.create( options[:page], options[:per_page] ) do |pager|
              # perform view count first (should create designs if missing)
              total = view( view_name, options.update(:reduce => true) )['rows'].pop
              pager.total_entries = total ? total['value'] : 0
              results = paginate(
                options.merge(
                  :design_doc => self.to_s, :view_name => view_name,
                  :include_docs => true, :reduce => false
                )
              )
              pager.replace( results )
            end
          end
      end
      
    end
  end # module mixins 
end # module CouchRest


# Take the liberty of adding ourself to the couchrest library

module CouchRest
  class ExtendedDocument < Document
    include CouchRest::Mixins::WillPaginate
  end
end

