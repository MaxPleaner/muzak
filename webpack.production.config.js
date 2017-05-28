



// --------------------------------------------------
// Gets run with 'npm deploy'
// Builds dist/bundle.js
// --------------------------------------------------

var coffeescript = require('coffee-script')
require.cache[require.resolve('coffee-script')] = require.cache[require.resolve('coffeescript')]

module.exports = {

  entry: "./entry.coffee",

  output: {
    filename: "dist/bundle.js"
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
      {exclude: ['./node_modules']}

    ]
  },

  resolve: {

    extensions: [".js", ".coffee", ".slim", ".sass", ".css"],

    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }

  },

  context: __dirname,

};
