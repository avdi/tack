require 'test_helper'

class TestSetTest < Test::Unit::TestCase
  include TestHelpers
  include Tack

  class FakeAdapter1

    def self.tests
      [
       ["foo_test.rb", ["Foo", "sometimes"], "test something"], 
       ["foo_test.rb", ["Foo", "in certain cases"], "it does something"],
      ]
    end

    def tests_for(path)
      self.class.tests
    end

  end

  should "grab all tests by default" do 
    test_set = TestSet.new(FakeAdapter1.new)
    assert_equal FakeAdapter1.tests, test_set.tests_for("foo_test.rb")
  end

  should "filter description based on string" do
    test_set = TestSet.new(FakeAdapter1.new)
    assert_equal [["foo_test.rb", ["Foo", "in certain cases"], "it does something"]], 
    test_set.tests_for("foo_test.rb", "does something")
  end

  should "filter description based on regexp" do
    test_set = TestSet.new(FakeAdapter1.new)
    assert_equal [["foo_test.rb", ["Foo", "in certain cases"], "it does something"]], 
    test_set.tests_for("foo_test.rb", /does/)
  end

  should "filter context based on string" do
    test_set = TestSet.new(FakeAdapter1.new)
    assert_equal [["foo_test.rb", ["Foo", "sometimes"], "test something"]], 
    test_set.tests_for("foo_test.rb", 'times')
  end

  should "filter context based on regexp" do
    test_set = TestSet.new(FakeAdapter1.new)
    assert_equal [["foo_test.rb", ["Foo", "sometimes"], "test something"]], 
    test_set.tests_for("foo_test.rb", /times/)
  end

  class FakeAdapter2
    
    def tests_for(path)
      case path
      when /foo_test\.rb/
        [["foo_test.rb", ["Foo"], "test foo"]]
      when /bar_test\.rb/
        [["bar_test.rb", ["Bar"], "test bar"]]
      end
    end

  end
  
  should "get tests from all test files within directory" do
    within_construct(false) do |c|
      c.directory 'test_dir' do |d|
        d.file 'bar_test.rb'
        d.file 'foo_test.rb'
      end
      test_set = TestSet.new(FakeAdapter2.new)
      tests = test_set.tests_for(c+'test_dir') 
      assert_equal [["bar_test.rb", ["Bar"], "test bar"],
                    ["foo_test.rb", ["Foo"], "test foo"]], tests
    end
  end

  should "skip over non-test files" do
    within_construct(false) do |c|
      c.directory 'test_dir' do |d|
        d.file 'foo.rb' # not a test file
      end
      adapter = stub_everything(:tests_for => [["foo_test.rb", ["Foo"], "test foo"]])
      test_set = TestSet.new(adapter)
      tests = test_set.tests_for(c+'test_dir') 
      assert_equal [], tests
    end

    
  end

end
