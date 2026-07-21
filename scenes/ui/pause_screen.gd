extends CanvasLayer

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings_menu: SettingsMenu = $SettingsMenu

@onready var resume_button: Button = $MainButtons/ResumeButton
@onready var settings_button: Button = $MainButtons/SettingsButton
@onready var title_screen_button: Button = $MainButtons/TitleScreenButton
@onready var quit_button: Button = $MainButtons/QuitButton

var is_paused: bool = false
var controller_disconnected: bool = false

func _ready() -> void:
  resume_button.pressed.connect(_on_resume_pressed)
  settings_button.pressed.connect(_on_settings_pressed)
  settings_menu.back_button.pressed.connect(_on_settings_back_pressed)
  title_screen_button.pressed.connect(_on_title_screen_pressed)
  quit_button.pressed.connect(_on_quit_button_pressed)
  
  Input.joy_connection_changed.connect(_on_joy_connection_changed)
  Steam.overlay_toggled.connect(_on_overlay_toggled)
  
  AudioManager.hook_up_buttons(self)
  Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
  is_paused = false

func _process(_delta: float) -> void:
  Steam.run_callbacks()

func _input(event: InputEvent) -> void:  
  if event.is_action_pressed("pause") and GameManager.can_pause():
    if settings_menu.visible:
      SaveManager.save_game()
    toggle_pause()
  elif event.is_action_pressed("ui_cancel"):
    if settings_menu.visible:
      _on_settings_back_pressed()
      return
    if visible:
      toggle_pause()

func toggle_pause() -> void:
  if is_paused:
    is_paused = false
    GameManager.unpause()
  else:
    is_paused = true
    GameManager.pause()
  visible = is_paused
  
  if is_paused:
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    for child in main_buttons.get_children():
      if GameManager.find_and_grab_focus(child):
        break
  else:
    Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
    
  main_buttons.visible = true
  settings_menu.visible = false

func _on_resume_pressed() -> void:
  toggle_pause()

func _on_settings_pressed() -> void: 
  for child in settings_menu.get_children():
    if GameManager.find_and_grab_focus(child):
      break
  
  main_buttons.visible = false
  settings_menu.visible = true

func _on_settings_back_pressed() -> void:
  SaveManager.save_game()
  for child in main_buttons.get_children():
    if GameManager.find_and_grab_focus(child):
      break
  settings_menu.visible = false
  main_buttons.visible = true

func _on_title_screen_pressed() -> void:
  for btn in main_buttons.get_children():
      btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
  get_viewport().gui_release_focus()
  
  GameManager.load_title_screen()

func _on_quit_button_pressed() -> void:
  get_tree().quit()

func _on_overlay_toggled(active: bool, _user_initiated: bool, _app_id: int) -> void:
  if active and not get_tree().paused:
    toggle_pause()


func _on_joy_connection_changed(_device: int, connected: bool):
    if not connected and not get_tree().paused:
        controller_disconnected = true
        toggle_pause()
