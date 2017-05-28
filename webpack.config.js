// ============================================================================
// Run with 'npm run dev'
// starts a server on localhost:8080
// ============================================================================

// ============================================================================
// Little trick so that that coffee-loader uses coffee 2
// ============================================================================

var coffeescript = require('coffee-script')
require.cache[require.resolve('coffee-script')] = require.cache[require.resolve('coffeescript')]

module.exports = {

// ============================================================================
// entry.coffee is the entry point
// ============================================================================

  entry: "./entry.coffee",

// ============================================================================
// with dev server the bundle.js only lives in memory
// ============================================================================

  output: {
    filename: "bundle.js"
  },

  module: {
    loaders: [

// ============================================================================
// load slim teplates to html strings (from javascript)
// example: require("html-loader./test.slim")
// ============================================================================

      {test: /\.slim$/, loader: ['slim-lang-loader']},

// ============================================================================
// Coffee script files are loaded like regular JS files:
// Foo = require("./foo.coffee")
// ============================================================================

      {test: /\.coffee$/, loader: 'coffee-loader'},

// ============================================================================
// Sass files once required are automatically attached to the dom.
// example: require("foo.sass")
// ============================================================================

      {test: /\.sass$/, loader: "style-loader!css-loader!sass-loader" },
      {exclude: ['./node_modules']},

// ============================================================================
// CSS files can be required too; they're also automatically put on the DOM
// ============================================================================

      {test: /\.css$/, loader: 'style-loader!css-loader'}

    ]
  },

  resolve: {

// ============================================================================
// An entry goes here for each of the extensions that get required
// ============================================================================

    extensions: [".js", ".coffee", ".slim", ".sass", ".css"],

// ============================================================================
// Something needed for Vue
// ============================================================================

    alias: {
      'vue$': 'vue/dist/vue.esm.js'
    }

  },

// ============================================================================
// Starts a static server with index.html at root
// ============================================================================

  context: __dirname,

};
