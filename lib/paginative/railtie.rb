module Paginative
  class Railtie < ::Rails::Railtie #:nodoc:
    initializer 'paginative' do |_app|
      Paginative::Hooks.init
    end
  end
end
