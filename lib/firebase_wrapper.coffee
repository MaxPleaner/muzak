# TODO

module.exports = FirebaseWrapper = load: (deps) -> class

  { firebase, StaticDom, Templates, config, state, JsPatches, Utils } = deps
  { is_hash } = JsPatches

  constructor: ->
    @app = firebase.initializeApp config.firebase_opts
    @realtime_db = firebase.database()
    @storage = firebase.storage()

  listen_for_audios: (callback) ->
    uid = state.current_user.uid
    ref = @realtime_db.ref("users/#{uid}/audios")
    ref.on "value", (snapshot) =>
      if uid
        obj = snapshot.val()
        if is_hash obj
          filenames = Object.keys(obj).map (key) -> "#{key}.webm"
          common_names = Object.values(obj).map (obj) -> obj.common_name
          callback({filenames, common_names})
      else
        ref.off "value"
        return

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
    uid = state.current_user.uid
    @storage_root().child("users/#{uid}/audios/#{filename}")

  store_audio_metadata: (filename, data) ->
    file_key = filename.replace(".webm", "")
    uid = state.current_user.uid
    @realtime_db.ref("users/#{uid}/audios/#{file_key}").set(data)
    
  remove_audio_metadata: (filename) ->
    file_key = filename.replace(".webm", "")
    uid = state.current_user.uid
    @realtime_db.ref("users/#{uid}/audios/#{file_key}").remove()

  storage_root: ->
    @_storage_root ||= @storage.ref()

