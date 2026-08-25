extends State

@export var base_footstep_interval: float = 0.5
@onready var player: Player = get_parent().get_parent()
var footstep_timer: float = 0.0

func enter(_prev):
  actor.play_directional_anim("walk")

func physics_update(_delta):
  if actor.is_dead: return
  var input_vec = player.get_input_vector()
  
  if input_vec == Vector2.ZERO:
    request_state("Idle")
    return

  var move_speed: float = actor.base_speed

  if is_running():
    move_speed *= actor.run_speed_modifier

  actor.set_facing_from_input(input_vec)

  actor.velocity = input_vec.normalized() * move_speed
    
  update_animation_speed()
    
  actor.play_directional_anim("walk")
  
  footstep_timer -= _delta

  if footstep_timer <= 0.0:
    actor.play_footstep()
    footstep_timer = get_footstep_interval(move_speed)

#func update(_delta):
  #if Input.is_action_pressed("aim"):
    #request_state("Aim")
    #
  #if actor.can_interact():
    #actor.interaction_allowed = false
    #request_state("Interact")

func dir_to_string(v: Vector2) -> String:
  if v == Vector2.RIGHT: return "right"
  if v == Vector2.LEFT: return "left"
  if v == Vector2.UP: return "up"
  return "down"


func update_animation_speed():
  var scale := 1.0

  if is_running():
    scale *= actor.run_speed_modifier

  actor.animated_sprite.speed_scale = scale
  
func is_running() -> bool:
  actor.is_running = Input.is_action_pressed("run")
  return Input.is_action_pressed("run")

func get_footstep_interval(current_speed: float) -> float:
  var normalized: float = current_speed / actor.base_speed
  return clamp(base_footstep_interval / normalized, 0.15, 0.7)

func exit(_next):
  footstep_timer = 0.0
