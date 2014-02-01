require "curb-fu"

require "minitest/autorun"
require "minitest/mock"
require "minitest/reporters"

#require "signet/oauth_1/client"
require "./lib/maxcdn"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

class Client < Minitest::Test

  def new_response
    response = Minitest::Mock.new
    response.expect(:body, '{ "foo": "bar" }')
    response.expect(:success?, true)
    response
  end

  def setup
    @max = MaxCDN::Client.new("alias", "key", "secret")
  end

  def test_initialize
    assert_equal "alias", @max.instance_variable_get(:@company_alias)
  end

  def test__connection_type
    assert_equal "https", @max._connection_type

    m = MaxCDN::Client.new("alias", "key", "secret", "foo", false)
    assert_equal "http", m._connection_type
  end

  def test__encode_params
    assert_equal "foo=foo%20bar&bah=boo",
      @max._encode_params({ :foo => "foo bar", :bah => "boo" })
  end

  def test__get_url
    assert_equal "https://rws.maxcdn.com/alias/foo",
      @max._get_url("/foo")
    assert_equal "https://rws.maxcdn.com/alias/foo?foo=foo%20bar",
      @max._get_url("/foo", { :foo => "foo bar" })
  end

  def test__response_as_json_standard
    response = new_response
    CurbFu::Request.stub :get, response do
      res = @max._response_as_json("get", "http://example.com")
      assert res
      assert response.verify
    end
  end

  def test__response_as_json_standard
    response = new_response
    CurbFu::Request.stub :get, response do
      res = @max._response_as_json("get", "http://example.com",
                                   { :debug_request => true })
      assert res.body
    end
  end

  def test_get
    response = new_response
    CurbFu::Request.stub :get, response do
      assert_equal({ "foo" => "bar" }, @max.get("/foo"))
    end
    assert response.verify
  end

  def test_post
    response = new_response
    CurbFu::Request.stub :post, response do
      assert_equal({ "foo" => "bar" }, @max.post("/foo"))
    end
    assert response.verify
  end

  def test_delete
    response = new_response
    CurbFu::Request.stub :delete, response do
      assert_equal({ "foo" => "bar" }, @max.delete("/foo"))
    end
    assert response.verify
  end

  def test_delete
    response = new_response
    CurbFu::Request.stub :delete, response do
      assert_equal({ "foo" => "bar" }, @max.purge(12345))
    end
    assert response.verify
  end
end

