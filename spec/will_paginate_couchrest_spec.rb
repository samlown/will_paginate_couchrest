require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CouchRest::WillPaginate do
  
  class SomeExtendedDoc < CouchRest::ExtendedDocument
    use_database SPEC_COUCH
    property :name
    paginated_view_by :name
  end

  class SomeModel < CouchRest::Model::Base
    use_database SPEC_COUCH
    property :name
    paginated_view_by :name
  end

  [SomeExtendedDoc, SomeModel].each do |klass|
   
    describe klass do

      before(:all) do
        reset_test_db!
      end

      it "should respond to paginated_view_by class method" do
        klass.should respond_to :paginated_view_by
      end

      it "should call view_by method when paginated view_by included" do
        klass.should_receive(:view_by)
        klass.paginated_view_by :name
      end
      
      it "should respond to the view and paginated method" do
        klass.should respond_to :paginate_by_name
        # @some_doc.stub(:id).and_return(123)
      end

      it "should accept request when no results" do
        docs = klass.paginate_by_name(:per_page => 5)
        docs.total_entries.should eql(0)    
      end

      it "should accept request without page" do
        docs = nil
        lambda { docs = klass.paginate_by_name(:per_page => 5) }.should_not raise_error
        docs.current_page.should eql(1)
      end

      it "should throw an exception when missing per_page parameter" do
        lambda { klass.paginate_by_name() }.should raise_error
      end


      describe "performing pagination with lots of documents" do

        before(:each) do
          reset_test_db!
          20.times do |i|
            txt = "%02d" % i
            klass.new(:name => "document #{txt}").save
          end
        end

        it "should produce a will paginate collection" do
          docs = klass.paginate_by_name( :page => 1, :per_page => 5 )
          docs.should be_a_kind_of(::WillPaginate::Collection)
          docs.total_pages.should eql(4)
          docs.first.name.should eql('document 00')
          docs.length.should eql(5)
          docs.last.name.should eql('document 04')
        end

        it "should produce second page from paginate collection" do
          docs = klass.paginate_by_name( :page => 2, :per_page => 5 )
          docs.first.name.should eql('document 05')
          docs.length.should eql(5)
          docs.last.name.should eql('document 09')
        end

        it "should perform paginate on all entries" do
          docs = klass.paginate_all(:page => 1, :per_page => 5)
          docs.first.class.should eql(klass)
          docs.total_pages.should eql(4)
          docs.total_entries.should eql(20)
          docs.length.should eql(5)
        end

      end


      describe "using pagination via proxy class" do
        before(:each) do
          @proxy = klass.on(SPEC_COUCH)
        end

        it "should allow paginate call on proxy" do
          klass.should_receive(:paginated_view).with('by_name', {:key => 'foo', :database => SPEC_COUCH})
          @proxy.paginate_by_name :key => 'foo'
        end
      end
    end
  end
end

