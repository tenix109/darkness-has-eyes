extends Node

var ui_focus_sound = preload("uid://khitqwv4rb7o")
var ui_press_sound = preload("uid://dbgv2xcq8ont8")

var awaken_sounds: Array[AudioStream] = [
  preload("res://audio/sounds/scares/Cosmic Hit.wav"),
  preload("res://audio/sounds/scares/Dark Hit.wav"),
  preload("res://audio/sounds/scares/Galactic One-Shot.wav"),
  preload("res://audio/sounds/scares/Galaxy Reverse.wav"),
  preload("uid://bpcw0sqd12u8v"),
  preload("uid://oc7lga56vf58"),
  preload("uid://cct6uqy4bf1f4"),
  preload("uid://dus76tcgq7l52"),
  preload("uid://8v1yqncyh7kp"),
  preload("uid://bagcyafuh3pfx"),
]


var music_player: AudioStreamPlayer
var current_music: AudioStream

var sfx_players: Array[AudioStreamPlayer]
var sfx_players2D: Array[AudioStreamPlayer2D]

func _ready():
  process_mode = Node.PROCESS_MODE_ALWAYS
  music_player = AudioStreamPlayer.new()
  music_player.bus = "Music"
  add_child(music_player)

  music_player.finished.connect(func(): 
    if current_music:
      music_player.play()	
)

# Plays a one-shot sound effect.
# sound: The AudioStream resource to play.
# bus_name: The audio bus to play on (e.g., "Master", "SFX").
# volume_db: The volume adjustment in decibels.
func play_sfx(sound: AudioStream, volume_db: float = 0.0, bus_name: String = "SFX") -> AudioStreamPlayer:
  if not sound:
    push_warning("SoundManager: Attempted to play a null AudioStream.")
    return null

  var player = AudioStreamPlayer.new()
  add_child(player)

  player.stream = sound
  player.bus = bus_name
  player.volume_db = volume_db
  
  if bus_name == "SFX":
    player.pitch_scale = randf_range(0.8, 1.2)
  
  sfx_players.append(player)
  
  player.play()

  player.finished.connect(func():
    sfx_players.erase(player)
    player.queue_free()
  )
  
  return player

func play_sfx_positional(sound: AudioStream, pos: Vector2 = Vector2.ZERO, volume_db: float = 0.0, bus_name: String = "SFX", max_dist: float = 480):
  if not sound:
    push_warning("AudioManager: Attempted to play a null AudioStream.")
    return null
  var player = AudioStreamPlayer2D.new()
  add_child(player)
  
  player.stream = sound
  player.bus = bus_name
  player.volume_db = volume_db
  player.global_position = pos
  
  player.max_distance = max_dist
  player.attenuation = 2.0
  
  if bus_name == "SFX":
    player.pitch_scale = randf_range(0.8, 1.2)
  
  sfx_players2D.append(player)
  
  player.play()

  player.finished.connect(func():
    sfx_players2D.erase(player)
    player.queue_free()
  )
  
  return player	
  
func pause_sfx():
  if not sfx_players.is_empty():
    for player in sfx_players:
      if is_instance_valid(player):
        player.stream_paused = true
  if not sfx_players2D.is_empty():
    for player in sfx_players2D:
      if is_instance_valid(player):
        player.stream_paused = true


func unpause_sfx():
  if not sfx_players.is_empty():
    for player in sfx_players:
      if is_instance_valid(player):
        player.stream_paused = false
        
  if not sfx_players2D.is_empty():
    for player in sfx_players2D:
      if is_instance_valid(player):
        player.stream_paused = false

# Plays music that persists between scenes
# music: The AudioStream resource to play
# volume_db: The volume adjustment in decibels
# fade_in: Time in seconds to fade in the new track (0 for instant)
func play_music(music: AudioStream, volume_db: float = 0.0, fade_in: float = 0.0) -> void:
  if not music:
    push_warning("AudioManager: Attempted to play a null music track.")
    return
    
  current_music = music
  
  if music_player.stream == music and music_player.playing:
    music_player.volume_db = volume_db
    return
    
  music_player.stream = music
  
  if fade_in > 0:
    music_player.volume_db = -80.0
    music_player.play()
    
    var tween = create_tween()
    tween.tween_property(music_player, "volume_db", volume_db, fade_in)
  else:
    music_player.volume_db = volume_db
    music_player.play()

# Stops the currently playing music
# fade_out: Time in seconds to fade out (0 for instant)
func stop_music(fade_out: float = 0.0) -> void:
  if not music_player.playing:
    return
    
  if fade_out > 0:
    var tween = create_tween()
    tween.tween_property(music_player, "volume_db", -80.0, fade_out)
    tween.tween_callback(music_player.stop)
  else:
    music_player.stop()

# Cross-fades between the current music and a new track
# new_music: The AudioStream resource to play
# fade_time: Time in seconds for the crossfade transition
# final_volume_db: The final volume of the new track
func crossfade_music(new_music: AudioStream, fade_time: float = 1.0, final_volume_db: float = 0.0) -> void:
  if not new_music:
    push_warning("AudioManager: Attempted to crossfade to a null music track.")
    return
  
  if not music_player.playing:
    play_music(new_music, final_volume_db, fade_time)
    return
  
  if music_player.stream == new_music and music_player.playing:
    return
    
  var old_player = music_player
  
  music_player = AudioStreamPlayer.new()
  music_player.bus = "Music"
  add_child(music_player)
  
  music_player.stream = new_music
  current_music = new_music
  
  music_player.finished.connect(func(): music_player.play())
  
  music_player.volume_db = -80.0
  music_player.play()
  
  var tween = create_tween()
  tween.set_parallel(true)
  
  tween.tween_property(old_player, "volume_db", -80.0, fade_time)
  tween.tween_property(music_player, "volume_db", final_volume_db, fade_time)
  
  tween.chain().tween_callback(func():
    old_player.stop()
    old_player.queue_free()
  )

func pause_music() -> void:
  if music_player.playing:
    music_player.stream_paused = true

func resume_music() -> void:
  if music_player.stream_paused:
    music_player.stream_paused = false

func hook_up_buttons(root_node: Node) -> void:
  for child in root_node.get_children():
    
    if child is BaseButton:
      child.mouse_entered.connect(func(): play_sfx(child.get_meta("unique_sound", ui_focus_sound), 0.0, "SFX"))
      child.focus_entered.connect(func(): play_sfx(child.get_meta("unique_sound", ui_focus_sound), 0.0, "SFX"))
      
      if not child.has_meta("ignore_ui_press"):
        child.pressed.connect(func(): play_sfx(child.get_meta("unique_sound", ui_press_sound), 2.0, "SFX2"))
      
    elif child is Slider:
      child.mouse_entered.connect(func(): play_sfx(child.get_meta("unique_sound", ui_focus_sound), 0.0, "SFX"))
      child.focus_entered.connect(func(): play_sfx(child.get_meta("unique_sound", ui_focus_sound), 0.0, "SFX"))
      child.value_changed.connect(func(_value): play_sfx(child.get_meta("unique_sound", ui_focus_sound), 0.0, "SFX"))

    if child.get_child_count() > 0:
      hook_up_buttons(child)

func play_awaken_scare(pos: Vector2, volume_db: float = 8.0) -> void:
  if awaken_sounds.is_empty():
    return
  play_sfx_positional(awaken_sounds.pick_random(), pos, volume_db)
