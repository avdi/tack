require 'test_helper'

class ShouldaTest < Test::Unit::TestCase
  include TestHelpers

  should "run tests that match substring" do
    body = <<-EOS
    should "do something" do
    end

    should "do nothing" do
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path, "some")
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.length
    end
  end

  should "run tests that match regular expression" do
    body = <<-EOS
    should "do something" do
    end

    should "do nothing" do
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path, /nothing/)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.length
    end
  end

  should "run tests that are in context which matches regexp" do
    body = <<-EOS
    context "sometimes" do
      context "in some cases" do

        should "do something" do
        end

        should "do another thing" do
        end

      end
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path, /cases/)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 2, result_set.length
    end
  end

  should "run failing spec" do
    body = <<-EOS
    should "append length is sum of component string lengths" do
      assert_equal ("ab"+"cd").length, ("ab".length - "cd".length)
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.failed.length
    end
  end

  should "run spec that raises error" do
    body = <<-EOS
    should "append length is sum of component string lengths" do
      raise "failing!"
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.failed.length
    end
  end

  should "run successful spec" do
    body = <<-EOS
    should "append length is sum of component string lengths" do
      assert_equal ("ab"+"cd").length, ("ab".length + "cd".length)
    end
    EOS
    with_test_class :body => body do |file_name, path|
      raw_results = Tack::Runner.run_tests(path.parent, path)
      result_set = Tack::ResultSet.new(raw_results)
      assert_equal 1, result_set.passed.length
    end
  end

  context "in a context" do
    
    should "run successful spec" do
      body = <<-EOS
        context "in all cases" do
          should "append length is sum of component string lengths" do
            assert_equal ("ab"+"cd").length, ("ab".length + "cd".length)
          end
        end
      EOS
      with_test_class :body => body do |file_name, path|
        raw_results = Tack::Runner.run_tests(path.parent, path)
        result_set = Tack::ResultSet.new(raw_results)
        assert_equal 1, result_set.passed.length
      end
    end

  end

end
