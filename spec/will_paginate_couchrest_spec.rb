require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe CouchRest::Mixins::WillPaginate do
  
  class SomeDoc < CouchRest::ExtendedDocument
    use_database SPEC_COUCH

    property :name

    paginated_view_by :name
  end

  it "should respond to paginated_view_by class method" do
    SomeDoc.should respond_to :paginated_view_by
  end

  it "should call view_by method when paginated view_by included" do
    SomeDoc.should_receive(:view_by)
    class SomeDoc
      paginated_view_by :name
    end
  end
  
  it "should respond to the view and paginated method" do
    SomeDoc.should respond_to :paginate_by_name
    # @some_doc.stub(:id).and_return(123)
  end

  it "should accept request when no results" do
    docs = SomeDoc.paginate_by_name(:per_page => 5)
    docs.total_entries.should eql(0)    
  end

  it "should accept request without page" do
    docs = nil
    lambda { docs = SomeDoc.paginate_by_name(:per_page => 5) }.should_not raise_error
    docs.current_page.should eql(1)
  end

  it "should throw an exception when missing per_page parameter" do
    lambda { SomeDoc.paginate_by_name() }.should raise_error
  end


  describe "performing pagination with lots of documents" do

    before(:each) do
      reset_test_db!
      20.times do |i|
        txt = "%02d" % i
        SomeDoc.new(:name => "document #{txt}").save
      end
    end

    it "should produce a will paginate collection" do
      docs = SomeDoc.paginate_by_name( :page => 1, :per_page => 5 )
      docs.should be_a_kind_of(::WillPaginate::Collection)
      docs.total_pages.should eql(4)
      docs.first.name.should eql('document 00')
      docs.length.should eql(5)
      docs.last.name.should eql('document 04')
    end

    it "should produce second page from paginate collection" do
      docs = SomeDoc.paginate_by_name( :page => 2, :per_page => 5 )
      docs.first.name.should eql('document 05')
      docs.length.should eql(5)
      docs.last.name.should eql('document 09')
    end

    it "should perform paginate on all entries" do
      docs = SomeDoc.paginate_all(:page => 1, :per_page => 5)
      docs.first.class.should eql(SomeDoc)
      docs.total_pages.should eql(4)
      docs.total_entries.should eql(20)
      docs.length.should eql(5)
    end

  end
end

