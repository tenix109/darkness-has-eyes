extends State

@export var zigzag_frequency: float = 6.0
@export var zigzag_amplitude: float = 20.0

var time_alive: float = 0.0

func enter(_prev):
  actor.is_possessed = true
  actor.sprite.position = Vector2.ZERO
  actor.sprite.rotation = 0.0
    
  actor.current_speed = 0.0
  time_alive = 0.0
    
func physics_update(_delta):
  if actor.is_in_light():
    state_machine.request_state("Repelled", true)
    return
  
  var player = GameManager.player
  if not player:
    return

  actor.nav_agent.target_position = player.get_target_position()
  
  if actor.nav_agent.is_navigation_finished() or player.is_dead:
    actor.velocity = Vector2.ZERO
    return

  time_alive += _delta
  
  actor.current_speed = lerp(actor.current_speed, actor.max_speed, actor.acceleration_rate * _delta)
  
  var next_path_pos = actor.nav_agent.get_next_path_position()
  var direction = actor.global_position.direction_to(next_path_pos)
  
  var side_vector = direction.orthogonal()
  var zigzag = side_vector * sin(time_alive * zigzag_frequency) * zigzag_amplitude
  
  actor.velocity = (direction * actor.current_speed) + zigzag
  
func exit(_next):
  GameManager.possessor.remove_current_possessable()
  actor.is_possessed = false
