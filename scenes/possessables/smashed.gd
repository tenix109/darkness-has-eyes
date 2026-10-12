extends State

@export var shatter_time: float = 0.35
@export var restore_time: float = 0.45
@export var smashed_duration: float = 10.0
@export var seeds: Array[float] = [777.0]
@export var shatter_sounds: Array[AudioStream]
@export var restore_sounds: Array[AudioStream]

var tween: Tween
var mat: ShaderMaterial
var wait_timer: float = 0.0
var restoring: bool = false

func enter(_prev):
  actor.set_physics_process(false)
  actor.set_process(false)
  actor.outline_sprite.visible = false
  actor.sprite.position = Vector2.ZERO
  actor.sprite.rotation = 0.0
  actor.velocity = Vector2.ZERO
  actor.is_possessed = false
  mat = actor.sprite.material as ShaderMaterial
  wait_timer = smashed_duration
  restoring = false
  play_shatter()

func update(delta):
  if restoring:
    return
  wait_timer -= delta
  if wait_timer <= 0.0:
    restoring = true
    play_restore()

func exit(_next):
  if tween:
    tween.kill()
    tween = null
  set_progress(0.0)

func set_progress(value: float) -> void:
  if mat:
    mat.set_shader_parameter("progress", value)

func play_shatter() -> void:
  if not mat:
    return
    
  if not shatter_sounds.is_empty():
    AudioManager.play_sfx_positional(shatter_sounds.pick_random(), actor.global_position, 0.0, "SFX2")
  
  var shatter_seed: float = seeds.pick_random() if not seeds.is_empty() else randf() * 1000.0
  mat.set_shader_parameter("seed", shatter_seed)
  if tween:
    tween.kill()
  tween = actor.create_tween()
  tween.tween_method(set_progress, 0.0, 1.0, shatter_time)

func play_restore() -> void:
  if tween:
    tween.kill()
    
  if not shatter_sounds.is_empty():
    AudioManager.play_sfx_positional(restore_sounds.pick_random(), actor.global_position, 0.0, "SFX2")
  
  tween = actor.create_tween()
  tween.tween_method(set_progress, 1.0, 0.0, restore_time)
  tween.finished.connect(func():
    state_machine.request_state("Idle")
  )
