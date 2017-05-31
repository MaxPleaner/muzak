module.exports =

  grid_matrix: []

  last_row_idx: -1

  recording_filenames: []

  media_recorder_chunks = []

  analyser_data =
    idx: 0
    num_semitones: []
    hertz: []
    scale: "standard"
    ticks_per_analyser_data_point: 10
    
  scales:
    standard: [
      "c", 'c#', 'd', 'd#', 'e', 'f',
      'f#', 'g', 'g#', 'a', 'a#', 'b'
    ]

  nodes: {}

  current_user:
    uid: null