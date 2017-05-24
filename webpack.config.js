// Little trick so that that coffee-loader uses coffee 2

var coffeescript = require('coffee-script')
require.cache[require.resolve('coffee-script')] = require.cache[require.resolve('coffeescript')]

module.exports = {

  entry: "./entry.coffee",

  // the bundle is stored in memory, though it's referenced by this path

  output: {
    filename: "bundle.js"
  },

  module: {
    loaders: [

      // load slim teplates to html strings (from javascript)
      // example: require("html-loader./test.slim")
      {test: /\.slim$/, loader: ['slim-lang-loader']},

      // Coffee script files are loaded like regular JS files:
      // Foo = require("./foo.coffee")
      {test: /\.coffee$/, loader: 'coffee-loader'},

      // Sass files once required are automatically attached to the dom.
      // example: require("foo.sass")
      {test: /\.sass$/, loader: "style-loader!css-loader!sass-loader" },
      {exclude: ['./node_modules']},

      {test: /\.css$/, loader: 'style-loader!css-loader'}

    ]
  },

  resolve: {

    // Put an entry here for each of the extensions which has a loader
    extensions: [".js", ".coffee", ".slim", ".sass", ".css"],

    // Something needed for Vue
    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }

  },

  // Starts a static server with index.html at root
  context: __dirname,

};
