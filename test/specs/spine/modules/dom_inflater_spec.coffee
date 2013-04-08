describe "Exo.Spine.Modules.DOMInflater", ->

  beforeEach ->
    class Dummy extends Exo.Spine.Controller
      @include Exo.Spine.Modules.DOMInflater

    @controllerClass = Dummy

    class Post extends Spine.Model
      @configure 'Post', 'title', 'date', 'content', 'note'

    @postClass = Post

    @el = "
      <div data-post-id=\"64\">
        <h1 data-post-attribute=\"title\">Awesome title</h1>
        <h2 data-post-attribute=\"date\">2013-04-07</h2>
        <p data-post-attribute=\"content\">Interesting text</p>
        <p><span data-post-attribute=\"note\">some note</span></p>
      </div>
    "

  it 'should be includeable by controllers', ->
    @controller = new @controllerClass
    expect(typeof @controller['inflateFromDOM'] == 'function').to.equal true
    expect(typeof @controller['dashify'] == 'function').to.equal true

  it 'should correctly dashify model class-names', ->
    @controller = new @controllerClass
    name = @controller.dashify 'CamelCaseClassName'
    expect(name).to.equal 'camel-case-class-name'

  it 'should inflate a valid model from DOM', ->
    @controller = new @controllerClass
      el: @el

    model = @controller.inflateModel(@controller.el, @postClass)

    expect(model.id).to.equal '64'
    expect(model.title).to.equal 'Awesome title'
    expect(model.date).to.equal '2013-04-07'
    expect(model.content).to.equal 'Interesting text'
    expect(model.note).to.equal 'some note'

  it 'should inflate models from dom and create controllers in a list', ->
    class DummyList extends Exo.Spine.List
      @include Exo.Spine.Modules.DOMInflater

    el = "
      <div>
        <div data-post-id=\"64\">
          <h1 data-post-attribute=\"title\">Awesome title</h1>
          <h2 data-post-attribute=\"date\">2013-04-07</h2>
          <p data-post-attribute=\"content\">Interesting text</p>
          <p><span data-post-attribute=\"note\">some note</span></p>
        </div>
        <div data-post-id=\"65\">
          <h1 data-post-attribute=\"title\">Awesome title2</h1>
          <h2 data-post-attribute=\"date\">2013-04-08</h2>
          <p data-post-attribute=\"content\">Interesting text2</p>
          <p><span data-post-attribute=\"note\">some note2</span></p>
        </div>
      </div>
    "

    controller = new DummyList
      modelClass: @postClass
      el: $(el)


