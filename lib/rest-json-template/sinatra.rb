require 'tilt'

module Sinatra
  module RestfulJson

    module Helpers

      def rfj_collection(resources)
        json = {
          :href => request.url,
          :items => resources.map { |resource| rfj(resource, :skip_encoding => true) }
        }

        response['Content-Type'] = "application/json"
        json = Yajl::Encoder.encode(json)
      end

      def rfj(resource, options = {})
        template = resource.class.to_s.downcase
        p template
        render :rfj, template, options, locals
      end

    end

    def self.registered(app)
      app.helpers(RestfulJson::Helpers)
    end

  end

  register RestfulJson
end

module RestfulJson
  class Template < Tilt::Template

    def prepare
    end

    def evaluate(scope, locals, &block)
      code = ::RestJson::Engine.new

    end


  end

  Tilt.register(:rfj, Template)
end
