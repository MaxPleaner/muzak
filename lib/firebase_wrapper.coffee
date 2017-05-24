# --------------------------------------------------
# useful resources:
# https://developer.mozilla.org/en-US/docs/Web/API/Blob
# https://firebase.google.com/docs/storage/web/upload-files
# --------------------------------------------------

module.exports = FirebaseWrapper = class

  constructor: ({firebase}) ->
    @firebase = firebase
    @app = @init_firebase_app()
    @realtime_db = firebase.database()

  ready: ->
    @listen_for_audios()

  listen_for_audios: ->
    ref = @realtime_db.ref("users/#{UID}/audios")
    ref.on "value", (snapshot) =>
      debugger

  init_firebase_app: ->
    @firebase.initializeApp @firebase_opts

  store_audio: (blob, filename) ->
    ref = @root_ref().child("users/#{UID}/audios/#{filename}")
    @store_audio_metadata filename, {status: "OK"}
    ref.put(blob)
    .then (snapshot) =>
  
      filenames = Object.keys(snapshot.val())

  store_audio_metadata: (filename, data) ->
    file_key = filename.replace(".webm", "")
    @realtime_db.ref("users/#{UID}/audios/#{file_key}").set(data)
    
  root_ref: ->
    @_root_ref ||= firebase.storage().ref()

  firebase_opts:
    apiKey: "AIzaSyCLJ-tKpxLAKcOKtcy0zVumYKQhwaB7FXQ"
    authDomain: "muzak-f826c.firebaseapp.com"
    databaseURL: "https://muzak-f826c.firebaseio.com"
    projectId: "muzak-f826c"
    storageBucket: "muzak-f826c.appspot.com"
    messagingSenderId: "551367724099"