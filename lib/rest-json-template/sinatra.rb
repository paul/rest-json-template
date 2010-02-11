require 'tilt'

module RestJson
  module SinatraHelper
    def restjson_for(resource, &blk)
      builder = RestJson::Builder.new(resource)
      yield builder
      builder
    end
  end
  Sinatra.helpers(SinatraHelper)

  class Template < Tilt::Template

    def compile!
    end

    def evaluate(scope, locals, &block)
      scope.instance_eval(data)
    end
  end

  Tilt.register('restjson', Template)
end
