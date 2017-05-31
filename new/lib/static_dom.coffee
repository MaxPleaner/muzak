module.exports = (->

# ============================================================================
# Primary sections
# ============================================================================

  @layout_wrapper = =>
    @_layout_wrapper ||= $("#layout-wrapper")

  @root_wrapper = =>
    @_root_wrapper ||= $("#root-wrapper")

  @root_content = =>
    @_root_content ||= $("#root-content")

  @auth_content = =>
    @_auth_content ||= $("#auth-content")

# ============================================================================
# Auth 
# ============================================================================ 

  @credentials = =>
    @_credentials ||= @root_content.find("#credentials")

  @errors = =>
    @_errors ||= @auth_content.find("#errors")

  @register_selector = =>
    @_register_selector ||= @auth_content.find("#register-selector")

  @register_form = =>
    @_register_form ||= @auth_content.find("#register-form")

  @sign_in_selector = =>
    @_sign_in_selector ||= @auth_content.find("#sign-in-selector")

  @sign_in_submit = =>
    @_sign_in_submit ||= @auth_content.find("#sign-in-submit")

  @register_submit = =>
    @_register_submit ||= @auth_content.find("#register-submit")

  @sign_in_form = =>
    @_sign_in_form ||= @auth_content.find("#sign-in-form")    

  @sign_in_email = =>
    @_sign_in_email ||= @sign_in_form.find("#sign-in-email")  

  @sign_in_pass = =>
    @_sign_in_pass ||= @sign_in_form.find("#sign-in-pass")      

  @register_email = =>
    @_register_email ||= @register_form.find("#register-email")

  @register_pass = =>
    @_register_pass ||= @register_form.find("#register-pass")

  @register_pass_confirm = =>
    @_register_pass_confirm ||= @register_form.find("#register-pass-confirm")
    
# ============================================================================
# Root
# ============================================================================

  @audios = =>
    @_audios ||= @root_content().find("#audios")

  @recordings = =>
    @_recordings ||= @root_content().find("#recordings")

  @audio_template = =>
    @_audio_template ||= @root_content().find("#audio-template")

  @analyser = =>
    @_analyser ||= @root_content().find("#analyser")

  @record_btn = =>
    @_record_btn ||= @root_content().find("#record")

  @recordings = =>
    @_recordings ||= @root_content().find("#recordings")

  @recordings_index = =>
    @_recordings_index ||= @root_content().find("#recordings-index")

  @show_analyser_btn = =>
    @_show_analyser_btn ||= @root_content().find("#show-analyser")

  @show_grid = =>
    @_show_grid ||= @root_content().find("#show-grid")

  @grid_wrapper = =>
    @_grid_wrapper ||= @root_content().find("#grid-wrapper")

  @show_recordings = =>
    @_show_recordings ||= @root_content().find("#show-recordings")

  @around_recordings = =>
    @_around_recordings ||= @root_content().find("#around-recordings")

# ============================================================================
# Grid
# ============================================================================

  @grid_content = =>
    @_grid_content ||= @grid_wrapper().find("#grid-content")

# ============================================================================
# Analyser
# ============================================================================

  @analyser_note = =>
    @_analyser_note ||= @analyser().find("#note")

  @analyser_hz = =>
    @_analyser_hz ||= @analyser().find("#hz")

  @analyser_semitones = =>
    @_analyser_semitones ||= @analyser().find("#semitones")


  this

).apply {}