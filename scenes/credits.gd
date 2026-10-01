# CreditsScreen.gd
extends Control

@export var scroll_speed: float = 140.0
@export var fast_scroll_speed: float = 450.0
@export var end_offset: float = 50.0

@onready var vbox: VBoxContainer = $CreditsVBox
@onready var ovani_player: OvaniPlayer = $OvaniPlayer

var scroll_position: float = 0.0
var is_finished: bool = false

func _ready() -> void:
  await get_tree().process_frame
  await get_tree().process_frame
  
  Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
  vbox.position.y = get_viewport_rect().size.y + 150
  ovani_player.FadeIntensity(1.0, 5.0)

func _process(delta: float) -> void:
  if is_finished:
      return
    
  var speed = fast_scroll_speed if Input.is_action_pressed("ui_accept") else scroll_speed
  scroll_position += speed * delta
    
  vbox.position.y = get_viewport_rect().size.y - scroll_position
    
  # === NEW: Stop when the bottom of the VBox is in the middle of the screen ===
  var middle_of_screen = get_viewport_rect().size.y / 2
  var vbox_bottom = vbox.position.y + vbox.size.y
    
  if vbox_bottom <= middle_of_screen + end_offset:
    vbox.position.y = middle_of_screen - vbox.size.y + end_offset
    is_finished = true
    _end_credits()


func _end_credits() -> void:
  ovani_player.FadeVolume(-50, 5)
  ovani_player.FadeIntensity(0, 4.0)
  await get_tree().create_timer(2.5).timeout
  GameManager.load_title_screen()
