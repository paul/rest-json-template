require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "RestJsonTemplate" do

  class Article < Struct.new(:id, :title, :text); end
  
  class Scope
    include RestJson::Helper
  end

  def scope
    scope = Scope.new
    scope.instance_variable_set(:@article, article)
    scope
  end

  def article
    @article = Article.new(42, "The Answer", "Life, the Universe, and Everything")
  end

  def data
    @data ||= File.read(__FILE__).split("\n__END__\n").last
  end

  def template 
    @template ||= RestJson::Template.new('test.json.restjson') { data }
  end


  it 'should do something' do
    text = template.render(scope)
    pp text
  end

end

__END__
restjson_for(@article) do |json|

  json.href "http://example.com/articles/#{@article.id}"

  json.attributes :title, :text

  json.link_to :comments, "http://example.com/articles/#{@article.id}/comments"

end
