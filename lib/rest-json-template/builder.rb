require 'active_support/ordered_hash'
require 'yajl'

module RestJson

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
    alias to_s render
    alias to_json render

    def to_h
      @attributes
    end
    alias to_obj to_h

    def method_missing(meth, *args)
      if @resource.respond_to?(meth)
        @resource.send(meth, *args)
      else
        super
      end
    end

  end
end
