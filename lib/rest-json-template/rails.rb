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
      def restjson_for(resource, &blk)
        builder = RestJson::Builder.new(resource)
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

      view_context = ActionView::Base.for_controller(self)
      output = RfjPartialRenderer.new(view_context, options, nil).render

      if resource.is_a?(Array)
        # we're probably rendering a collection to be used in a collection document
        return output
      else
        self.content_type = Mime::JSON
        self.response_body = ActiveSupport::JSON.encode(output)
      end
    end

    class RfjPartialRenderer < ActionView::Partials::PartialRenderer

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

