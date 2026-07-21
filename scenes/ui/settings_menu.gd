class_name SettingsMenu
extends VBoxContainer

@onready var music_slider: HSlider = $MusicVolume/MusicSlider
@onready var sound_slider: HSlider = $SoundVolume/SoundSlider
@onready var full_screen_button: CheckButton = $FullScreenButton
@onready var back_button: Button = $BackButton

func _ready() -> void:
  music_slider.value_changed.connect(_on_music_slider_value_changed)
  music_slider.value = SaveManager.music_volume
  sound_slider.value_changed.connect(_on_sfx_slider_value_changed)
  sound_slider.value = SaveManager.sfx_volume
  full_screen_button.toggled.connect(_on_window_mode_toggle_toggled)
  full_screen_button.button_pressed  = SaveManager.is_fullscreen

func _on_music_slider_value_changed(value: float) -> void:
  SaveManager.music_volume = value
  SaveManager.set_bus_volume("Music", value)

func _on_sfx_slider_value_changed(value: float) -> void:
  SaveManager.sfx_volume = value
  SaveManager.set_bus_volume("SFX", value)
  SaveManager.set_bus_volume("SFX2", value)

func _on_window_mode_toggle_toggled(toggled_on: bool) -> void:
  SaveManager.is_fullscreen = toggled_on
  toggle_fullscreen(toggled_on)
    
func toggle_fullscreen(toggled_on: bool)-> void:
  if toggled_on:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
  else:
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
