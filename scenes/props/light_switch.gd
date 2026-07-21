extends Interactable

@export var room: Room
@export var lights: Node2D

@export var light_switch: AudioStream
@export var power_off: AudioStream
@export var power_on: AudioStream

@onready var usable_light: PointLight2D = $UsableLight

var switch_on: bool = false
var on_cooldown: bool = false
var switch_disabled: bool = false

func _ready() -> void:
  switch_disabled = room.has_no_light
  usable_light.visible = not switch_disabled
  lights.visible = false

func can_interact(_player) -> bool:
  if switch_disabled:
    GameManager.show_toast_message("The switch appears broken.")
    return false
  if switch_on or on_cooldown:
    GameManager.show_toast_message("The switch won't budge.")
    return false
  return true

func interact(player: Player) -> void:
  if not can_interact(player):
    return
  
  turn_on()
  await get_tree().create_timer(10, false).timeout
  start_cooldown()

func turn_on():
  AudioManager.play_sfx_positional(light_switch, global_position)
  switch_on = true
  lights.visible = true
  room.is_lit = true
  usable_light.visible = false

func start_cooldown():
  AudioManager.play_sfx_positional(power_off, global_position)
  on_cooldown = true
  switch_on = false
  lights.visible = false
  room.is_lit = false
  await get_tree().create_timer(3, false).timeout
  end_cooldown()

func end_cooldown():
  AudioManager.play_sfx_positional(power_on, global_position)
  on_cooldown = false
  usable_light.visible = true
