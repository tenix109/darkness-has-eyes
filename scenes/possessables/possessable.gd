class_name Possessable
extends Actor

@export var max_speed: float = 110.0
@export var acceleration_rate: float = 0.6

@onready var sprite: Sprite2D = $Visuals/Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var outline_sprite: Sprite2D = $Visuals/Sprite2D/OutlineSprite
@onready var visible_on_screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier

@onready var nav_agent: NavigationAgent2D = $NavAgent
@onready var state_machine: StateMachine = $StateMachine

var current_speed: float = 0.0
var start_room: Room
var start_point: Vector2
var is_possessed: bool = false
var on_cooldown: bool = false

func _ready() -> void:
  start_point = global_position
  state_machine.request_state("Idle", true)
  await get_tree().process_frame
  if GameManager.possessor:
    GameManager.possessor.register_possessable(self)

var last_move_direction: Vector2
func _physics_process(_delta):
  if velocity.length() > 0.0:
    last_move_direction = velocity.normalized()
  
  move_and_slide()

func cooldown() -> void:
  on_cooldown = true
  await get_tree().create_timer(10, false).timeout
  on_cooldown = false

func can_awaken() -> bool:
  return state_machine.get_current_state_name() == "Idle" and not is_in_light() and not on_cooldown

func awaken():
  state_machine.request_state("Awakening", true)
