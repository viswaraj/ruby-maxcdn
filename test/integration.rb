require "curb-fu"
require "minitest/autorun"
require "minitest/reporters"
require "./lib/maxcdn"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

if (ENV["ALIAS"].nil? or ENV["KEY"].nil? or ENV["SECRET"].nil?)
  abort "Please export ALIAS, KEY and SECRET with your credentials and ensure that you're test host's IP is whitelisted."
end

class Client < Minitest::Test

  def setup
    @max  = MaxCDN::Client.new(ENV["ALIAS"], ENV["KEY"], ENV["SECRET"])
    @time = Time.now.to_i.to_s
  end

  def test_initialize
    assert_equal ENV["ALIAS"], @max.instance_variable_get(:@company_alias)
  end

  def test_get
    [ "account.json",
      "account.json/address",
      "users.json",
      "zones.json"
    ].each do |end_point|
      key = end_point.include?("/") ? end_point.split("/")[1] : end_point.replace(".json", "")

      assert @max.get(end_point)["data"][key], "get #{key} with data"
    end
  end

  def test_post

    zone = {
      :name => @time,
      :url  => "http://www.example.com"
    }

    assert @max.post("zones/pull.json", zone)["data"]["pullzone"]["id"]

    # for test_delete
    @delete_zone = @max.post("zones/pull.json", zone)["data"]["pullzone"]["id"]
  end

  def test_delete
    assert_equal 200, @max.delete("zones/pull.json/#{@delete_zone}")["code"], "delete successful"
  end

  def test_put
    name = @time + "_put"
    assert_equal name, @max.put("account.json", { :name => name })["data"]["account"]["name"], "put successful"
  end

  def test_purge
    @zone = @max.get("zones/pull.json")["data"]["pullzones"][0]["id"]
    assert_equal 200, @max.purge(@zone)["code"], "purge successful"
  end

  def test_purge_file
    @popularfiles = @max.get("reports/popularfiles.json")["data"]["popularfiles"]
    assert_equal 200, @max.purge(@zone, @popularfiles[0]["uri"])["code"], "purge file successful"
  end

  def test_purge_files
    assert_equal 200, @max.purge(@zone, [ @popularfiles[0]["uri"], @popularfiles[1]["uri"]])["code"], "purge files successful"
  end
end

