extends State

@onready var player: Player = get_parent().get_parent() as Player

func enter(_prev):
  player.set_facing_from_input(-player.pushable_grab_side)
  actor.play_directional_anim("idle")

func physics_update(_delta):
  if player.is_dead or player.current_pushable == null:
    return

  var pushable: Pushable = player.current_pushable
  var axis: Vector2 = pushable.grabbed_side_axis
  var input_vec: Vector2 = player.get_input_vector()

  var along: float = input_vec.dot(axis)
  var axis_input: Vector2 = axis * along

  var move_speed: float = actor.base_speed * actor.push_speed_modifier

  if axis_input.is_zero_approx():
    actor.velocity = Vector2.ZERO
    actor.play_directional_anim("idle")
  else:
    actor.velocity = axis_input.normalized() * move_speed
    actor.play_directional_anim("walk")

  player.set_facing_from_input(-player.pushable_grab_side)

  actor.global_position = pushable.global_position + actor.pushable_grab_offset

func exit(_next):
  actor.animated_sprite.speed_scale = 1.0
