extends State

@export var arrive_distance: float = 8.0
@export var max_travel_distance: float = 48.0
@export var wall_collision_after: float = 8.0
@export var homing_rate: float = 8.0

var distance_flown: float = 0.0
var walls_armed: bool = false
var flight_dir: Vector2 = Vector2.ZERO

func enter(_prev):
  actor.is_possessed = true
  actor.sprite.rotation = 0.0
  actor.current_speed = 0.0
  distance_flown = 0.0
  walls_armed = false
  actor.z_index = 0
  actor.set_collision_mask_value(1, false)

  var player = GameManager.player
  if not player:
    state_machine.request_state("Smashed", true)
    return

  flight_dir = actor.global_position.direction_to(player.get_target_position())
  if flight_dir == Vector2.ZERO:
    state_machine.request_state("Smashed", true)

func physics_update(delta):
  if actor.is_in_light():
    state_machine.request_state("Repelled", true)
    return

  var player = GameManager.player
  if player:
    var desired := actor.global_position.direction_to(player.get_target_position())
    if desired != Vector2.ZERO:
      flight_dir = flight_dir.lerp(desired, clampf(homing_rate * delta, 0.0, 1.0)).normalized()

  actor.velocity = flight_dir * actor.max_speed
  distance_flown += actor.max_speed * delta

  if not walls_armed and distance_flown >= wall_collision_after:
    actor.set_collision_mask_value(1, true)
    walls_armed = true

  if walls_armed and actor.get_slide_collision_count() > 0:
    var hit := actor.get_slide_collision(0)
    if hit.get_normal().dot(flight_dir) < -0.3:
      state_machine.request_state("Smashed")
      return

  if distance_flown >= max_travel_distance:
    state_machine.request_state("Smashed")
    return

  if player and actor.global_position.distance_to(player.get_target_position()) <= arrive_distance:
    state_machine.request_state("Smashed")

func exit(_next):
  GameManager.possessor.release_possessable(actor)
  actor.is_possessed = false
  actor.velocity = Vector2.ZERO
  actor.sprite.position = Vector2.ZERO
  actor.sprite.rotation = 0.0
  actor.z_index = 0
  actor.set_collision_mask_value(1, false)
