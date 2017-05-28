module.exports = class

  initialize: ( {StaticDom, Templates, FirebaseWrapper }) ->

    Object.assign this, { StaticDom, Templates, FirebaseWrapper }
    @add_layout()
    @add_auth_listeners()
    @add_keyboard_shortcuts()
  
  add_layout: ->

    @StaticDom.layout_wrapper().append(Templates.$layout_content)

  add_auth_listeners: ->

    firebase.auth().onAuthStateChanged (user) ->
      if user
        @FirebaseWrapper.logged_in({StaticDom, Templates, user})
      else
        @FirebaseWrapper.logged_out({StaticDom, Templates})

  add_keyboard_shortcuts: ->

    $(document).on "keyup", (e) ->
      if e.which == 82 # the 'r' key
        $("#record").trigger "click"
  