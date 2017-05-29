module.exports = load: ({Deps}) -> (->

  { @StaticDom } = Deps

  @add_error = (error_text) ->
    $error = $("""
      <li class='error'></li>
    """).text msg
    @StaticDom.errors().append $error_text
    setTimeout $error.remove, 2500

  @valid_email = (email) ->
    regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    regex.test(email)

  @valid_password = (password) =>
    unless password.length >= 6
      @add_error "password must be >= 6 chars"
      return false
    true

  @valid_credentials = (type, email, password, pass_confirm) =>
    unless @valid_email(email)
      @add_error "email is not valid"
      return false
    unless @valid_password(password)
      @add_error "password is not valid"
      return false
    if type == "register"
      unless password == pass_confirm
        @add_error "password and confirmation aren't equal"
        return false
    true

  this

).apply {}
