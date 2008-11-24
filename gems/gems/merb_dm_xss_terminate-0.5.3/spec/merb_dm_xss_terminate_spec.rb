require File.dirname(__FILE__) + '/spec_helper'

describe "merb_xss_terminate" do
  it "should do nothing" do
    true.should == true
  end

  it "should strip tags on discovered fields" do
    c = Comment.create!(:title => "<script>alert('xss in title')</script>",
                        :body  => "<script>alert('xss in body')</script>")
  
    c.title.should == "alert('xss in title')"
    c.body.should  == "alert('xss in body')"
  end
  
  it "should use white-list sanitizer on specified fields" do
    e = Entry.create!(:title => "<script>alert('xss in title')</script>",
                      :body => "<script>alert('xss in body')</script>",
                      :extended => "<script>alert('xss in extended')</script>",
                      :person_id => 1)
  
    e.xss_terminate_options[:sanitize].should == [:body, :extended]
    e.title.should == "alert('xss in title')"
    e.body.should == ""
    e.extended.should === ""
  end
  
  it "should exclude specified fields from being sanitized" do
    p = Person.create!(:name => "<strong>Mallory</strong>")
  
    p.xss_terminate_options[:except].should == [:name]
    p.name.should === "<strong>Mallory</strong>"
  end
  
  it "should use html5lib sanitizer on specified fields" do
    r = Review.create!(:title => "<script>alert('xss in title')</script>",
                       :body => "<script>alert('xss in body')</script>",
                       :extended => "<script>alert('xss in extended')</script>",
                       :person_id => 1)
                       
    r.xss_terminate_options[:html5lib_sanitize].should == [:body, :extended]
    r.title.should == "alert('xss in title')"
    r.body.should == "&lt;script&gt;alert('xss in body')&lt;/script&gt;"
    r.extended.should == "&lt;script&gt;alert('xss in extended')&lt;/script&gt;"
  end
  
  it "should strip tags from one field and sanitize another" do
    p = Page.create!(:title => "<title>Helpless, helpless helpless</title>",
                     :contents => "<script>bad_move()</script><b>oh look out</b>")
                     
    p.title.should == 'Helpless, helpless helpless'
    p.contents.should == '<b>oh look out</b>'
  end
end
