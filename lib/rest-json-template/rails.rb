
module RestJson
  module Rails
    class RestJson < ActionView::TemplateHandlers::TemplateHandler

      def self.call(template)
        new(template).compile
      end

      def initialize(template)
        @template = template
      end

      def compile
        "obj = #{@template.source}\nobj.to_obj"
      end

      ActionView::Template.register_template_handler :restjson, self
    end

    module Helpers
      def restjson_for(resource, &blk)
        builder = RestJson::Builder.new(resource)
        yield builder
        builder
      end

      ActionView::Helpers.send(:include, self)
    end

    ActionController::Renderers.add :ssj_collection do |resources, options|
      self.content_type = Mime::SSJ
      json = {
        :href => request.url,
        :items => render(:ssj => resources)
      }
      json = ActiveSupport::JSON.encode(json)
      self.response_body = json
    end

    ActionController::Renderers.add :ssj do |resource, options|
      options[:partial] = resource

      view_context = ActionView::Base.for_controller(self)
      output = SsjPartialRenderer.new(view_context, options, nil).render

      if resource.is_a?(Array)
        # we're probably rendering a collection to be used in a collection document
        return output
      else
        self.content_type = Mime::SSJ
        self.response_body = ActiveSupport::JSON.encode(output)
      end
    end

    class SsjPartialRenderer < ActionView::Partials::PartialRenderer

      def render_collection
        @template = template = find_template

        return nil if @collection.blank?

        result = template ? collection_with_template(template) : collection_without_template
        # This forces the results into a string, so don't do it!
        #result.join(spacer).html_safe!
      end

      def _find_template(path)
        if controller = @view.controller
          prefix = controller.controller_path unless path.include?(?/)
        end

        #@view.find(path, {:formats => @view.formats}, prefix, true)
        # Pretend we're not a partial, so we find the non-underscored template
        @view.find(path, {:formats => @view.formats}, prefix, false)
      end

    end

  end

end

