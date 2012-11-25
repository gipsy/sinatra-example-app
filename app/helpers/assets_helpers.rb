require 'sinatra/base'

module Sinatra
  module AssetHelpers
    # +options+ can pass "force_production" to trump env setting
    # if digest is used in the future, will need to incorporate this into these two helpers
    def stylesheets_tag(options = {})
      if settings.production? || options[:force_production]
        '<link rel="stylesheet" href="/compiled/css/application.min.css" type="text/css" media="all" />'
      else
        '<link rel="stylesheet" href="/assets/application.css" type="text/css" media="all" />'
      end
    end

    def javascripts_tag(options = {})
      if settings.production? || options[:force_production]
        '<script src="/compiled/js/application.min.js" type="text/javascript"></script>'
      else
        '<script src="/assets/application.js" type="text/javascript"></script>'
      end
    end

  end
end