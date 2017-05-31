module.exports = class

  constructor: (deps) ->
    { @StaticDom, @Validations } = deps
    @add_event_listeners()

  add_event_listeners: ->
    StaticDom.sign_in_selector().on "click", @sign_in_selector_on_click
    StaticDom.register_selector().on "click", @register_selector_on_click
    StaticDom.sign_in_submit().on "click", @sign_in_submit_on_click
    StaticDom.register_submit().on "click", @register_submit_on_click

  sign_in_selector_on_click: =>
    StaticDom.sign_in_form().removeClass "hidden"
    StaticDom.register_form().addClass "hidden"

  register_selector_on_click: =>
    StaticDom.register_form().removeClass "hidden"
    StaticDom.sign_in_form().addClass "hidden"

  sign_in_submit_on_click: =>
    email = StaticDom.sign_in_email().val()
    pass = StaticDom.sign_in_pass().val()
    if @Validations.valid_credentials "sign_in", email, pass
      @firebase_login_request(email, pass)

  register_submit_on_click: =>
    email = StaticDom.register_email().val()
    pass = StaticDom.register_pass().val()
    pass_confirm = StaticDom.register_pass_confirm().val()
    if @Validations.valid_credentials "register", email, pass, pass_confirm
      @firebase_register_request(email, pass, pass_confirm)

  firebase_login_request: (email, pass) ->
    @firebase.auth().signInWithEmailAndPassword(email, pass)
    .catch @firebase_error

  firebase_register_request: (email, pass, password_confirm) ->
    @firebase.auth().createUserWithEmailAndPassword(email, pass)
    .catch @firebase_error

  firebase_error: (err) ->
    add_error("#{err.code} #{err.message}")