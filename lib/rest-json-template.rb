require 'active_support/ordered_hash'
require 'tilt'
require 'yajl'


module RestJson

  class Template < Tilt::Template

    def compile!
    end

    def evaluate(scope, locals, &block)
      scope.instance_eval(data)
    end
  end
  Tilt.register('restjson', Template)

  module Helper
    def restjson_for(resource, &blk)
      builder = RestJson::Builder.new(resource)
      yield builder
      builder.render
    end
  end

  class Builder

    def initialize(resource)
      @resource = resource
      @attributes = ActiveSupport::OrderedHash.new
      set_keys!
    end

    def set_keys!
      @attributes[:_type] = @resource.class.to_s.split('::').last
    end

    def href(href)
      @attributes[:href] = href
    end

    def attributes(*keys)
      keys = keys.flatten
      if keys.first.is_a?(Hash)
        @attributes.merge!(keys.first)
      else
        keys.each do |name|
          @attributes[name] = @resource.send(name)
        end
      end
    end
    alias attribute attributes

    def link_to(name, url)
      name = name.to_s
      name << "_href" unless name =~ /_href\Z/
      attribute(name => url)
    end

    def render
      Yajl::Encoder.encode(@attributes)
    end

  end

end
