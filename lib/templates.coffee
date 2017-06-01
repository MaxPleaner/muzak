module.exports = (->

  @$layout_content = $ require "html-loader!../templates/layout.slim"
  @$root_content   = $ require "html-loader!../templates/root.slim"
  @$auth_content   = $ require "html-loader!../templates/auth.slim"
  @$grid_content   = $ require "html-loader!../templates/grid.slim"

  this
  
).apply {}
