class_name BlockingDoor extends StaticBody2D

@export var pressure_plate: PressurePlate

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var held_open: bool = false
var pending_close: bool = false

func _ready() -> void:
  animation_player.animation_finished.connect(_on_animation_finished)
  if pressure_plate:
    pressure_plate.weight_changed.connect(set_held_open)
  set_blocked(true)

func set_held_open(should_open: bool):
  if should_open:
    pending_close = false
    if held_open:
      return
    held_open = true
    animation_player.play("open")
    return
    
  if not held_open:
    return
  pending_close = true
  try_close()
  
func try_close() -> void:
  if not pending_close:
    return
  pending_close = false
  held_open = false
  animation_player.play("close")
  set_blocked(true)

func _on_animation_finished(anim_name: StringName) -> void:
  if anim_name == "open":
    animation_player.play("opened")
    set_blocked(false)
  elif anim_name == "close":
    animation_player.play("closed")
  
func set_blocked(blocked: bool) -> void:
  collision_shape.set_deferred("disabled", not blocked)
  
