require "nest"

module Redpear

  def self.autoload(const, path = nil)
    path ||= "redpear/#{const.to_s.downcase}"
    super const, path
  end

  autoload :Column
  autoload :Concern
  autoload :Connection
  autoload :Expiration
  autoload :Finders
  autoload :Index
  autoload :Model
  autoload :Namespace
  autoload :Nest
  autoload :Persistence
  autoload :Schema

end
