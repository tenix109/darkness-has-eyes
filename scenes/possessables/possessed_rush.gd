extends State

@export var arrive_distance: float = 8.0
@export var overshoot_distance: float = 64.0
@export var wall_collision_after: float = 16.0

var distance_flown: float = 0.0
var walls_armed: bool = false

var target: Vector2
var flight_dir: Vector2 = Vector2.ZERO

func enter(_prev):
  actor.is_possessed = true
  actor.sprite.rotation = 0.0
  actor.current_speed = 0.0
  distance_flown = 0.0
  walls_armed = false
  actor.z_index = 0
  
  var player = GameManager.player
  if not player:
    state_machine.request_state("Idle", true)
    return

  var aim := player.get_target_position()
  flight_dir = actor.global_position.direction_to(aim)
  target = aim + flight_dir * overshoot_distance

  if flight_dir == Vector2.ZERO:
    state_machine.request_state("Idle", true)

func physics_update(delta):
  if actor.is_in_light():
    state_machine.request_state("Repelled", true)
    return

  actor.velocity = flight_dir * actor.max_speed
  distance_flown += actor.max_speed * delta
  
  if not walls_armed and distance_flown >= wall_collision_after:
    actor.set_collision_mask_value(1, true)
    walls_armed = true

  if walls_armed and actor.get_slide_collision_count() > 0:
    var hit := actor.get_slide_collision(0)
    if hit.get_normal().dot(flight_dir) < -0.3:
      state_machine.request_state("Idle", true)
      return

  if actor.global_position.distance_to(target) <= arrive_distance:
    state_machine.request_state("Idle", true)

func exit(next):
  GameManager.possessor.remove_current_possessable()
  actor.is_possessed = false
  actor.velocity = Vector2.ZERO
  actor.sprite.position = Vector2.ZERO
  actor.sprite.rotation = 0.0

  if next == "Idle":
    actor.cooldown()
