Contact = require './models/contact'
ContactItem = require './controllers/contact_item'

class App extends Exo.Spine.Controller

  elements: 
    '.contacts': 'listEl'

  prepare: ->
    @list = new Exo.Spine.List
      modelClass: Contact
      controller: ContactItem
      el: @listEl

$ ->
  el: ($ 'body')
