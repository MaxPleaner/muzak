module.exports = {}

  # This object gets methods added to it dynamically.
  # This happens in the entry.coffee constructor.

  # The method generator is build_dom_methods.coffee
  # The method list is dom_graph.coffee

  # The point of all this is to have a static list of references to the DOM.
  # Each gets turned into a function which automatically caches.
  # The caching can disabled by passing a single argument of false