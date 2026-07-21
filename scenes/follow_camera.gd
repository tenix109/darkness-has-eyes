class_name FollowCamera
extends Camera2D

@export var follow_speed: float = 6.0
@export var follow_offset: Vector2
@export var target: Node2D

var shake_strength := 0.0
var shake_time := 0.0

func _ready() -> void:
  #GM.camera = self
  if target: snap_to_target()

func set_target(new_target: Node2D):
  target = new_target

func snap_to_target():
  if target:
    global_position = target.global_position + follow_offset

func _process(delta):
  if not target:
    return
  
  #apply_shake(delta)
  
  var target_postion := target.global_position + follow_offset
  
  global_position = global_position.lerp(
    target_postion,
    1.0 - exp(-follow_speed * delta)
  )

func apply_shake(delta: float):
  if shake_strength > 0.0:
    shake_time -= delta

    offset = Vector2(
      randf_range(-shake_strength, shake_strength),
      randf_range(-shake_strength, shake_strength)
    )
  else:
    offset = Vector2.ZERO
func shake(strength: float, duration: float) -> void:
  shake_strength = strength
  shake_time = duration

func tween_zoom(to: Vector2, duration: float, ease_type := Tween.EASE_OUT, trans := Tween.TRANS_SINE) -> void:
  var tween := get_tree().create_tween()
  tween.tween_property(self, "zoom", to, duration) \
    .set_ease(ease_type) \
    .set_trans(trans)
