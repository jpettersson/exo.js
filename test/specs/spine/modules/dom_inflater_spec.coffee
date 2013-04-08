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
      modelClass: @postClass

    @controller.inflateFromDOM()

    expect(@controller.model.id).to.equal '64'
    expect(@controller.model.title).to.equal 'Awesome title'
    expect(@controller.model.date).to.equal '2013-04-07'
    expect(@controller.model.content).to.equal 'Interesting text'
    expect(@controller.model.note).to.equal 'some note'