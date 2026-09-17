extends State

@export var awaken_duration: float = 1.5

var awaken_timer: float = 0.0

var tween: Tween 

func enter(_prev):
  actor.set_physics_process(true)
  actor.set_process(true)
  GameManager.possessor.possessed_count += 1
  actor.outline_sprite.visible = true
  awaken_timer = 0.0
  tween = create_tween()
  _start_awaken_tween()
  
  AudioManager.play_awaken_scare(actor.global_position)

func update(delta: float) -> void:
  if actor.is_in_light():
    GameManager.possessor.possessed_count -= 1
    state_machine.request_state("Idle", true)
    return

  awaken_timer += delta
  
  if awaken_timer >= awaken_duration:
    tween.stop()
    state_machine.request_state("Possessed", true)

func _start_awaken_tween() -> void:
  var shake_amount := randf_range(1.0, 3.0)
  var rotate_amount := deg_to_rad(randf_range(-8.0, 8.0))
  var duration := randf_range(0.04, 0.12)

  tween.tween_property(
    actor.sprite,
    "position",
    Vector2(
      randf_range(-shake_amount, shake_amount),
      randf_range(-shake_amount, shake_amount)
    ),
    duration
  )

  tween.parallel().tween_property(
    actor.sprite,
    "rotation",
    rotate_amount,
    duration
  )

  tween.finished.connect(_on_awaken_tween_finished)

func _on_awaken_tween_finished():
  if state_machine.current_state != self:
    tween.stop()
    return

  actor.sprite.position = Vector2.ZERO
  actor.sprite.rotation = 0.0
  tween = create_tween()
  _start_awaken_tween()

func exit(_next):
  actor.sprite.position = Vector2.ZERO
  actor.sprite.rotation = 0.0
