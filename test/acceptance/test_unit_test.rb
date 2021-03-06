require 'test_helper'

class TestUnitTest < Test::Unit::TestCase
  include TestHelpers

  should "grab all tests" do
    body =<<-EOS
    def test_one
    end

    def test_two
    end
    EOS
    with_test_class(:body => body, :class_name => :FakeTest) do |file_name, path|
      set = Tack::TestSet.new
      tests = set.tests_for(path)
      assert_equal 2, tests.length
      assert_equal [file_name, ["FakeTest"], "test_one"], tests.sort.first
      assert_equal [file_name, ["FakeTest"], "test_two"], tests.sort.last
    end
  end

  should "find tests that match substring" do
    body=<<-EOS
    def test_one
    end
    def test_two
    end
    EOS
    with_test_class(:body => body, :class_name => :FakeTest) do |file_name, path|
      set = Tack::TestSet.new
      tests = set.tests_for(path, "two")
      assert_equal 1, tests.length
      assert_equal [file_name, ["FakeTest"], "test_two"], tests.first
    end
  end

  should "find tests that match regular expression" do
    body=<<-EOS
    def test_one
    end
    def test_two
    end
    EOS
    with_test_class(:body => body, :class_name => :FakeTest) do |file_name, path|
      set = Tack::TestSet.new
      tests = set.tests_for(path, /two/)
      assert_equal 1, tests.length
      assert_equal [file_name, ["FakeTest"], "test_two"], tests.first
    end
  end

  should "run failing test" do
    body =<<-EOS
    def test_append_length
      assert_equal ("ab".length - "cd".length), ("ab"+"cd").length
    end
EOS
    with_test_class(:body => body) do |file_name, path|
      set = Tack::TestSet.new
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)

      assert_equal 0, results[:passed].length
      assert_equal 1, results[:failed].length
      result = results[:failed].first
      assert_equal [path.to_s, ["FakeTest"], "test_append_length"], result[:test]
      assert_match /expected but was/, result[:failure][:message]
      assert_kind_of Array, result[:failure][:backtrace]
    end
  end

  should "run test with error" do
    body =<<-EOS
    def test_append_length
      raise "failing!"
    end
EOS
    with_test_class(:body => body) do |file_name, path|
      set = Tack::TestSet.new
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)

      assert_equal 0, results[:passed].length
      assert_equal 1, results[:failed].length
      result = results[:failed].first
      assert_equal [path.to_s, ["FakeTest"], "test_append_length"], result[:test]
      assert_match /was raised/, result[:failure][:message]
      assert_kind_of Array, result[:failure][:backtrace]
    end
  end

  should "run successful test" do
    body =<<-EOS
    def test_append_length
      assert_equal ("ab".length + "cd".length), ("ab"+"cd").length
    end
EOS
    with_test_class(:body => body) do |file_name, path|
      set = Tack::TestSet.new
      tests = set.tests_for(path)
      runner = Tack::Runner.new(path.parent)
      results = runner.run(tests)
      assert_equal 1, results[:passed].length
      assert_equal 0, results[:failed].length
      assert_equal [path.to_s, ["FakeTest"], "test_append_length"], results[:passed].first[:test]
    end    
  end

end
