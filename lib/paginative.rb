require "paginative/engine"
require 'geocoder'

module Paginative
end

# load Rails/Railtie
begin
  require 'rails'
rescue LoadError
  #do nothing
end

# Load All the stuff we need
require 'paginative/models/model_extension'

# if not using Railtie, call `Ragamuffins::Hooks.init` directly
if defined? Rails
  require 'paginative/railtie'
end
