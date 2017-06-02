module.exports = load: (deps) ->

  root: require "./template_callbacks/root.coffee"
  auth: require "./template_callbacks/auth.coffee"
  grid: require("./template_callbacks/grid.coffee").load(deps)


