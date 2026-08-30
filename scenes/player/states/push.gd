extends State

@export var base_footstep_interval: float = 0.5
var footstep_timer: float = 0.0

@onready var player: Player = get_parent().get_parent() as Player


func enter(_prev):
  player.set_facing_from_input(-player.pushable_grab_side)
  player.play_directional_anim("idle")

func physics_update(delta):
  if player.is_dead or player.current_pushable == null:
    return

  var pushable: Pushable = player.current_pushable
  var axis: Vector2 = pushable.grabbed_side_axis
  var input_vec: Vector2 = player.get_input_vector()

  var along: float = input_vec.dot(axis)
  var axis_input: Vector2 = axis * along

  var move_speed: float = player.base_speed * player.push_speed_modifier
  if axis_input.is_zero_approx():
    player.velocity = Vector2.ZERO
    player.play_directional_anim("idle")
    player.animated_sprite.speed_scale = 1.0
    footstep_timer = 0.0
  else: # moving
    player.velocity = axis_input.normalized() * move_speed
    player.animated_sprite.speed_scale = player.push_speed_modifier * signf(axis_input.dot(player.facing))
    print(signf(axis_input.dot(player.facing)))
    player.play_directional_anim("walk")
    footstep_timer -= delta
    if footstep_timer <= 0.0:
      player.play_footstep()
      footstep_timer = get_footstep_interval(move_speed)

  player.set_facing_from_input(-player.pushable_grab_side)
  
  player.global_position = pushable.global_position + player.pushable_grab_offset

func exit(_next):
  footstep_timer = 0.0
  player.animated_sprite.speed_scale = 1.0

func get_footstep_interval(current_speed: float) -> float:
  var normalized: float = current_speed / player.base_speed
  return clamp(base_footstep_interval / normalized, 0.15, 1.4)
