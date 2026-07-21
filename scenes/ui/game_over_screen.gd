class_name GameOverScreen
extends Control

@onready var darkness: ColorRect = $DarknessVoid
@onready var main_buttons: VBoxContainer = $CenterContainer/MainButtons
@onready var gameover_label: RichTextLabel = $GameoverLabel

@onready var retry_button: Button = $CenterContainer/MainButtons/RetryButton
@onready var title_screen_button: Button = $CenterContainer/MainButtons/TitleScreenButton
@onready var quit_button: Button = $CenterContainer/MainButtons/QuitButton

func _ready() -> void:
  visible = false
  main_buttons.modulate.a = 0.0
  gameover_label.modulate.a = 0.0
  
  retry_button.pressed.connect(_on_retry_button_pressed)
  title_screen_button.pressed.connect(_on_title_screen_button_pressed)
  quit_button.pressed.connect(_on_quit_button_pressed)
   
func _on_retry_button_pressed():
  for btn in main_buttons.get_children():
      btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
  get_viewport().gui_release_focus()
  GameManager.retry_level()

func _on_title_screen_button_pressed():
  for btn in main_buttons.get_children():
      btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
  get_viewport().gui_release_focus()
  GameManager.load_title_screen()

func _on_quit_button_pressed():
  get_tree().quit()

func trigger_game_over() -> void:
  Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
  visible = true
  
  var mat = darkness.material as ShaderMaterial
  mat.set_shader_parameter("radius", 0.0)
  
  var tween = create_tween()
  tween.tween_property(mat, "shader_parameter/radius", 1.3, 1.5).set_trans(Tween.TRANS_SINE)
  
  gameover_label.visible_characters = 0
  
  var label_tween = create_tween()

  label_tween.parallel().tween_property(
    gameover_label, "modulate:a", 1.0, 0.8
  ).set_delay(1.0)

  label_tween.parallel().tween_property(
    gameover_label,
    "visible_characters",
    gameover_label.get_total_character_count(),
    0.4
  ).set_delay(1.0)
  
  var buttons_tween = create_tween()
  buttons_tween.tween_property(main_buttons, "modulate:a", 1.0, 1.0).set_delay(1.5)
  
  buttons_tween.tween_callback(func():
    AudioManager.hook_up_buttons(main_buttons)
    GameManager.find_and_grab_focus(self)
  )
  
