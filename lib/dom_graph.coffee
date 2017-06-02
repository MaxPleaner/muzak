module.exports = 
  layout_wrapper: { selector: "#layout-wrapper" }
  root_wrapper: { selector: "#root-wrapper" }

  root_content:

    selector: "#root-content"
    children:

      credentials: { selector: "#credentials" }
      errors: { selector: "#errors" }
      audios: { selector: "#audios" }
      recordings: { selector: "#recordings" }
      recordings_index: { selector: "#recordings-index" }
      audio_template: { selector: "#audio-template" }
      record_btn: { selector: "#record" }
      show_analyser_btn: { selector: "#show-analyser-btn" }
      show_grid: { selector: "#show-grid" }
      show_recordings: { selector: "#show-recordings" }
      around_recordings: { selector: "#around-recordings" }

      grid_wrapper: 

        selector: "#grid-wrapper"
        children:

          grid_content:

            selector: "#grid-content"
            children:

              add_row: { selector: "#add-row" }
              remove_row: { selector: "#remove-row" }
              rows: { selector: "#rows" }
              bpm: { selector: "#bpm" }
              division: { selector: "#division" }
              default_row_length: { selector: "#default-row-length" }
              record_grid: { selector: "#record-grid" }
              play_grid: { selector: "#play-grid" }

      analyser:

        selector: "#analyser"
        children:

          analyser_node: { selector: "#note" }
          analyser_hz: { selector: "#hz" }
          analyser_semitones: { selector: "#semitones" }

  auth_content:

    selector: "#auth-content"
    children:
      
      register_selector: { selector: "#register-selector" }
      register_form: { selector: "#register-form" }
      sign_in_selector: { selector: "#sign-in-selector" }
      sign_in_submit: { selector: "#sign-in-submit" }
      register_submit: { selector: "#register-submit" }
      sign_in_form: { selector: "#sign-in-form" }
      sign_in_email: { selector: "#sign-in-email" }
      sign_in_pass: { selector: "#sign-in-pass" }
      register_email: { selector: "#register-email" }
      register_pass: { selector: "#register-pass" }
      register_pass_confirm: { selector: "#register-pass-confirm" }