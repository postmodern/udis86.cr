require "../src/udis86"
require "spectator"

module Fixtures
  ROOT = File.expand_path("./fixtures",__DIR__)

  def self.path(name)
    File.join(ROOT,name)
  end

  def self.[](name)
    File.open(path(name)) do |io|
      bytes = Bytes.new(io.size)
      io.read(bytes)
      
      return String.new(bytes)
    end
  end
end

Spectator.configure do |config|
  config.formatter = Spectator::Formatting::DocumentFormatter.new
end
