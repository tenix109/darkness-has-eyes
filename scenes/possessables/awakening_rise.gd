extends State

@export var rise_height: float = 16.0
@export var rise_duration: float = 0.8
@export var pause_duration: float = 0.8
@export var airborne_z_index: int = 5

var awaken_timer: float = 0.0
var tween: Tween
var rest_z_index: int = 0

func enter(_prev):
  actor.set_physics_process(true)
  actor.set_process(true)
  GameManager.possessor.possessed_count += 1
  actor.outline_sprite.visible = true
  awaken_timer = 0.0
  rest_z_index = actor.z_index
  actor.z_index = airborne_z_index
  tween = create_tween()
  tween.tween_property(actor.sprite, "position:y", -rise_height, rise_duration)
  AudioManager.play_awaken_scare(actor.global_position)

func update(delta: float) -> void:
  if actor.is_in_light():
    GameManager.possessor.possessed_count -= 1
    state_machine.request_state("Idle", true)
    return
  awaken_timer += delta
  if awaken_timer >= rise_duration + pause_duration:
    state_machine.request_state("Possessed", true)

func exit(next):
  if tween:
    tween.kill()
    tween = null
  # Keep the risen Y if we're about to rush. Drop only if lights interrupted.
  if next != "Possessed":
    actor.sprite.position = Vector2.ZERO
    actor.sprite.rotation = 0.0
    actor.z_index = rest_z_index
