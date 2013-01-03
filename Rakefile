require 'rubygems'
require 'bundler'
require 'pathname'
require 'logger'
require 'fileutils'

Bundler.require

ROOT        = Pathname(File.dirname(__FILE__))
LOGGER      = Logger.new(STDOUT)
BUNDLES     = %w( exo.coffee spine.coffee )
BUILD_DIR   = ROOT.join("lib")
SOURCE_DIR  = ROOT.join("src")

task :compile do
  sprockets = Sprockets::Environment.new(ROOT) do |env|
    env.logger = LOGGER
  end

  sprockets.append_path(SOURCE_DIR)

  BUNDLES.each do |bundle|
    assets = sprockets.find_asset(bundle)
    basename = assets.pathname.to_s.split('/')[-1].split(".").first

    assets.write_to(BUILD_DIR.join("#{basename}.js"))
  end
end