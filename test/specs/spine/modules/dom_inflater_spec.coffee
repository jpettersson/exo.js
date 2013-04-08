describe "Exo.Spine.Modules.DOMInflater", ->

  beforeEach ->
    class Dummy extends Exo.Spine.Controller
      @include Exo.Spine.Modules.DOMInflater

    @controllerClass = Dummy

    class Post extends Spine.Model
      @configure 'Post', 'title', 'date', 'content', 'note'

    @postClass = Post

    class PostApocalypse extends Spine.Model
      @configure 'PostApocalypse', 'title', 'date', 'content', 'note'

    @postApocalypseClass = PostApocalypse

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
      modelClass: @postClass
      el: @el

    model = @controller.inflateModel(@controller.el, 'Post')

    expect(model.id).to.equal '64'
    expect(model.title).to.equal 'Awesome title'
    expect(model.date).to.equal '2013-04-07'
    expect(model.content).to.equal 'Interesting text'
    expect(model.note).to.equal 'some note'


  it 'should inflate models from dom and tag templates in a list', ->
    class DummyList extends Exo.Spine.List
      @include Exo.Spine.Modules.DOMInflater

    postTemplate = (model)-> 
      "<div data-post-id=\"#{model.id}\">
          <h1 data-post-attribute=\"title\">#{model.title}</h1>
          <h2 data-post-attribute=\"date\">#{model.date}</h2>
          <p data-post-attribute=\"content\">#{model.content}</p>
          <p><span data-post-attribute=\"note\">#{model.note}</span></p>
        </div>"

    postApocalypseTemplate = (model)-> 
      "<div data-post-apocalypse-id=\"#{model.id}\">
          <h1 data-post-apocalypse-attribute=\"title\">#{model.title}</h1>
          <h2 data-post-apocalypse-attribute=\"date\">#{model.date}</h2>
          <p data-post-apocalypse-attribute=\"content\">#{model.content}</p>
          <p><span data-apocalypse-post-attribute=\"note\">#{model.note}</span></p>
        </div>"

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
        <div class=\"apocalypse\" data-post-apocalypse-id=\"80\">
          <h1 data-post-apocalypse-attribute=\"title\">Apocalypse!</h1>
          <h2 data-post-apocalypse-attribute=\"date\">20XX-XX-XX</h2>
          <p data-post-apocalypse-attribute=\"content\">Interesting text3</p>
          <p><span data-post-apocalypse-attribute=\"note\">some note3</span></p>
        </div>
      </div>
    "

    controller = new DummyList
      modelClasses: [@postClass, @postApocalypseClass]

      templates: 
        Post: postTemplate
        PostApocalypse: postApocalypseTemplate

      el: $(el)

    #console.log $(controller.el).children(['data-item'])
    len = controller.el.children(['data-item']).length
    expect(len).to.equal 3

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
      template: postTemplate

      el: $(el)

    #console.log $(controller.el).children(['data-item'])
    len = controller.el.children(['data-item']).length
    expect(len).to.equal 2


  it 'should inflate models from dom and create controllers in a list', ->
    class DummyList extends Exo.Spine.List
      @include Exo.Spine.Modules.DOMInflater

    postTemplate = (model)-> 
      "<div data-post-id=\"#{model.id}\">
          <h1 data-post-attribute=\"title\">#{model.title}</h1>
          <h2 data-post-attribute=\"date\">#{model.date}</h2>
          <p data-post-attribute=\"content\">#{model.content}</p>
          <p><span data-post-attribute=\"note\">#{model.note}</span></p>
        </div>"

    postApocalypseTemplate = (model)-> 
      "<div data-post-apocalypse-id=\"#{model.id}\">
          <h1 data-post-apocalypse-attribute=\"title\">#{model.title}</h1>
          <h2 data-post-apocalypse-attribute=\"date\">#{model.date}</h2>
          <p data-post-apocalypse-attribute=\"content\">#{model.content}</p>
          <p><span data-apocalypse-post-attribute=\"note\">#{model.note}</span></p>
        </div>"

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
        <div class=\"apocalypse\" data-post-apocalypse-id=\"80\">
          <h1 data-post-apocalypse-attribute=\"title\">Apocalypse!</h1>
          <h2 data-post-apocalypse-attribute=\"date\">20XX-XX-XX</h2>
          <p data-post-apocalypse-attribute=\"content\">Interesting text3</p>
          <p><span data-post-apocalypse-attribute=\"note\">some note3</span></p>
        </div>
      </div>
    "

    class PostItemController extends Exo.Spine.Controller
      prepareWithModel: (model)->
        @model = model

      render: ->
        @html postTemplate(@model)

    class PostApocalypseItemController extends Exo.Spine.Controller
      prepareWithModel: (model)->
        @model = model

      render: ->
        @html postApocalypseTemplate(@model)

    # Using multiple Models -> Controller mappings
    controller = new DummyList
      modelClasses: [@postClass, @postApocalypseClass]

      controllers: 
        Post: PostItemController
        PostApocalypse: PostApocalypseItemController

      el: $(el)

    len = controller.el.children(['data-item']).length
    expect(len).to.equal 3

    expect(controller.children().length).to.equal 3

    # Using a single Model -> Controller mapping
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
    "

    controller = new DummyList
      modelClass: @postClass
      controller: PostItemController

      el: $(el)

    len = controller.el.children(['data-item']).length
    expect(len).to.equal 2

    expect(controller.children().length).to.equal 2