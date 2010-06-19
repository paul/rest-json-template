require 'action_view/template'

module RestfulJson
  module Rails
    class RestJson < ActionView::Template::Handler

      def self.call(template)
        new(template).compile
      end

      def initialize(template)
        @template = template
      end

      def compile
        "obj = #{@template.source}\nobj.to_obj"
      end

      ActionView::Template.register_template_handler :rfj, self
    end

    module Helpers
      def restful_json_for(resource, &blk)
        builder = ::RestJson::Builder.new(resource)
        yield builder
        builder
      end

      ActionView::Helpers.send(:include, self)
    end

    ActionController::Renderers.add :rfj_collection do |resources, options|
      self.content_type = Mime::JSON
      json = {
        :href => request.url,
        :items => render(:rfj => resources)
      }
      json = ActiveSupport::JSON.encode(json)
      self.response_body = json
    end

    ActionController::Renderers.add :rfj do |resource, options|
      options[:partial] = resource

      view_context = self.view_context
      output = RfjPartialRenderer.new(view_context, options, nil).render

      if resource.respond_to?(:each)
        # we're probably rendering a collection to be used in a collection document
        return output
      else
        self.content_type = Mime::JSON
        self.response_body = ActiveSupport::JSON.encode(output)
      end
    end

    class RfjPartialRenderer < ActionView::Partials::PartialRenderer

      def render_collection
        return nil if @collection.blank?

        if @options.key?(:spacer_template)
          spacer = find_template(@options[:spacer_template]).render(@view, @locals)
        end

        result = @template ? collection_with_template : collection_without_template
        #result.join(spacer).html_safe
      end


      def find_template(path=@path)
        return path unless path.is_a?(String)
        prefix = @view.controller_path unless path.include?(?/)
        @view.find_template(path, prefix, false)
      end

    end

  end

end

