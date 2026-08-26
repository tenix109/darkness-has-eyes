class_name Pushable
extends AnimatableBody2D

var is_grabbed: bool = false
var grabbed_side_axis: Vector2 = Vector2.ZERO
var grabbing_player: Player = null

func axis_from_side(side: Vector2) -> Vector2:
  if abs(side.x) > abs(side.y):
    return Vector2.RIGHT
  return Vector2.UP

func begin_grab(player: Player, side: Vector2):
  player.add_collision_exception_with(self)
  is_grabbed = true
  grabbing_player = player
  grabbed_side_axis = axis_from_side(side)
  
func end_grab():
  grabbing_player.remove_collision_exception_with(self)
  is_grabbed = false
  grabbing_player = null

func sync_from_player_delta(delta_pos: Vector2) -> void:
  if not is_grabbed:
    return

  var motion := grabbed_side_axis * delta_pos.dot(grabbed_side_axis)
  if motion.is_zero_approx():
    return

  if test_move(global_transform, motion):
    return
  global_position += motion
