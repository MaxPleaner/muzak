module.exports = load: (deps) ->

  { StaticDom, Templates, Utils } = deps

  class

    initialize: (deps) ->
      
      @add_layout()
      @add_auth_listeners()
      @add_keyboard_shortcuts()
    
    add_layout: ->

      StaticDom.layout_wrapper().append(Templates.$layout_content)

    add_auth_listeners: ->

      firebase.auth().onAuthStateChanged (user) ->
        if user
          Utils.logged_in(user)
        else
          Utils.logged_out()

    add_keyboard_shortcuts: ->

      $(document).on "keyup", (e) ->
        if e.which == 82 # the 'r' key
          $("#record").trigger "click"
    