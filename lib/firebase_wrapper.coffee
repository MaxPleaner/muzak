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
    @storage = firebase.storage()

  ready: ->
    @listen_for_audios()

  blob_from_ref_path: (ref_path) => new Promise (resolve, reject) =>
    @storage.ref(ref_path).getDownloadURL()
    .catch (e) => debugger
    .then (url) =>
      xhr = new XMLHttpRequest()
      xhr.responseType = 'blob'
      xhr.onload = (event) =>
        resolve xhr.response
      xhr.open "GET", url
      xhr.send()

  get_blob_url: (blob) ->
    URL.createObjectURL blob    

  listen_for_audios: ->
    ref = @realtime_db.ref("users/#{UID}/audios")
    ref.on "value", (snapshot) =>
      if UID
        obj = snapshot.val()
        if is_hash obj
          filenames = Object.keys(obj).map (key) ->
            "#{key}.webm"
          common_names = Object.values(obj).map (obj) ->
            obj.common_name
          Utils.sync_recording_state(filenames, common_names)
      else
        ref.off "value"
        return

  init_firebase_app: ->
    @firebase.initializeApp @firebase_opts

  store_audio: (blob, filename) ->
    ref = @build_audio_ref(filename)
    ref.put(blob)
    .then =>
      @store_audio_metadata filename, {common_name: filename}

  remove_audio: (filename) ->
    ref = @build_audio_ref filename
    ref.delete()
    .then =>
      @remove_audio_metadata filename

  build_audio_ref: (filename) ->
    @storage_root().child("users/#{UID}/audios/#{filename}")

  store_audio_metadata: (filename, data) ->
    file_key = filename.replace(".webm", "")
    @realtime_db.ref("users/#{UID}/audios/#{file_key}").set(data)
    
  remove_audio_metadata: (filename) ->
    file_key = filename.replace(".webm", "")
    @realtime_db.ref("users/#{UID}/audios/#{file_key}").remove()

  storage_root: ->
    @_storage_root ||= @storage.ref()

  firebase_opts:
    apiKey: "AIzaSyCLJ-tKpxLAKcOKtcy0zVumYKQhwaB7FXQ"
    authDomain: "muzak-f826c.firebaseapp.com"
    databaseURL: "https://muzak-f826c.firebaseio.com"
    projectId: "muzak-f826c"
    storageBucket: "muzak-f826c.appspot.com"
    messagingSenderId: "551367724099"