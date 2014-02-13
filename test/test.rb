#!/usr/bin/env ruby
require "minitest/autorun"
require "minitest/reporters"

require "./lib/maxcdn"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

require "webmock"
include WebMock::API

host = "https://rws.maxcdn.com/alias"

headers = {
  'Authorization' => /.+/,
  'Cache-Control' => /.+/,
  'Content-Type'  => /application.+/,
  'Expect'        => /.*/,
  'User-Agent'    => "Ruby MaxCDN API Client"
}

stub_request(:post, host+"/zones/pull.json")
  .with(:body => 'foo=bar&bar=foo', :headers => headers)
  .to_return(:body => '{"foo": "bar"}')

stub_request(:post, host+"/zones/pull.json?foo=bar")
  .with(:headers => headers)
  .to_return(:body => '{"foo": "bar"}')

stub_request(:put, host+"/account.json")
  .with(:body => "foo=bar", :headers => headers)
  .to_return(:body => '{"foo":"bar"}')

#stub_request(:delete, host+"/zones/pull.json/12345/cache?files=foo.txt")
stub_request(:delete, host+"/zones/pull.json/12345/cache")
  .with(:body => "files=foo.txt", :headers => headers)
  .to_return(:body => '{"foo":"bar"}')

#stub_request(:delete, host+"/zones/pull.json/12345/cache?files[0]=foo.txt&files[1]=bar.txt")
stub_request(:delete, host+"/zones/pull.json/12345/cache")
  .with(:body => "files[0]=foo.txt&files[1]=bar.txt", :headers => headers)
  .to_return(:body => '{"foo":"bar"}')

# only post and put pass content-type header
headers.delete('Content-Type')

# get
stub_request(:get, host+"/account.json")
  .with(:headers => headers)
  .to_return(:body => '{"foo":"bar"}')

# delete
stub_request(:delete, host+"/zones/pull.json/12345/cache")
  .with(:headers => headers)
  .to_return(:body => '{"foo":"bar"}')

class Client < Minitest::Test

  def setup
    @max = MaxCDN::Client.new("alias", "key", "secret")
    @max.debug = true if ENV['DEBUG']
  end

  def test_initialize
    assert_equal "alias", @max.instance_variable_get(:@company_alias)
  end

  def test__connection_type
    assert_equal "https", @max._connection_type
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
    res = @max._response_as_json("get", "account.json")
    assert_equal({ "foo" => "bar" }, res)

    res = @max._response_as_json("post", "zones/pull.json?foo=bar")
    assert_equal({ "foo" => "bar" }, res)
  end

  def test__response_as_json_body
    res = @max._response_as_json("post", "zones/pull.json", { :body => true }, { "foo"=> "bar", "bar" => "foo" })
    assert_equal({ "foo" => "bar" }, res)
  end

  def test_get
    assert_equal({ "foo" => "bar" }, @max.get("account.json"))
  end

  def test_post
      assert_equal({ "foo" => "bar" }, @max.post("zones/pull.json", {"foo" => "bar", "bar" => "foo"}))
      assert_equal({ "foo" => "bar" }, @max.post("zones/pull.json?foo=bar"))
  end

  def test_put
    assert_equal({ "foo" => "bar" }, @max.put("account.json", {"foo"=>"bar"}))
  end

  def test_delete_cache
    assert_equal({ "foo" => "bar" }, @max.delete("zones/pull.json/12345/cache"))
  end

  def test_delete_cache_w_files
    assert_equal({ "foo" => "bar" }, @max.delete("zones/pull.json/12345/cache", { :files => "foo.txt" }))
  end

  def test_purge
    assert_equal({ "foo" => "bar" }, @max.purge(12345))
  end

  def test_purge_file
    assert_equal({ "foo" => "bar" }, @max.purge(12345, "foo.txt"))
  end

  def test_purge_files
    assert_equal({ "foo" => "bar" }, @max.purge(12345, [ "foo.txt", "bar.txt" ]))
  end
end

