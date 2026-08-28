class_name Player
extends Actor

@export var base_speed := 50.0
@export var push_speed_modifier := 0.5 
@export var run_speed_modifier := 1.5
@export var target_offset: Vector2
@export var searching_sounds: Array[AudioStream]

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var action_bar: ActionBar = $ActionBar
@onready var damage_area: Area2D = $DamageArea
@onready var interaction_area: Area2D = $InteractionArea
@onready var state_machine: StateMachine = $StateMachine
@onready var threat_meter: Node = $ThreatMeter

var current_interactable: Interactable = null
var facing: Vector2 = Vector2.UP

var is_winning: bool = false
var is_dead: bool = false
var is_running: bool = false
var is_searching: bool = false
var current_search_object: Searchable = null
var search_timer: float = 0.0
var total_search_time: float = 0.0

var current_pushable: Pushable = null
var pushable_grab_offset: Vector2
var pushable_grab_side: Vector2

const YOU_LOSE = preload("uid://bqtvhiwkgqon0")

func _ready() -> void:
  GameManager.player = self
  position_interaction_area()
  state_machine.request_state("Idle", true)
  interaction_area.area_entered.connect(_on_interaction_area_entered)
  interaction_area.area_exited.connect(_on_interaction_area_exited)
  damage_area.body_entered.connect(_on_damage_body_enter)

func _process(delta: float) -> void:
  if is_searching:
    if is_in_light():
      update_search(delta)
    else:
      stop_searching()
      
  if Input.is_action_just_pressed("interact"):
    if current_pushable:
      stop_pushing()
    elif can_interact() and not is_searching:
      current_interactable.interact(self)
    elif is_searching:
      stop_searching()

func can_interact() -> bool:
  return current_interactable and not is_dead

func _physics_process(_delta):
  move_and_slide()
  if current_pushable:
    current_pushable.sync_from_player_delta(get_position_delta())

func play_directional_anim(base: String) -> String:
  var dir_name = get_facing_string()
  if not animated_sprite:
    animated_sprite = $AnimatedSprite2D
  var anim_name: String = "%s_%s" % [base, dir_name]
  animated_sprite.play(anim_name)
  return anim_name

func set_facing_from_input(input_vec: Vector2):
  if input_vec == Vector2.ZERO:
    return

  if abs(input_vec.x) > abs(input_vec.y):
    facing = Vector2(sign(input_vec.x), 0)
  else:
    facing = Vector2(0, sign(input_vec.y))
    
  position_interaction_area()

func get_facing_string() -> String:
  match facing:
    Vector2.UP:
      return "up"
    Vector2.RIGHT:
      return "right"
    Vector2.LEFT:
      return "left"
  return "down"

func position_interaction_area():
  match get_facing_string():
    "up":
      interaction_area.position = Vector2(0, -18)
    "down":
      interaction_area.position = Vector2(0, 4)
    "left":
      interaction_area.position = Vector2(-8, -8)
    "right":
      interaction_area.position = Vector2(8, -8)

func get_target_position() -> Vector2:
  return global_position + target_offset

func _on_interaction_area_entered(area):
  current_interactable = area
  refresh_context_prompt()

func refresh_context_prompt() -> void:
  if current_pushable:
    GameManager.show_context_message("{interact}Let go")
  elif current_interactable is PushHandle and not current_interactable.can_interact(self):
    GameManager.hide_context_message()
  elif current_interactable:
    GameManager.show_context_message("{interact}" + current_interactable.interaction_prompt)
  else:
    GameManager.hide_context_message()

func _on_interaction_area_exited(area):
  if area == current_interactable:
    current_interactable = null
    GameManager.hide_context_message()

func _on_damage_body_enter(body):
  if body is Possessable and not is_dead and not is_winning:
    if body.is_possessed:
      if current_pushable:
        stop_pushing()
      is_dead = true
      AudioManager.play_sfx(YOU_LOSE)
      state_machine.request_state("Idle", true)
      await get_tree().create_timer(0.5).timeout
      GameManager.game_over()

func start_searching(object: Searchable):
  is_searching = true
  play_searching_sound()
  state_machine.request_state("Idle", true)
  current_search_object = object
  
  search_timer = object.elapsed_time
  total_search_time = object.search_time
  
  action_bar.progress_bar.max_value = total_search_time
  action_bar.progress_bar.value = search_timer
  action_bar.visible = true

func play_searching_sound():
  if not is_searching:
    return
  await get_tree().create_timer(0.3, false).timeout
  AudioManager.play_sfx(searching_sounds.pick_random(), -12.0)
  await get_tree().create_timer(1.2, false).timeout
  play_searching_sound()

func update_search(delta):
  search_timer += delta
  action_bar.progress_bar.value = search_timer
  
  if search_timer >= total_search_time:
    finish_search()

func stop_searching():
  if is_searching:
    is_searching = false
    action_bar.visible = false
    
    if current_search_object:
      current_search_object.interrupt_search(search_timer, current_room.is_lit)
    
    current_search_object = null

func finish_search():
  threat_meter.event_increase()
  is_searching = false
  action_bar.visible = false
  
  if current_search_object:
    current_search_object.complete_search()
  
  current_search_object = null

func start_pushing(pushable: Pushable, side: Vector2):
  current_pushable = pushable
  pushable_grab_offset = global_position - pushable.global_position
  pushable_grab_side = side
  pushable.begin_grab(self, side)
  state_machine.request_state("Push", true)
  GameManager.show_context_message("{interact}Let go")

func stop_pushing():
  pushable_grab_offset = Vector2.ZERO
  pushable_grab_side = Vector2.ZERO
  current_pushable.end_grab()
  current_pushable = null
  state_machine.request_state("Idle", true)
  
  if current_interactable:
    GameManager.show_context_message("{interact}" + current_interactable.interaction_prompt)
  else:
    GameManager.hide_context_message()

func get_input_vector():
  return Vector2(
    Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
    Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
  )
