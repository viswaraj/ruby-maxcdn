#!/usr/bin/env ruby
require "minitest/autorun"
require "minitest/reporters"

require "./lib/ext/hash"

class Client < Minitest::Test
  def test_to_params_basic
    assert_equal "foo=bar", { "foo" => "bar" }.to_params
    assert_equal "foo=bar&bar=foo", { :foo => "bar", :bar => "foo" }.to_params
  end

  def test_to_params_escape
    assert_equal "foo%20bar=bar%20boo", { "foo bar" => "bar boo" }.to_params
  end

  def test_to_params_array
    assert_equal "foo[0]=bar&foo[1]=boo", { "foo" => [ "bar", "boo" ] }.to_params
    assert_equal "foo[0]=bar&foo[1]=boo", { :foo => [ :bar, :boo ] }.to_params
  end

  def test_to_params_crazy
    assert_equal "a=1&c=%40%24%5E%24%23%25%26%23%26&%3F%21=asdf&1=FDAS&b[0]=a&b[1]=b&b[2]=c", {
        :a => 1,
        :b => [ :a, :b, :c ],
        :c => "@$^$#%&#&",
        "?!" => "asdf",
        1 => "FDAS"
      }.to_params
  end

end
