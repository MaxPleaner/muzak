# TODO

#logged_in StaticDom, Templates, user

    # window.UID = user.uid
    # db.ready()
    # $auth_content.remove()
    # $root_wrapper = $ "#root-wrapper"
    # $root_wrapper.append($root_content)
    # $grid_wrapper = $root_content.find "#grid-wrapper"
    # $grid_wrapper.append $grid_content
    # $credentials = $root_content.find "#credentials"
    # $credentials.text "logged in as #{user.email}"

#logged_out StaticDom, Templates

    # window.UID = null
    # $root_content.remove()
    # $auth_wrapper = $ "#auth-wrapper"
    # $auth_wrapper.append $auth_content

module.exports = FirebaseWrapper = class

# ============================================================================
# Initialized with a firebase app factory.
# the storage and database packages are assumed to have been required
# and their respective functions added to the factory
# ============================================================================

  constructor: ({firebase}) ->
    @firebase = firebase
    @app = @init_firebase_app()
    @realtime_db = firebase.database()
    @storage = firebase.storage()

  init_firebase_app: ->
    @firebase.initializeApp @firebase_opts

# ============================================================================
# A generic "start" method; more things could be added here.
# This is called whenever a user is logged in.
# Auth is handled separately.
# ============================================================================

  ready: ->
    @listen_for_audios()

# ============================================================================
# Listens for the value of the user's recorded audio list
# calls Utils.sync_recording_state with the results
# ============================================================================

  listen_for_audios: ->
    ref = @realtime_db.ref("users/#{UID}/audios")
    ref.on "value", (snapshot) =>
      if UID
        obj = snapshot.val()
        if is_hash obj
          filenames = Object.keys(obj).map (key) -> "#{key}.webm"
          common_names = Object.values(obj).map (obj) -> obj.common_name
          Utils.sync_recording_state(filenames, common_names)
      else
        ref.off "value"
        return

# ============================================================================
# Fetches an audio blob from firebase (returns promise)
# ============================================================================

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

# ============================================================================
# Creates a URL for a blob that's already in the browser.
# This URL only works within the user's own browser.
# It's can be used as the src for an audio tag.
# ============================================================================

  get_blob_url: (blob) ->
    URL.createObjectURL blob    

# ============================================================================
# Uploads a blob to firebase
# ============================================================================

  store_audio: (blob, filename) ->
    ref = @build_audio_ref(filename)
    ref.put(blob)
    .then =>
      @store_audio_metadata filename, {common_name: filename}

# ============================================================================
# Deletes a blob from firebase
# ============================================================================

  remove_audio: (filename) ->
    ref = @build_audio_ref filename
    ref.delete()
    .then =>
      @remove_audio_metadata filename

# ============================================================================
# Build a storage key for a blob
# ============================================================================

  build_audio_ref: (filename) ->
    @storage_root().child("users/#{UID}/audios/#{filename}")

# ============================================================================
# Store a record of a recording in the realtime database
# ============================================================================

  store_audio_metadata: (filename, data) ->
    file_key = filename.replace(".webm", "")
    @realtime_db.ref("users/#{UID}/audios/#{file_key}").set(data)
    
# ============================================================================
# Remove a record of a recording in the realtime database
# ============================================================================

  remove_audio_metadata: (filename) ->
    file_key = filename.replace(".webm", "")
    @realtime_db.ref("users/#{UID}/audios/#{file_key}").remove()

# ============================================================================
# A reference to the root of the firebase storage
# ============================================================================

  storage_root: ->
    @_storage_root ||= @storage.ref()

# ============================================================================
# Options for connecting to Firebase
# These are fine to send to the client and store in source control
# ============================================================================

  firebase_opts:
    apiKey: "AIzaSyCLJ-tKpxLAKcOKtcy0zVumYKQhwaB7FXQ"
    authDomain: "muzak-f826c.firebaseapp.com"
    databaseURL: "https://muzak-f826c.firebaseio.com"
    projectId: "muzak-f826c"
    storageBucket: "muzak-f826c.appspot.com"
    messagingSenderId: "551367724099"