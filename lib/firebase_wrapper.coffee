# --------------------------------------------------
# useful resources:
# https://developer.mozilla.org/en-US/docs/Web/API/Blob
# https://firebase.google.com/docs/storage/web/upload-files
# --------------------------------------------------

module.exports = FirebaseWrapper = class

  constructor: ({firebase}) ->
    @firebase = firebase
    @app = @init_firebase_app()

  init_firebase_app: ->
    @firebase.initializeApp @firebase_opts

  store_audio: (blob, filename) ->
    ref = @root_ref().child("audios/#{filename}")
    ref.put(blob)
    .then (snapshot) =>
      console.log snapshot
    .catch (e) =>
      debugger

  root_ref: ->
    @_root_ref ||= firebase.storage().ref()

  firebase_opts:
    apiKey: "AIzaSyCLJ-tKpxLAKcOKtcy0zVumYKQhwaB7FXQ"
    authDomain: "muzak-f826c.firebaseapp.com"
    databaseURL: "https://muzak-f826c.firebaseio.com"
    projectId: "muzak-f826c"
    storageBucket: "muzak-f826c.appspot.com"
    messagingSenderId: "551367724099"