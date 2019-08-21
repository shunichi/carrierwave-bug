begin
  require "bundler/inline"
rescue LoadError
  $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
  raise
end

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "activerecord", "5.2.3"
  gem "carrierwave", "2.0.0"
  # gem "carrierwave", "1.3.1"
  gem "sqlite3"
end

require "active_record"
require "carrierwave"
require "minitest/autorun"

CarrierWave.root = Dir.pwd
CarrierWave.configure do |config|
  config.storage = :file
  config.enable_processing = false
end

ActiveSupport.on_load :active_record do
  require 'carrierwave/orm/activerecord'
end

class AvatarUploader < CarrierWave::Uploader::Base
end

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Schema.define do
  create_table :users do |t|
    t.column :avatar, :string
  end
end

class User < ActiveRecord::Base
  mount_uploader :avatar, AvatarUploader
end

class BugTest < Minitest::Test
  def test_cache
    user = User.create!(avatar: File.open("./test.jpg"))
    assert user.avatar.present?
    user.update!(avatar_cache: '')
    # Fail on carrierwave 2.0.0
    assert user.avatar.present?
  end
end
